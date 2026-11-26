import AVFoundation
import Foundation
import MusicTheoryCore

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
        let indices = Set(activeByVoice.values).union(releasing).sorted()
        activeByVoice.removeAll()
        releasing.removeAll()
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

/// Engine state, buffer cache, and voice allocator are confined to a serial
/// queue; waveform synthesis happens on a separate background render queue.
private final class LiveKeyboardAudioWorker: @unchecked Sendable {
    private static let voiceLimit = 10
    private static let sampleRate: Double = 44_100
    private static let rampSteps = 10
    private static let rampDurationMilliseconds = 30

    private let queue = DispatchQueue(label: "org.garaged.ScaleClimbing.live-keyboard.audio", qos: .userInitiated)
    private let renderQueue = DispatchQueue(label: "org.garaged.ScaleClimbing.live-keyboard.render", qos: .utility, attributes: .concurrent)

    private var engine: AVAudioEngine?
    private var nodes: [AVAudioPlayerNode] = []
    private var buffers: [Int: AVAudioPCMBuffer] = [:]
    private var guitarBuffers: [Int: AVAudioPCMBuffer] = [:]
    private var registry = LiveKeyboardVoiceRegistry(maxVoices: LiveKeyboardAudioWorker.voiceLimit)
    private var generations = Array(repeating: UInt64.zero, count: LiveKeyboardAudioWorker.voiceLimit)

    func prepare(_ pitches: [Pitch], guitar: Bool = false) {
        for midi in Set(pitches.filter { (-1...9).contains($0.octave) }.map(\.midiNumber).filter { (0...127).contains($0) }) {
            renderQueue.async { [self] in
                let samples = Self.waveform(pitch: Pitch(midiNumber: midi), guitar: guitar)
                // Only Sendable waveform data crosses Dispatch queues. AVAudioPCMBuffer
                // construction and access remain confined to the audio queue.
                queue.async { [self] in
                    if let buffer = makeBuffer(samples) {
                        if guitar { guitarBuffers[midi] = buffer } else { buffers[midi] = buffer }
                    }
                }
            }
        }
    }

    private static func waveform(pitch: Pitch, guitar: Bool) -> [Float] {
        let frequency = GeneratedChordTones.frequency(for: pitch)
        return guitar ? LiveGuitarTone.samples(frequency: frequency, sampleRate: sampleRate)
                      : LiveKeyboardTone.samples(frequency: frequency, sampleRate: sampleRate)
    }

    func noteOn(_ pitch: Pitch) { noteOn(pitch, voice: .piano(pitch.midiNumber)) }

    func noteOn(_ pitch: Pitch, voice: LiveInstrumentVoice, autoRelease: Bool = false) {
        let midi = pitch.midiNumber
        queue.async { [self] in
            if autoRelease { release(voice: voice) }
            guard ensureEngine(), let index = registry.noteOn(voice: voice) else { return }
            let cached = voice.isGuitar ? guitarBuffers[midi] : buffers[midi]
            guard let buffer = cached ?? makeBuffer(Self.waveform(pitch: pitch, guitar: voice.isGuitar)) else {
                _ = registry.noteOff(voice: voice)
                registry.finishRelease(voice: index)
                return
            }
            if voice.isGuitar { guitarBuffers[midi] = buffer } else { buffers[midi] = buffer }
            generations[index] &+= 1
            let generation = generations[index]
            let node = nodes[index]
            node.stop()
            node.volume = 0
            node.scheduleBuffer(buffer, at: nil, options: voice.isGuitar ? [] : [.loops])
            node.play()
            ramp(index: index, generation: generation, from: 0, to: 1, releasing: false)
            if autoRelease {
                queue.asyncAfter(deadline: .now() + .milliseconds(2000)) { [self] in
                    guard generations[index] == generation else { return }
                    release(voice: voice)
                }
            }
        }
    }

    func noteOff(_ pitch: Pitch) { noteOff(voice: .piano(pitch.midiNumber)) }

    func noteOff(voice: LiveInstrumentVoice) {
        queue.async { [self] in release(voice: voice) }
    }

    private func release(voice: LiveInstrumentVoice) {
        guard let index = registry.noteOff(voice: voice) else { return }
        generations[index] &+= 1
        ramp(index: index, generation: generations[index], from: nodes[index].volume, to: 0, releasing: true)
    }

    func allNotesOff() {
        queue.async { [self] in
            for index in registry.releaseAll() {
                generations[index] &+= 1 // Cancel any callbacks from previous attacks/releases.
                ramp(index: index, generation: generations[index], from: nodes[index].volume, to: 0, releasing: true)
            }
        }
    }

    private func ensureEngine() -> Bool {
        if engine == nil {
            let created = AVAudioEngine()
            guard let format = AVAudioFormat(standardFormatWithSampleRate: Self.sampleRate, channels: 1) else {
                return false
            }
            for _ in 0..<Self.voiceLimit {
                let node = AVAudioPlayerNode()
                created.attach(node)
                created.connect(node, to: created.mainMixerNode, format: format)
                nodes.append(node)
            }
            engine = created
        }

        guard let engine else { return false }
        if !engine.isRunning {
            do {
                #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(
                    .playback, mode: .default, options: [.mixWithOthers]
                )
                try AVAudioSession.sharedInstance().setActive(true)
                #endif
                try engine.start()
            } catch {
                return false
            }
        }
        return true
    }

    private func makeBuffer(_ samples: [Float]) -> AVAudioPCMBuffer? {
        guard !samples.isEmpty,
              let format = AVAudioFormat(standardFormatWithSampleRate: Self.sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(
                  pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)
              ),
              let channel = buffer.floatChannelData?[0] else { return nil }

        buffer.frameLength = AVAudioFrameCount(samples.count)
        for index in samples.indices { channel[index] = samples[index] }
        return buffer
    }

    private func ramp(
        index: Int,
        generation: UInt64,
        from initial: Float,
        to target: Float,
        releasing: Bool
    ) {
        for step in 1...Self.rampSteps {
            queue.asyncAfter(
                deadline: .now() + .milliseconds(step * Self.rampDurationMilliseconds / Self.rampSteps)
            ) { [self] in
                guard generations[index] == generation else { return }
                let fraction = Float(step) / Float(Self.rampSteps)
                nodes[index].volume = initial + (target - initial) * fraction
                if releasing && step == Self.rampSteps {
                    nodes[index].stop()
                    nodes[index].volume = 0
                    registry.finishRelease(voice: index)
                }
            }
        }
    }
}
