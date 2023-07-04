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
    
    var title: String = ""
    var icon: String = ""
    
    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, title: String = "", systemImage: String = "", onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.title = title
        self.icon = systemImage
    }

    public var body: some View {
        VStack {
            GroupBox(content: {
                    GeometryReader { geo in
                        SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness, onSubmit: onSubmit)
                    }.frame(minHeight: 150)
                        .padding(5)
                    SKRGBHexEditor(selection: $selection, onSubmit: onSubmit)
                    .padding(5)
                }, label: {
                    Group {
                        if title != "" {
                            if icon == "" {
                                Label(title, systemImage: icon)
                                    .labelStyle(.titleOnly)
                            } else {
                                Label(title, systemImage: icon)
                            }
                        } else {
                            EmptyView()
                        }
                    }.bold()
            })
            GroupBox {
                SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), onSubmit: onSubmit)
                    .frame(height: 25)
                    .padding(10)
            }
        }.frame(minWidth: 150)
     }
}
public struct SKCompactColorPicker: View {
    
    @Binding var selection: Color
    
    @State var isDraggingBrightness: Bool = false
    @State var isOpen: Bool = false
    
    var dynamicKnobHiding: Bool = true
    var onSubmit: () -> Void
    
    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Circle()
            .fill(selection)
            .overlay(
                    Circle()
                        .stroke(Color.secondary, lineWidth: 2)
                )
            .frame(width: 20, height: 20)
            .onTapGesture {
                isOpen.toggle()
            }
            .popover(isPresented: $isOpen, content: {
                VStack {
                    GroupBox {
                        GeometryReader { geo in
                            SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness, onSubmit: onSubmit)
                        }.frame(width: 220, height: 200)
                            .padding(.bottom, 3)
                        SKRGBHexEditor(selection: $selection, onSubmit: onSubmit)
                            .frame(width: 210)
                    }
                    GroupBox {
                        SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), onSubmit: onSubmit)
                            .frame(width: 220, height: 25)
                    }
                }.frame(width: 250, height: 310)
//                    .padding()
            })
     }
}
