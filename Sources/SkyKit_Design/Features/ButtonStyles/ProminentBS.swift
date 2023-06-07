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
                    Color.accentColor
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
