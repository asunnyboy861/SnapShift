import Foundation
import Speech
import AVFoundation
import Combine

class VoiceCaptureManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var isListening = false
    var onTrigger: (() -> Void)?

    func startListening() {
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            if authStatus == .notDetermined {
                SFSpeechRecognizer.requestAuthorization { [weak self] status in
                    if status == .authorized {
                        DispatchQueue.main.async { self?.beginRecognition() }
                    }
                }
            }
            return
        }
        beginRecognition()
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isListening = false
    }

    private func beginRecognition() {
        stopListening()

        let node = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.requiresOnDeviceRecognition = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { [weak self] result, _ in
            guard let result = result else { return }
            let transcript = result.bestTranscription.formattedString.lowercased()
            if transcript.contains("now") || transcript.contains("cheese") || transcript.contains("snap") {
                self?.onTrigger?()
                self?.stopListening()
            }
        }

        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true
    }
}
