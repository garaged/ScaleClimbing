import AVFoundation
import Foundation
import MusicTheoryCore

/// Pure voice-allocation state. Releasing slots stay reserved until their short
/// release ramps complete; no current note is abruptly stolen by a new press.
struct LiveKeyboardVoiceRegistry {
    let maxVoices: Int
    private var activeByPitch: [Int: Int] = [:]
    private var releasing: Set<Int> = []

    init(maxVoices: Int) {
        precondition(maxVoices > 0)
        self.maxVoices = maxVoices
    }

    var activeNoteCount: Int { activeByPitch.count }

    mutating func noteOn(midiNumber: Int) -> Int? {
        guard activeByPitch[midiNumber] == nil else { return nil }
        let occupied = Set(activeByPitch.values).union(releasing)
        guard let available = (0..<maxVoices).first(where: { !occupied.contains($0) }) else {
            return nil
        }
        activeByPitch[midiNumber] = available
        return available
    }

    mutating func noteOff(midiNumber: Int) -> Int? {
        guard let voice = activeByPitch.removeValue(forKey: midiNumber) else { return nil }
        releasing.insert(voice)
        return voice
    }

    mutating func finishRelease(voice: Int) {
        releasing.remove(voice)
    }

    mutating func releaseAll() -> [Int] {
        let indices = Set(activeByPitch.values).union(releasing).sorted()
        activeByPitch.removeAll()
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
    private var registry = LiveKeyboardVoiceRegistry(maxVoices: LiveKeyboardAudioWorker.voiceLimit)
    private var generations = Array(repeating: UInt64.zero, count: LiveKeyboardAudioWorker.voiceLimit)

    func prepare(_ pitches: [Pitch]) {
        for midi in Set(pitches.map(\.midiNumber)) {
            renderQueue.async { [self] in
                let samples = LiveKeyboardTone.samples(
                    frequency: GeneratedChordTones.frequency(for: Pitch(midiNumber: midi)),
                    sampleRate: Self.sampleRate
                )
                // Only Sendable waveform data crosses Dispatch queues. AVAudioPCMBuffer
                // construction and access remain confined to the audio queue.
                queue.async { [self] in
                    if let buffer = makeBuffer(samples) {
                        buffers[midi] = buffer
                    }
                }
            }
        }
    }

    func noteOn(_ pitch: Pitch) {
        let midi = pitch.midiNumber
        queue.async { [self] in
            guard ensureEngine(), let index = registry.noteOn(midiNumber: midi) else { return }
            guard let buffer = buffers[midi] ?? makeBuffer(LiveKeyboardTone.samples(
                frequency: GeneratedChordTones.frequency(for: pitch),
                sampleRate: Self.sampleRate
            )) else {
                _ = registry.noteOff(midiNumber: midi)
                registry.finishRelease(voice: index)
                return
            }
            buffers[midi] = buffer
            generations[index] &+= 1
            let generation = generations[index]
            let node = nodes[index]
            node.stop()
            node.volume = 0
            node.scheduleBuffer(buffer, at: nil, options: [.loops])
            node.play()
            ramp(index: index, generation: generation, from: 0, to: 1, releasing: false)
        }
    }

    func noteOff(_ pitch: Pitch) {
        queue.async { [self] in
            guard let index = registry.noteOff(midiNumber: pitch.midiNumber) else { return }
            ramp(index: index, generation: generations[index], from: nodes[index].volume, to: 0, releasing: true)
        }
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
