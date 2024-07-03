//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 05/06/2023.
//

import Foundation
import SwiftUI
import CoreGraphics
import SkyKitC

#if os(iOS)
public typealias SystemImage = UIImage
#elseif os(macOS)
public typealias SystemImage = NSImage
#endif

#if !os(visionOS)
public struct SKNoiseGenerator {
    @AppStorage("fr.adesky.skyKit.noiseCache") var cache: [UInt32] = []
    
    var cachingEnabled: Bool
    
    public init() {
        self.cachingEnabled = true
    }
    
    public init(cachingEnabled: Bool) {
        self.cachingEnabled = cachingEnabled
    }
    public func image(width: Int, height: Int, completionHandler: @escaping (SystemImage?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                let colorSpace       = CGColorSpaceCreateDeviceRGB()
                let bytesPerPixel    = 4
                let bitsPerComponent = 8
                let bytesPerRow      = bytesPerPixel * width
                let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
                let random = randomAlpha(Int32(width * height))
                guard let context = CGContext(data: random, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                    completionHandler(nil)
                    return
                }
                
                let cgImage = context.makeImage()!
                
                #if os(macOS)
                let image = SystemImage(cgImage: cgImage, size: .init(width: CGFloat(width), height: CGFloat(height)))
                #else
                let image = SystemImage(cgImage: cgImage)

                #endif
                
                completionHandler(image)
                random?.deallocate()
            }
        }
    }
    func clearCache() {
        self.cache = []
    }
}

#endif
