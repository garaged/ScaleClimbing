import AVFoundation
import Foundation
import MusicTheoryCore
import Synchronization

/// Pure voice-allocation state. Releasing slots stay reserved until their short
/// release ramps complete; no current note is abruptly stolen by a new press.
enum LiveInstrumentVoice: Hashable, Sendable {
    case piano(Int)
    case guitarString(Int)
    case guitarAudition

    var isGuitar: Bool {
        if case .piano = self { return false }
        return true
    }
}

struct LiveKeyboardVoiceRegistry {
    let maxVoices: Int
    private var activeByVoice: [LiveInstrumentVoice: Int] = [:]
    private var releasing: Set<Int> = []

    init(maxVoices: Int) {
        precondition(maxVoices > 0)
        self.maxVoices = maxVoices
    }

    var activeNoteCount: Int { activeByVoice.count }
    var releasingIndices: [Int] { releasing.sorted() }

    mutating func noteOn(midiNumber: Int) -> Int? { noteOn(voice: .piano(midiNumber)) }

    mutating func noteOn(voice: LiveInstrumentVoice) -> Int? {
        guard activeByVoice[voice] == nil else { return nil }
        let occupied = Set(activeByVoice.values).union(releasing)
        guard let available = (0..<maxVoices).first(where: { !occupied.contains($0) }) else {
            return nil
        }
        activeByVoice[voice] = available
        return available
    }

    mutating func noteOff(midiNumber: Int) -> Int? { noteOff(voice: .piano(midiNumber)) }

    mutating func noteOff(voice: LiveInstrumentVoice) -> Int? {
        guard let index = activeByVoice.removeValue(forKey: voice) else { return nil }
        releasing.insert(index)
        return index
    }

    mutating func finishRelease(voice: Int) {
        releasing.remove(voice)
    }

    mutating func releaseAll() -> [Int] {
        let indices = activeByVoice.values.sorted()
        releasing.formUnion(indices)
        activeByVoice.removeAll()
        return indices
    }
}

/// An integer number of cycles produces a seamless repeat at the sample boundary.
/// The 2-second loop has < 0.25 Hz resolution at the default 44.1 kHz.
enum LiveKeyboardTone {
    static func samples(
        frequency: Double,
        sampleRate: Double = 44_100,
        duration: Double = 2
    ) -> [Float] {
        guard frequency.isFinite, frequency > 0,
              sampleRate.isFinite, sampleRate > 0,
              duration.isFinite, duration > 0 else { return [] }
        let frames = Int((sampleRate * duration).rounded())
        guard frames > 1 else { return [] }
        let cycles = max(1, Int((frequency * Double(frames) / sampleRate).rounded()))
        let phaseStep = 2 * Double.pi * Double(cycles) / Double(frames)
        return (0..<frames).map { frame in
            Float(0.09 * sin(phaseStep * Double(frame)))
        }
    }
}

/// A bounded offline additive pluck with decaying partials; not a recorded guitar.
enum LiveGuitarTone {
    static func samples(frequency: Double, sampleRate: Double = 44_100, duration: Double = 2) -> [Float] {
        guard frequency.isFinite, sampleRate.isFinite, duration.isFinite,
              frequency > 0, frequency < sampleRate / 2,
              (100...96_000).contains(sampleRate), (0.01...3).contains(duration) else { return [] }
        let frames = Int((sampleRate * duration).rounded())
        let partials = [1.0, 0.43, 0.26, 0.15, 0.09, 0.05].enumerated().filter {
            Double($0.offset + 1) * frequency < sampleRate / 2
        }
        return (0..<frames).map { frame in
            let t = Double(frame) / sampleRate
            let attack = min(1, t / 0.006)
            let tail = min(1, Double(frames - 1 - frame) / (sampleRate * 0.025))
            var sum = 0.0
            for (index, gain) in partials {
                let harmonic = Double(index + 1)
                sum += gain * exp(-t * (2.6 + harmonic * 0.9)) * sin(2 * Double.pi * harmonic * frequency * t)
            }
            return Float(0.045 * attack * tail * sum)
        }
    }
}

/// Note-on and note-off remain distinct operations: unlike the guided exercise
/// player, this service does not cancel other pitches when a finger is pressed.
@MainActor
public final class LiveKeyboardPlayer {
    private let worker = LiveKeyboardAudioWorker()

