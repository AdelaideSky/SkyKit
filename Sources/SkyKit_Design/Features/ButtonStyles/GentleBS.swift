//
//  GentleBS.swift
//  
//
//  Created by Adélaïde Sky on 04/06/2023.
//

import Foundation
import SwiftUI

public struct GentleButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @State var isHover: Bool = false
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(4)
            .background {
                Color.gray
                    .opacity(configuration.isPressed ? 0.2 : isHover ? 0.1 : 0)
            }
            .onHover { isHover = $0 }
            .cornerRadius(5)
            .symbolVariant(configuration.isPressed ? .fill : .none)
    }
}

public extension ButtonStyle where Self == GentleButtonStyle {
    static var gentle: Self { Self() }
}
