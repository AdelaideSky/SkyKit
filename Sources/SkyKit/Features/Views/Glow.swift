//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 12/01/2024.
//

import SwiftUI

public struct GlowViewModifier: ViewModifier {
    let radius: CGFloat
    let opacity: CGFloat
    
    let saturation: CGFloat
    let brightness: CGFloat
    
    init(radius: CGFloat = 4, opacity: CGFloat = 1, saturation: CGFloat = 1, brightness: CGFloat = 0) {
        self.radius = radius
        self.opacity = opacity
        self.saturation = saturation
        self.brightness = brightness
    }
    
    public func body(content: Content) -> some View {
        if radius > 0 {
            content
                .background(
                    content
                        .blur(radius: radius)
                        .opacity(opacity)
                        .brightness(brightness)
                        .saturation(saturation)
                )
        } else {
            content
        }
    }
}

public extension View {
    func glow(radius: CGFloat = 4, opacity: CGFloat = 1, saturation: CGFloat = 1, brightness: CGFloat = 0) -> some View {
        self.modifier(GlowViewModifier(radius: radius, opacity: opacity, saturation: saturation, brightness: brightness))
    }
}
