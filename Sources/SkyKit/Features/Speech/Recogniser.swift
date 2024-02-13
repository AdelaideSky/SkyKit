//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 12/02/2024.
//
//  Source from https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text, modified to fit modern apis

import Foundation
import AVFoundation
import Speech
import SwiftUI
import Observation


/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
@Observable
public class SKTranscriptionTape {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    public enum RecognitionState: Hashable {
        case stopped
        case starting
        case transcribing
        case stopping
        case error(String)
        
        public var label: String {
            switch self {
            case .stopped:
                "Stopped"
            case .starting:
                "Starting..."
            case .transcribing:
                "Transcribing"
            case .stopping:
                "Stopping..."
            case .error(let string):
                "Error: \(string)"
            }
        }
    }
    
    public var state: RecognitionState = .stopped
    
    public var transcript: String = ""
    
    @ObservationIgnored
    private var audioEngine: AVAudioEngine?
    
    @ObservationIgnored
    private var request: SFSpeechAudioBufferRecognitionRequest?
    
    @ObservationIgnored
    private var task: SFSpeechRecognitionTask?
    
    @ObservationIgnored
    private let recognizer: SFSpeechRecognizer?
    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    public init() {
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            state = .error("Unable to initialise")
            return
        }
        recognizer?.defaultTaskHint = .dictation
        Task {
            guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                state = .error("Unauthorised: can't transcribe")
                return
            }
            guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                state = .error("Unauthorised: can't record")
                return
            }
        }
    }
    
    
    public func toggleTranscription() {
        Task {
            if state != .stopped {
                self.reset()
            } else {
                self.transcribe()
            }
        }
    }
    /**
     Begin transcribing audio.
     
     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.
     */
    public func transcribe() {
        guard let recognizer, recognizer.isAvailable else {
            state = .error("Recogniser is unavailable")
            return
        }
        
        self.state = .starting
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
            self.state = .transcribing
        } catch {
            self.reset()
            state = .error("Something went wrong")
        }
    }
    
    /// Reset the speech recognizer.
    public func stop() {
        state = .stopping
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
        state = .stopped
    }
    
    public func reset() {
        stop()
        transcript = ""
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
//        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(result.bestTranscription.formattedString)
        }
    }
    
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
}


extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}


extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
