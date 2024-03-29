//
//  GentleFillingBS.swift
//  
//
//  Created by Adélaïde Sky on 04/06/2023.
//

import Foundation
import SwiftUI

public struct GentleFillingButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    @State var multicolorIconOnClick = false
    let darkStyle: Bool
    
    public init(multicolorIconOnClick: Bool = false) {
        self._multicolorIconOnClick = .init(initialValue: multicolorIconOnClick)
        self.darkStyle = false
    }
    public init(darkStyle: Bool = false) {
        self.darkStyle = darkStyle
    }
    
    public init() {self.darkStyle = false}
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        VStack {
            Spacer(minLength: 0)
            HStack {
                Spacer(minLength: 0)
                configuration.label
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }.background {
            if darkStyle {
                if colorScheme == .dark {
                    #if canImport(UIKit)
                    Color(uiColor: .secondarySystemGroupedBackground)
                        .opacity(configuration.isPressed ? 1 : 0.9)
                    #else
                    Rectangle().fill(.background)
                        .opacity(configuration.isPressed ? 1 : 0.9)
                    #endif
                } else {
                    #if canImport(UIKit)
                    Color(uiColor: .secondarySystemGroupedBackground)
                        .opacity(configuration.isPressed ? 0.9 : 0.8)
                    #else
                    Rectangle().fill(.white)
                        .opacity(configuration.isPressed ? 1 : 0.9)
                    #endif
                }
            } else {
                Color.gray
                    .opacity(configuration.isPressed ? 0.2 : 0.1)
            }
        }
        .cornerRadius(darkStyle ? 10 : 5)
        .symbolVariant(configuration.isPressed ? .fill : .none)
        .symbolRenderingMode(multicolorIconOnClick ? .monochrome : configuration.isPressed ? .multicolor : .monochrome)
    }
}

public extension ButtonStyle where Self == GentleFillingButtonStyle {
    static var gentleFilling: Self { Self() }
    static func gentleFilling(darkStyle: Bool) -> Self { Self(darkStyle: darkStyle) }
}

