//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI
#if os(macOS)
public struct SKColorPicker<Label: View>: View {
    
    let selection: Binding<Color>
    
    let gradient = Gradient(colors: Array(0...255).map { Color(hue:Double($0)/255 , saturation: 0.7, brightness: 1) })
    
    @State var isDraggingBrightness: Bool = false
    @State var isDragging: Bool = false
    @State var isOpen: Bool = false
    
    var dynamicKnobHiding: Bool = true
    var onSubmit: () -> Void
    var onDraggingChange: (Bool) -> Void
    var label: (() -> Label)?
    
    var style: SKColorPickerStyle = .compact
    var optimisation: Bool = true
    
    var scrollControls = true
    
    public enum SKColorPickerStyle {
        case compact
        case expanded
    }

    public init(_ selection: Binding<Color>,
                label: @escaping () -> Label,
                dynamicKnobHiding: Bool = true,
                onDraggingChange: @escaping (Bool) -> Void = {_ in},
                onSubmit: @escaping () -> Void = {}) {
        self.selection = selection
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
    public func disableRGBHexEditorOptimisation(_ disable: Bool = true) -> SKColorPicker {
        var answer = self
        answer.optimisation = !disable
        return answer
    }
    
    public func scrollDisabled(_ disable: Bool = true) -> SKColorPicker {
        var answer = self
        answer.scrollControls = !disable
        return answer
    }
    
    @ViewBuilder
    var expandedView: some View {
        print("refresh")
        return VStack {
            GroupBox(content: {
                VStack {
                    GeometryReader { geo in
                        SKColorWheel(selection, geo: geo, showingKnob: !isDraggingBrightness, isDragging: _isDragging, scrollControls: scrollControls, onSubmit: onSubmit)
                    }.dropDestination(for: Color.self) { payload, _ in
                        selection.wrappedValue = payload.first!
                        return true
                    }
                    .frame(minHeight: 150)
                        .padding(10)
                    SKRGBHexEditor(selection: selection, holdUpdates: optimisation ? isDragging || isDraggingBrightness : false, onSubmit: onSubmit)
                        .equatable()
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
                SKBrightnessSlider(selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), scrollControls: scrollControls,  onSubmit: onSubmit)
                    .equatable()
                    .frame(height: 25)
                    .padding(10)
                    
            }
        }.frame(minWidth: 260, minHeight: 337)
            .onChange(of: isDraggingBrightness || isDragging) { newValue in
                onDraggingChange(newValue)
            }
     }
    
    @ViewBuilder
    var compactView: some View {
        Circle()
            .fill(isOpen ? .secondary : selection.wrappedValue)
            .frame(width: 15, height: 15)
//            Overlay (rainbow)
            .overlay {
                Circle()
                    .stroke(AngularGradient(gradient: gradient,
                                            center: .center).opacity(0.5), lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .id(gradient)
                
            }
//        TapGesture (open popover)
            .onTapGesture {
                isOpen.toggle()
            }
//        Drag&Drop
            .draggable(selection.wrappedValue)
            .dropDestination(for: Color.self) { payload, _ in
                selection.wrappedValue = payload.first!
                return true
            }
//        Popover
            .popover(isPresented: $isOpen, content: {
                VStack {
                    GroupBox {
                        GeometryReader { geo in
                            SKColorWheel(selection, geo: geo, showingKnob: !isDraggingBrightness, isDragging: _isDragging, scrollControls: scrollControls, onSubmit: onSubmit)
                        }.frame(width: 230, height: 210)
                        SKRGBHexEditor(selection: selection, holdUpdates: optimisation ? isDragging || isDraggingBrightness : false, onSubmit: onSubmit)
                            .equatable()
                            .frame(width: 210, height: 30)
                            .padding(.vertical, 3)
                    }
                    GroupBox {
                        SKBrightnessSlider(selection, isDragging: dynamicKnobHiding ? $isDraggingBrightness : .constant(false), scrollControls: scrollControls, onSubmit: onSubmit)
                            .equatable()
                            .frame(width: 230, height: 25)
                            .padding(4)
                    }
                }.frame(width: 260, height: 337)
                    .onChange(of: isDraggingBrightness || isDragging) { newValue in
                        onDraggingChange(newValue)
                    }
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
        self.selection = selection
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
        self.selection = selection
        self.dynamicKnobHiding = dynamicKnobHiding
        self.onSubmit = onSubmit
        self.onDraggingChange = onDraggingChange
        self.label = {Text(label)}
    }
}
#endif
