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
    init(radius: CGFloat = 4, opacity: CGFloat = 1) {
        self.radius = radius
        self.opacity = opacity
    }
    public func body(content: Content) -> some View {
        content
            .background(
                content
                    .blur(radius: radius)
                    .opacity(opacity)
            )
    }
}

public extension View {
    func glow(radius: CGFloat = 4, opacity: CGFloat = 1) -> some View {
        self.modifier(GlowViewModifier(radius: radius, opacity: opacity))
    }
}
