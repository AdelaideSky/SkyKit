//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 03/12/2023.
//

#if canImport(UIKit)
import SwiftUI
import Vision

class SKSubjectDetectionHandlerModel {
    func process(_ image: UIImage?, state: Binding<SKAnalysisState>) async {
        // Your asynchronous code here
    }
}
struct SKSubjectDetectionHandler: ViewModifier {
    
    @Binding var image: UIImage?
    @Binding var foreground: UIImage?
    
    @Binding var state: SKAnalysisState
    
    
    
    func body(content: Content) -> some View {
        content
            .task(id: image) {
                await processImage()
            }
    }
    
    private func processImage() async {
        if let image = image {
            foreground = nil
            state = .inProgress
            
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: image.cgImage!)
            
            do {
                try await withCheckedThrowingContinuation { continuation in
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try handler.perform([request])
                            
                            guard let result = request.results?.first else {
                                state = .noSubject
                                continuation.resume(returning: ())
                                return
                            }
                            
                            if let buffer = try? result.generateMaskedImage(ofInstances: result.allInstances, from: handler, croppedToInstancesExtent: false) {
                                let foreground = UIImage(pixelBuffer: buffer)
                                state = .successfull
                                self.foreground = foreground
                            } else {
                                state = .noSubject
                            }
                            continuation.resume(returning: ())
                        } catch {
                            // Handle errors
                            state = .unavailable
                            continuation.resume(throwing: error)
                        }
                    }
                }
            } catch {
                // Handle errors
                state = .unavailable
                print("Error processing image: \(error)")
            }
        }
    }
}

extension View {
    public func subjectDetectionHandler(_ image: Binding<UIImage?>, foreground: Binding<UIImage?>, state: Binding<SKAnalysisState>) -> some View {
        self
            .modifier(SKSubjectDetectionHandler(image: image, foreground: foreground, state: state))
    }
}

public enum SKAnalysisState: Hashable {
    case unavailable
    case inProgress
    case noSubject
    case successfull
}
#endif
