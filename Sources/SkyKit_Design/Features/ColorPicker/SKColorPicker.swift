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
    @State var isDragging: Bool = false
    
    var dynamicKnobHiding: Bool = true
    var onSubmit: () -> Void
    var onDraggingChange: (Bool) -> Void
    
    var title: String = ""
    var icon: String = ""
    
    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, title: String = "", systemImage: String = "", onDraggingChange: @escaping (Bool) -> Void = {_ in}, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.title = title
        self.icon = systemImage
        self.onDraggingChange = onDraggingChange
        
    }

    public var body: some View {
        VStack {
            GroupBox(content: {
                VStack {
                    GeometryReader { geo in
                        SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness, isDragging: _isDragging, onSubmit: onSubmit)
                    }.frame(minHeight: 150)
                        .padding(10)
                    SKRGBHexEditor(selection: $selection, onSubmit: onSubmit)
                    .frame(height: 40)
                    .padding(.horizontal, 10)
                    .padding(.top, -5)
                    .padding(.bottom, 5)
                }
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
        }.frame(minWidth: 200)
            .onChange(of: isDraggingBrightness || isDragging) { newValue in
                onDraggingChange(newValue)
            }
     }
}
public struct SKCompactColorPicker: View {
    
    @Binding var selection: Color
    
    @State var isDraggingBrightness: Bool = false
    @State var isDragging: Bool = false
    @State var isOpen: Bool = false
    
    var dynamicKnobHiding: Bool = true
    var onSubmit: () -> Void
    var onDraggingChange: (Bool) -> Void

    public init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, onDraggingChange: @escaping (Bool) -> Void = {_ in}, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.onDraggingChange = onDraggingChange

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
                        Group {
                            GeometryReader { geo in
                                SKColorWheel($selection, geo: geo, showingKnob: !isDraggingBrightness, isDragging: _isDragging, onSubmit: onSubmit)
                            }.frame(width: 230, height: 210)
                                .padding(.bottom, 3)
                            SKRGBHexEditor(selection: $selection, onSubmit: onSubmit)
                                .frame(width: 210, height: 30)
                        }.padding(3)
                    }
                    GroupBox {
                        SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), onSubmit: onSubmit)
                            .frame(width: 230, height: 25)
                            .padding(4)
                    }
                }.frame(width: 260, height: 337)
                    .onChange(of: isDraggingBrightness || isDragging) { newValue in
                        onDraggingChange(newValue)
                    }
//                    .padding()
            })
     }
}
