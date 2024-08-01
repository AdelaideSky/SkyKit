//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 04/07/2023.
//

import SwiftUI
#if os(macOS)
public struct SKRGBHexEditor: View, Equatable {
    @Binding var selection: Color
    var onSubmit: () -> Void
    var holdUpdates: Bool
    
    @State var red: Double = 0
    @State var green: Double = 0
    @State var blue: Double = 0
    
    public init(selection: Binding<Color>, holdUpdates: Bool = false, onSubmit: @escaping () -> Void) {
        self._selection = selection
        self.onSubmit = onSubmit
        self.holdUpdates = holdUpdates
    }
    @State var hex: String = ""
    
    @FocusState private var focusedField: Int?
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.selection == rhs.selection && !lhs.holdUpdates == !rhs.holdUpdates
    }
    
    public var body: some View {
        HStack {
            VStack {
                TextField("", text: .init(get: {
                    return "\(Int(red*255))"
                }, set: { newValue in
                    if let doubleValue = Double(newValue) {
                        self.selection = .init(red: doubleValue/255, green: green, blue: blue)
                        onSubmit()
                    }
                })).focused($focusedField, equals: 1)
                    .textFieldStyling()
                Text("R").font(.footnote)
                    .opacity(0.7)
            }.frame(minWidth: 35)
                .elementStyling()
                
            VStack {
                TextField("", text: .init(get: {
                    return "\(Int(green*255))"
                }, set: { newValue in
                    if let doubleValue = Double(newValue) {
                        self.selection = .init(red: red, green: doubleValue/255, blue: blue)
                        onSubmit()
                    }
                })).focused($focusedField, equals: 2)
                    .textFieldStyling()
                Text("V").font(.footnote)
                    .opacity(0.7)
            }.frame(minWidth: 35)
                .elementStyling()
                
            VStack {
                TextField("", text: .init(get: {
                    return "\(Int(blue*255))"
                }, set: { newValue in
                    if let doubleValue = Double(newValue) {
                        self.selection = .init(red: red, green: green, blue: doubleValue/255)
                        onSubmit()
                    }
                })).focused($focusedField, equals: 3)
                    .textFieldStyling()
                Text("B").font(.footnote)
                    .opacity(0.7)
            }.frame(minWidth: 35)
                .elementStyling()
            
            VStack {
                HStack(spacing: 2) {
                    Spacer(minLength: 0)
                    Text("#").italic().opacity(0.7).padding(.horizontal, 1)
                    TextField("", text: .init(get: {
                        hex.uppercased()
                    }, set: { newValue in
                        let value = newValue.replacingOccurrences(of: "#", with: "")
                        guard value.count <= 6 else {
                            hex = String(value.dropLast(newValue.count-6))
                            return
                        }
                        selection = Color(hex: value)
                        onSubmit()
                    })).multilineTextAlignment(.center)
                        .focused($focusedField, equals: 4)
                        .onSubmit {
                            hex = selection.toHex.uppercased()
                        }
                    Spacer(minLength: 0)
                }.frame(minWidth: 75, maxWidth: .infinity)
                    .textFieldStyling()
                Text("HEX").font(.footnote)
                    .opacity(0.7)
            }.textFieldStyle(.plain)
                .foregroundStyle(.secondary)
            
        }.frame(height: 40)
            .onAppear {
                DispatchQueue(label: "SKRGBHexEditorUpdate").async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusedField = nil // Remove initial focus
                    }
                    hex = selection.toHex.uppercased()
                    let rgb = selection.getRGB()
                    
                    red = rgb.0
                    green = rgb.1
                    blue = rgb.2
                }
            }
            .onChange(of: selection) { newValue in
                if !holdUpdates {
                    DispatchQueue(label: "SKRGBHexEditorUpdate").async {
                        hex = selection.toHex.uppercased()
                        let rgb = selection.getRGB()
                        red = rgb.0
                        green = rgb.1
                        blue = rgb.2
                    }
                }
            }
            .onChange(of: holdUpdates) { newValue in
                if !newValue {
                    DispatchQueue(label: "SKRGBHexEditorUpdate").async {
                        hex = selection.toHex.uppercased()
                        let rgb = selection.getRGB()
                        red = rgb.0
                        green = rgb.1
                        blue = rgb.2
                    }
                }
            }
            .disabled(holdUpdates)
            .frame(minWidth: 220)
            .padding(.trailing, 2)
    }
}

fileprivate extension View {
    func textFieldStyling() -> some View {
        self
            .padding(.horizontal, 3)
            .frame(height: 22)
            .clipped()
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.secondary)
                    .opacity(0.1)
            }
    }
    func elementStyling() -> some View {
        self
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .foregroundStyle(.secondary)
    }
}
#endif
