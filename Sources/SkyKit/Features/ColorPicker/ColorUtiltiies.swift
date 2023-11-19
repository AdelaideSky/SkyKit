//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

#if os(macOS)
@available(macOS, introduced: 12)
extension Color {
    func getHSB() -> (CGFloat, CGFloat, CGFloat) {
        autoreleasepool {
            guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else {
                return (0, 0, 0)
            }
            
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            return (hue, saturation, brightness)
        }
    }
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        autoreleasepool {
            guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else {
                return (0, 0, 0)
            }
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return (red, green, blue)
        }
    }
}
#else
extension Color {
//    func getHSB() -> (CGFloat, CGFloat, CGFloat) {
//        autoreleasepool {
//            guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else {
//                return (0, 0, 0)
//            }
//            
//            var hue: CGFloat = 0
//            var saturation: CGFloat = 0
//            var brightness: CGFloat = 0
//            var alpha: CGFloat = 0
//            
//            nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
//            
//            return (hue, saturation, brightness)
//        }
//    }
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        autoreleasepool {
            guard let uiColor = UIColor(self) else {
                return (0, 0, 0)
            }
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return (red, green, blue)
        }
    }
}
#endif
