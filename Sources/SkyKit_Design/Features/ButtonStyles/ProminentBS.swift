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
