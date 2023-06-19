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
    
    public init(multicolorIconOnClick: Bool = false) {
        self.multicolorIconOnClick = multicolorIconOnClick
    }
    public init() {}
    
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
            Color.gray
                .opacity(configuration.isPressed ? 0.2 : 0.1)
        }
        .cornerRadius(5)
        .symbolVariant(configuration.isPressed ? .fill : .none)
        .symbolRenderingMode(multicolorIconOnClick ? .monochrome : configuration.isPressed ? .multicolor : .monochrome)
    }
}

public extension ButtonStyle where Self == GentleFillingButtonStyle {
    static var gentleFilling: Self { Self() }
}

