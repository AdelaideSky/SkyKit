//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 03/12/2023.
//

#if canImport(UIKit)
import SwiftUI
import Vision

struct SKSubjectDetectionHandler: ViewModifier {
    
    @Binding var image: Data?
    @Binding var foreground: Data?
    
    @Binding var state: SKAnalysisState
    
    func body(content: Content) -> some View {
        content
            .onChange(of: image) {
                Task {
                    await processImage()
                }
            }
    }
    
    private func processImage() async {
        if let image = image {
            foreground = nil
            state = .inProgress
            
            let request = VNGenerateForegroundInstanceMaskRequest()
            
            var cgImage = CGImage(pngDataProviderSource: .init(data: image as CFData)!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
            if cgImage == nil {
                cgImage = CGImage(jpegDataProviderSource: .init(data: image as CFData)!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
            }
            
            guard cgImage != nil else {
                state = .noSubject
                return
            }
            let handler = VNImageRequestHandler(cgImage: cgImage!)
            
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
                                let foreground = UIImage(pixelBuffer: buffer)?.pngData()
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
    public func subjectDetectionHandler(_ image: Binding<Data?>, foreground: Binding<Data?>, state: Binding<SKAnalysisState>) -> some View {
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
