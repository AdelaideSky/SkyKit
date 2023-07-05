//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

public struct SKColorPicker<Label: View>: View {
    
    @Binding var selection: Color
    
    @State var isDraggingBrightness: Bool = false
    @State var isDragging: Bool = false
    @State var isOpen: Bool = false
    
    var dynamicKnobHiding: Bool = true
    var onSubmit: () -> Void
    var onDraggingChange: (Bool) -> Void
    var label: (() -> Label)?
    
    var style: SKColorPickerStyle = .compact
    
    public enum SKColorPickerStyle {
        case compact
        case expanded
    }

    public init(_ selection: Binding<Color>,
                label: @escaping () -> Label,
                dynamicKnobHiding: Bool = true,
                onDraggingChange: @escaping (Bool) -> Void = {_ in},
                onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.onDraggingChange = onDraggingChange
        self.label = label
    }
    
    public func skColorPickerStyle(_ style: SKColorPickerStyle) -> SKColorPicker {
        var answer = self
        answer.style = style
        return answer
    }
    
    var expandedView: some View {
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
                }
            }, label: {
                    if let label = label {
                        label()
                    }
            })
            GroupBox {
                SKBrightnessSlider($selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), onSubmit: onSubmit)
                    .frame(height: 25)
                    .padding(10)
            }
        }.frame(minWidth: 260, minHeight: 337)
            .onChange(of: isDraggingBrightness || isDragging) { newValue in
                onDraggingChange(newValue)
            }
     }
    
    var compactView: some View {
        Circle()
            .fill(selection)
            .frame(width: 15, height: 15)
            .overlay(
                    Circle().stroke(AngularGradient(gradient: Gradient(colors: Array(0...255).map { Color(hue:Double($0)/255 , saturation: 0.7, brightness: 1) }),
                                                    center: .center).opacity(0.5), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        
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
                                .padding(.bottom, 2)
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

    public var body: some View {
        switch style {
        case .compact:
            if let label = label {
                LabeledContent(content: {
                    compactView
                }, label: label)
            } else {
                compactView
            }
        case .expanded:
            expandedView
        }
     }
}

public extension SKColorPicker where Label == EmptyView {
     init(_ selection: Binding<Color>, dynamicKnobHiding: Bool = true, onDraggingChange: @escaping (Bool) -> Void = {_ in}, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.onDraggingChange = onDraggingChange
        self.label = nil
    }
}

public extension SKColorPicker where Label == Text {
    init(_ label: String, selection: Binding<Color>,
                dynamicKnobHiding: Bool = true,
                onDraggingChange: @escaping (Bool) -> Void = {_ in},
                onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.onDraggingChange = onDraggingChange
        self.label = {Text(label)}
    }
}
