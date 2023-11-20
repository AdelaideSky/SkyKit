//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 04/06/2023.
//

import Foundation
import SwiftUI

public struct ProminentButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    public func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .font(.headline)
                .padding(15)
            Spacer()
        }
            .background {
                ZStack {
                    Rectangle()
                        .fill(.tint)
                        .opacity(isEnabled ? 1 : 0)
                    SKNoiseTexture()
                        .opacity(0.1)
                }
                    .opacity(configuration.isPressed ? 0.8 : 1)
            }
            .cornerRadius(10)
            .symbolVariant(configuration.isPressed ? .fill : .none)
            
    }
}

public extension ButtonStyle where Self == ProminentButtonStyle {
    static var prominent: Self { Self() }
}

public struct ProminentShadowedButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .font(.headline)
                .padding(15)
            Spacer()
        }
            .background {
                ZStack {
                    if colorScheme == .dark {
                        Rectangle()
                            .fill()
                            .foregroundStyle(.tint.shadow(.inner(color: configuration.isPressed ? .black.opacity(0.2) : .white.opacity(0.2), radius: 5, x: 5, y: 5)).shadow(.inner(color: .black.opacity(0.25), radius: 5, x: -5, y: -5)))
                            .opacity(isEnabled ? 1 : 0)
                    } else {
                        Rectangle()
                            .fill()
                            .foregroundStyle(.tint.shadow(.inner(color: configuration.isPressed ? .black.opacity(0.2) : .white.opacity(0.3), radius: 5, x: 5, y: 5)).shadow(.inner(color: .black.opacity(0.2), radius: 5, x: -5, y: -5)))
                            .opacity(isEnabled ? 1 : 0)
                    }
                    SKNoiseTexture()
                        .opacity(0.1)
                }
                .brightness(configuration.isPressed ? -0.2 : -0.1)
                .saturation(configuration.isPressed ? 0.9 : 1)
            }
            .cornerRadius(10)
            .symbolVariant(configuration.isPressed ? .fill : .none)
    }
}

public extension ButtonStyle where Self == ProminentShadowedButtonStyle {
    static var prominentShadowed: Self { Self() }
}
