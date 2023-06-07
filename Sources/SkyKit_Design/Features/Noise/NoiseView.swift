//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 03/06/2023.
//

import SwiftUI
import CoreGraphics
import SkyKitC
#if os(iOS)
func createImage(width: Int, height: Int, completionHandler: @escaping (UIImage?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
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
    }

}
#else
func createImage(width: Int, height: Int, completionHandler: @escaping (NSImage?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
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

        let image = NSImage(cgImage: cgImage, size: .init(width: CGFloat(width), height: CGFloat(height)))

        completionHandler(image)
    }

}
#endif
public struct SKNoise: View {
    
    @State var image: Image?
    
    public init() {
        
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                if image != nil {
                    image
                }
            }.task {
                createImage(width: Int(geo.size.width), height: Int(geo.size.height), completionHandler: { noise in
                    if noise != nil {
                        #if os(iOS)
                        image = Image(uiImage: noise!)
                        #else
                        image = Image(nsImage: noise!)
                        #endif
                    }
                })
            }
        }
    }
}
