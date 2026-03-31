import AppKit
import AVFoundation
import Foundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorder()

    private var recorder: AVAudioRecorder?
    private var completion: ((URL?) -> Void)?
    private(set) var isRecording = false
    var onLevelUpdate: ((Float) -> Void)?
    private var meterTimer: Timer?

    private var outputURL: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("whisper_recording.m4a")
    }

    private override init() { super.init() }

    // MARK: - Public

    func startRecording() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                guard granted else {
                    self?.showMicrophonePermissionAlert()
                    return
                }
                self?.beginRecording()
            }
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        meterTimer?.invalidate()
        meterTimer = nil
        onLevelUpdate?(0)
        self.completion = completion
        recorder?.stop()
        isRecording = false
    }

    // MARK: - AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        completion?(flag ? recorder.url : nil)
        completion = nil
    }

    // MARK: - Private

    private func beginRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey:             Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:           44100,
            AVNumberOfChannelsKey:     1,
            AVEncoderAudioQualityKey:  AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: outputURL, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.record()
            isRecording = true
            meterTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
                self?.sampleLevel()
            }
        } catch {
            print("[AudioRecorder] Failed to start: \(error)")
        }
    }

    private func sampleLevel() {
        guard let r = recorder, r.isRecording else { return }
        r.updateMeters()
        let db = r.averagePower(forChannel: 0) // -160 to 0 dB
        let minDB: Float = -50
        let level = max(0, min(1, (db - minDB) / (-minDB)))
        onLevelUpdate?(level)
    }

    private func showMicrophonePermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Microphone Access Required"
        alert.informativeText = "Please grant microphone access in System Settings → Privacy & Security → Microphone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
        }
    }
}
