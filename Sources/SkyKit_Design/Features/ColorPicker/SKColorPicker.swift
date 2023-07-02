//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

public struct SKColorPicker: View {
    
    @Binding var selection: Color
    
    public init(_ selection: Binding<Color>) {
        self._selection = selection
    }

    public var body: some View {
        Form {
            Section {
                GeometryReader { geo in
                    SKColorWheel($selection, geo: geo)
                }.frame(minHeight: 150)
            }
            Section {
                SKBrightnessSlider($selection)
                    .frame(height: 25)
                    .padding(1)
            }
        }.frame(minWidth: 150)
            .formStyle(.grouped)
            .scrollDisabled(true)
     }
}
