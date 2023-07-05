//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 04/07/2023.
//

import SwiftUI

public struct SKRGBHexEditor: View {
    @Binding var selection: Color
    var onSubmit: () -> Void
    
    var red: Double {
        return Double(selection.getRGB().0)
    }
    var green: Double {
        return Double(selection.getRGB().1)
    }
    var blue: Double {
        return Double(selection.getRGB().2)
    }
    
    public init(selection: Binding<Color>, onSubmit: @escaping () -> Void) {
        self._selection = selection
        self.onSubmit = onSubmit
    }
    @State var hex: String = ""
    
    @FocusState private var focusedField: Int?
    
    public var body: some View {
        HStack {
            Group {
                Group {
                    VStack {
                        TextField("", text: .init(get: {
                            return "\(Int(red*255))"
                        }, set: { newValue in
                            if let doubleValue = Double(newValue) {
                                self.selection = .init(red: doubleValue/255, green: green, blue: blue)
                            }
                        })).focused($focusedField, equals: 1)
                            .padding(3)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.secondary)
                                    .opacity(0.1)
                            }
                        Text("R").font(.footnote)
                            .opacity(0.7)
                    }
                    
                    VStack {
                        TextField("", text: .init(get: {
                            return "\(Int(green*255))"
                        }, set: { newValue in
                            if let doubleValue = Double(newValue) {
                                self.selection = .init(red: red, green: doubleValue/255, blue: blue)
                            }
                        })).focused($focusedField, equals: 2)
                            .padding(3)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.secondary)
                                    .opacity(0.1)
                            }
                        Text("V").font(.footnote)
                            .opacity(0.7)
                    }
                    
                    VStack {
                        TextField("", text: .init(get: {
                            return "\(Int(blue*255))"
                        }, set: { newValue in
                            if let doubleValue = Double(newValue) {
                                self.selection = .init(red: red, green: green, blue: doubleValue/255)
                            }
                        })).focused($focusedField, equals: 3)
                            .padding(3)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.secondary)
                                    .opacity(0.1)
                            }
                        Text("B").font(.footnote)
                            .opacity(0.7)
                    }
                }.frame(minWidth: 35)
                    .multilineTextAlignment(.center)
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
                            if let newColor = Color(hex: value) {
                                selection = newColor
                            } else {
                                hex = value
                            }
                        })).focused($focusedField, equals: 4)
                            .frame(maxWidth: 60)
                            .onSubmit {
                                hex = selection.hex.uppercased()
                            }
                            .padding(.leading, 1)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }.frame(minWidth: 75, maxWidth: .infinity)
                        .padding(3)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.secondary)
                                .opacity(0.1)
                        }
                    Text("HEX").font(.footnote)
                        .opacity(0.7)
                }
            }.textFieldStyle(.plain)
                .foregroundStyle(.secondary)
        }.frame(height: 15)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = nil // Remove initial focus
                }
                hex = selection.hex.uppercased()
            }
            .onChange(of: selection) { newValue in
                hex = selection.hex.uppercased()
            }
            .frame(minWidth: 220)
            .padding(.trailing, 2)
    }
}