    public init() {}

    public func prepare(_ pitches: [Pitch]) {
        worker.prepare(pitches)
    }

    public func noteOn(_ pitch: Pitch) {
        worker.noteOn(pitch)
    }

    public func noteOff(_ pitch: Pitch) {
        worker.noteOff(pitch)
    }

    public func allNotesOff() {
        worker.allNotesOff()
    }

    public func prepareGuitar(_ pitches: [Pitch]) { worker.prepare(pitches, guitar: true) }
    public func guitarNoteOn(string: Int, pitch: Pitch) {
        guard (1...6).contains(string), (-1...9).contains(pitch.octave),
              (0...127).contains(pitch.midiNumber) else { return }
        worker.noteOn(pitch, voice: .guitarString(string))
    }
    public func guitarNoteOff(string: Int) {
        guard (1...6).contains(string) else { return }
        worker.noteOff(voice: .guitarString(string))
    }
    public func auditionGuitar(_ pitch: Pitch) {
        guard (-1...9).contains(pitch.octave), (0...127).contains(pitch.midiNumber) else { return }
        worker.noteOn(pitch, voice: .guitarAudition, autoRelease: true)
    }
}

/// Control commands are published by one serial producer. The render callback
/// alone owns oscillator state; an atomic acknowledgement reserves release tails
/// until the final sample has reached silence. No dispatch, locking or allocation
/// is required while mixing samples.
private final class LiveRenderSlot: @unchecked Sendable {
    private let command = Atomic<UInt64>(0)
    private let finished = Atomic<UInt64>(0)
    private var voice: LiveRenderVoice

    init(sampleRate: Double) {
        voice = LiveRenderVoice(sampleRate: sampleRate)
    }

    func publish(_ value: LiveVoiceCommand) {
        command.store(value.packed, ordering: .releasing)
    }

    func didFinish(generation: UInt64) -> Bool {
        finished.load(ordering: .acquiring) == generation
    }

    func render(into output: UnsafeMutablePointer<Float>, frameCount: Int) -> Bool {
        let next = LiveVoiceCommand(packed: command.load(ordering: .acquiring))
        if next.generation != voice.generation { voice.apply(next) }
        if voice.isSilent {
            if !next.gate { finished.store(next.generation, ordering: .releasing) }
            return false
        }
        for frame in 0..<frameCount {
            output[frame] += voice.nextSample()
        }
        if voice.isSilent && !next.gate {
            finished.store(next.generation, ordering: .releasing)
        }
        return true
    }
}

/// The exact mixer used by the source callback and offline regression tests.
final class LiveRenderMixer: @unchecked Sendable {
    // Fixed -3.74 dB headroom; even ten full-level piano voices cannot exceed
    // 0.585. No count-dependent normalization or limiter-induced modulation.
    static let outputGain: Float = 0.65
    private let slots: [LiveRenderSlot]

    init(voiceLimit: Int, sampleRate: Double) {
        slots = (0..<voiceLimit).map { _ in LiveRenderSlot(sampleRate: sampleRate) }
    }

    func publish(index: Int, command: LiveVoiceCommand) {
        slots[index].publish(command)
    }

    func didFinish(index: Int, generation: UInt64) -> Bool {
        slots[index].didFinish(generation: generation)
    }

    @discardableResult
    func render(into output: UnsafeMutablePointer<Float>, frameCount: Int) -> Bool {
        output.update(repeating: 0, count: frameCount)
        var sounding = false
        for slot in slots {
            if slot.render(into: output, frameCount: frameCount) { sounding = true }
        }
        if sounding {
            for frame in 0..<frameCount { output[frame] *= Self.outputGain }
        }
        return sounding
    }
}

/// Engine and allocator are confined to the control queue. The AVAudioSourceNode
/// owns a fixed set of render slots, shared only through atomic command words.
private final class LiveKeyboardAudioWorker: @unchecked Sendable {
    private static let voiceLimit = 10
    private let queue = DispatchQueue(label: "org.garaged.ScaleClimbing.live-keyboard.audio", qos: .userInitiated)
    private var mixer: LiveRenderMixer?
    private var engine: AVAudioEngine?
    private var registry = LiveKeyboardVoiceRegistry(maxVoices: LiveKeyboardAudioWorker.voiceLimit)
    private var generations = Array(repeating: UInt64.zero, count: LiveKeyboardAudioWorker.voiceLimit)
    private var lastMIDIs = Array(repeating: 0, count: LiveKeyboardAudioWorker.voiceLimit)
    private var lastGuitar = Array(repeating: false, count: LiveKeyboardAudioWorker.voiceLimit)

