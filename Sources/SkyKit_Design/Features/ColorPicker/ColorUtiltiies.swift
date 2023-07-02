//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

@available(macOS, introduced: 12)
extension Color {
    func getHSB() -> (CGFloat, CGFloat, CGFloat) {
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
