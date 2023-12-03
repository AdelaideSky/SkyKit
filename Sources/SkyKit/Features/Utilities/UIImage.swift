//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 03/12/2023.
//

import SwiftUI
import VideoToolbox

#if canImport(UIKit)

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}

#endif
