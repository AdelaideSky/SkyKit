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
    var onSubmit: () -> Void
    
    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Form {
            Section {
                GeometryReader { geo in
                    SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness, onSubmit: onSubmit)
                }.frame(minHeight: 150)
            }
            Section {
                SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), onSubmit: onSubmit)
                    .frame(height: 25)
                    .padding(1)
            }
        }.frame(minWidth: 150)
            .formStyle(.grouped)
            .scrollDisabled(true)
     }
}
