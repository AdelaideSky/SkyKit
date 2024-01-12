//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 12/01/2024.
//

import SwiftUI

public struct GlowViewModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                content
                    .blur(radius: 4)
            )
    }
}

public extension View {
    func glow() -> some View {
        self.modifier(GlowViewModifier())
    }
}
