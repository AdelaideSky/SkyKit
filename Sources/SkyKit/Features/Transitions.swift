//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 04/02/2024.
//

import SwiftUI

private struct BlurModifier: ViewModifier {
    public let isIdentity: Bool
    public var intensity: CGFloat
    public let ignoresSafeArea: Bool
    public func body(content: Content) -> some View {
        if isIdentity && ignoresSafeArea {
            content
                .blur(radius: isIdentity ? intensity : 0)
                .opacity(isIdentity ? 0 : 1)
                .ignoresSafeArea()
        } else {
            content
                .blur(radius: isIdentity ? intensity : 0)
                .opacity(isIdentity ? 0 : 1)
        }
    }
}

public extension AnyTransition {
    static var blur: AnyTransition {
        .blur()
    }

    static var blurWithoutScale: AnyTransition {
        .modifier(
            active: BlurModifier(isIdentity: true, intensity: 5, ignoresSafeArea: false),
            identity: BlurModifier(isIdentity: false, intensity: 5, ignoresSafeArea: false)
        )
    }

    static func blur(
        intensity: CGFloat = 5,
        scale: CGFloat = 0.8,
        scaleAnimation animation: Animation = .spring(),
        ignoresSafeArea: Bool = false
    ) -> AnyTransition {
        .scale(scale: scale)
            .animation(animation)
            .combined(
                with: .modifier(
                    active: BlurModifier(isIdentity: true, intensity: intensity, ignoresSafeArea: ignoresSafeArea),
                    identity: BlurModifier(isIdentity: false, intensity: intensity, ignoresSafeArea: ignoresSafeArea)
                )
            )
    }
    
}
