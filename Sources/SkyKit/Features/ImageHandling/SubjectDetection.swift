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
    
    @Binding var image: UIImage?
    @Binding var foreground: UIImage?
    
    @Binding var state: SKAnalysisState
    
    func body(content: Content) -> some View {
        content
            .task(id: image) {
                state = .unavailable
                DispatchQueue(label: "ImageCropping").async {
                    if let image {
                        foreground = nil
                        DispatchQueue.main.sync { state = .inProgress }
                        
                        let request = VNGenerateForegroundInstanceMaskRequest()
                        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
                        
                        try? handler.perform([request])
                        
                        guard let result = request.results?.first else {
                            DispatchQueue.main.sync { state = .noSubject }
                            return
                        }
                        
                        if let buffer = try? result.generateMaskedImage(ofInstances: result.allInstances, from: handler, croppedToInstancesExtent: false) {
                            let foreground = UIImage(pixelBuffer: buffer)
                            DispatchQueue.main.sync {
                                state = .successfull
                                self.foreground = foreground
                            }
                        } else {
                            DispatchQueue.main.sync { state = .noSubject }
                        }
                    }
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
