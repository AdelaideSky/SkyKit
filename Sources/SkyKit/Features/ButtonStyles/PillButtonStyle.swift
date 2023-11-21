//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 21/11/2023.
//

import SwiftUI

public struct PillButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(.background)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .foregroundStyle(.secondary)
                    .opacity(configuration.isPressed ? 0.9 : 1)
            }
            .symbolVariant(configuration.isPressed ? .fill : .none)
    }
}

public extension ButtonStyle where Self == PillButtonStyle {
    static var pill: Self { Self() }
}
