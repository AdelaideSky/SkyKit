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
    
    var title: String?
    var icon: String?
    
    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, title: String? = nil, systemImage: String? = nil, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.title = title
        self.icon = systemImage
    }

    public var body: some View {
        VStack {
            if let title = title, let icon = icon {
                GroupBox(content: {
                    GeometryReader { geo in
                        SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness, onSubmit: onSubmit)
                    }.frame(minHeight: 150)
                        .padding(5)
                }, label: {
                    Label(title, systemImage: icon)
                })
            }
            GroupBox {
                SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), onSubmit: onSubmit)
                    .frame(height: 25)
                    .padding(10)
            }
        }.frame(minWidth: 150)
     }
}