    func prepare(_ pitches: [Pitch], guitar: Bool = false) {
        // Oscillators need no waveform cache. Warm the output graph before the
        // first touch; the previous graph also remained active after playback.
        guard !pitches.isEmpty else { return }
        queue.async { [self] in _ = ensureEngine() }
    }

    func noteOn(_ pitch: Pitch) {
        guard (-1...9).contains(pitch.octave), (0...127).contains(pitch.midiNumber) else { return }
        noteOn(pitch, voice: .piano(pitch.midiNumber))
    }

    func noteOn(_ pitch: Pitch, voice: LiveInstrumentVoice, autoRelease: Bool = false) {
        let midi = pitch.midiNumber
        queue.async { [self] in
            if autoRelease { release(voice: voice) }
            guard ensureEngine() else { return }
            reapReleasedSlots()
            guard let index = registry.noteOn(voice: voice) else { return }
            lastMIDIs[index] = midi
            lastGuitar[index] = voice.isGuitar
            let generation = publish(index: index, gate: true)
            if autoRelease {
                queue.asyncAfter(deadline: .now() + .milliseconds(2000)) { [self] in
                    guard generations[index] == generation else { return }
                    release(voice: voice)
                }
            }
        }
    }

    func noteOff(_ pitch: Pitch) {
        guard (-1...9).contains(pitch.octave), (0...127).contains(pitch.midiNumber) else { return }
        noteOff(voice: .piano(pitch.midiNumber))
    }

    func noteOff(voice: LiveInstrumentVoice) {
        queue.async { [self] in release(voice: voice) }
    }

    private func release(voice: LiveInstrumentVoice) {
        guard let index = registry.noteOff(voice: voice) else { return }
        _ = publish(index: index, gate: false)
        reapReleasedSlots()
    }

    func allNotesOff() {
        queue.async { [self] in
            for index in registry.releaseAll() { _ = publish(index: index, gate: false) }
            reapReleasedSlots()
        }
    }

    @discardableResult
    private func publish(index: Int, gate: Bool) -> UInt64 {
        let generation = (generations[index] + 1) & LiveVoiceCommand.generationMask
        generations[index] = generation == 0 ? 1 : generation
        mixer?.publish(index: index, command: LiveVoiceCommand(generation: generations[index], midi: lastMIDIs[index],
            guitar: lastGuitar[index], gate: gate))
        return generations[index]
    }

    private func reapReleasedSlots() {
        guard let mixer else { return }
        for index in registry.releasingIndices where mixer.didFinish(index: index, generation: generations[index]) {
            registry.finishRelease(voice: index)
        }
    }

    private func ensureEngine() -> Bool {
        if engine?.isRunning == true { return true }
        do {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            #endif
            if engine == nil {
                let created = AVAudioEngine()
                let outputRate = created.outputNode.outputFormat(forBus: 0).sampleRate
                let rate = outputRate.isFinite && (8_000...192_000).contains(outputRate)
                    ? outputRate : LiveRenderVoice.sampleRate
                guard let format = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1) else {
                    return false
                }
                let renderMixer = LiveRenderMixer(voiceLimit: Self.voiceLimit, sampleRate: rate)
                let source = AVAudioSourceNode(format: format) { isSilence, _, frames, outputData in
                    let buffers = UnsafeMutableAudioBufferListPointer(outputData)
                    guard buffers.count == 1, let data = buffers[0].mData,
                          Int(buffers[0].mDataByteSize) >= Int(frames) * MemoryLayout<Float>.stride else { return -50 }
                    let sounding = renderMixer.render(into: data.assumingMemoryBound(to: Float.self), frameCount: Int(frames))
                    isSilence.pointee = ObjCBool(!sounding)
                    return 0
                }
                created.attach(source)
                created.connect(source, to: created.mainMixerNode, format: format)
                mixer = renderMixer
                engine = created
            }
            guard let engine else { return false }
            engine.prepare()
            try engine.start()
            return true
        } catch { return false }
    }
}
