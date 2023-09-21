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
    let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
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
                        .fill()
                        .foregroundStyle(.tint.shadow(.inner(color: .gray.opacity(0.2), radius: 5, x: 5, y: 5)).shadow(.inner(color: .black.opacity(0.2), radius: 5, x: -5, y: -5)))
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

public extension ButtonStyle where Self == ProminentShadowedButtonStyle {
    static var prominentShadowed: Self { Self() }
}
