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


public struct SKNoiseGenerator {
    @AppStorage("fr.adesky.skyKit.noiseCache") var cache: [UInt32] = []
    
    var cachingEnabled: Bool
    
    public init() {
        self.cachingEnabled = true
    }
    
    public init(cachingEnabled: Bool) {
        self.cachingEnabled = cachingEnabled
    }
    
    #if os(iOS)
    func image(width: Int, height: Int, completionHandler: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                let colorSpace       = CGColorSpaceCreateDeviceRGB()
                let bytesPerPixel    = 4
                let bitsPerComponent = 8
                let bytesPerRow      = bytesPerPixel * width
                let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
                
                guard let context = CGContext(data: randomAlpha(Int32(width * height)), width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                    completionHandler(nil)
                    return
                }
                
                let cgImage = context.makeImage()!
                
                let image = UIImage(cgImage: cgImage)
                
                completionHandler(image)
                
                // Release the resources
                context.release()
                cgImage.release()
            }
        }
    }
    #else
    func image(width: Int, height: Int, completionHandler: @escaping (NSImage?) -> Void) {
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
                
                let image = NSImage(cgImage: cgImage, size: .init(width: CGFloat(width), height: CGFloat(height)))
                
                completionHandler(image)
                random?.deallocate()
            }
        }
    }
    #endif
    func clearCache() {
        self.cache = []
    }
}

