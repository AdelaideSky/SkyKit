//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

public struct SKColorPicker: View {
    
    @Binding var selection: Color
    
    @State var isDraggingBrightness: Bool = false
    
    var dynamicKnobHiding: Bool = true
    
    public init(_ selection: Binding<Color>) {
        self._selection = selection
    }
    
    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
    }

    public var body: some View {
        Form {
            Section {
                GeometryReader { geo in
                    SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness)
                }.frame(minHeight: 150)
            }
            Section {
                SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false))
                    .frame(height: 25)
                    .padding(1)
            }
        }.frame(minWidth: 150)
            .formStyle(.grouped)
            .scrollDisabled(true)
     }
}
