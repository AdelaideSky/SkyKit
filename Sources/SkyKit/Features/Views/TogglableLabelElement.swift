//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 22/09/2023.
//

import SwiftUI

public struct SKTogglableLabelElement<Element: Equatable>: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    
    var element: Element
    @Binding var list: [Element]
    var label: LocalizedStringKey
    
    var shouldHighlight: Bool {
        guard isEnabled else { return false }
        return list.contains(where: {$0 == element})
    }
    
    var tintColor: Color {
        if colorScheme == .dark {
            return shouldHighlight ? .white : .gray.opacity(0.3)
        } else {
            return shouldHighlight ? .black.opacity(0.5) : Color(hex: "F6F6F6")
        }
    }
    
    public init(_ element: Element, label: LocalizedStringKey, list: Binding<[Element]>) {
        self.element = element
        self._list = list
        self.label = label
    }
    
    public init(_ element: Element, label: String, list: Binding<[Element]>) {
        self.element = element
        self._list = list
        self.label = .init(label)
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                #if !os(visionOS)
                performHaptic()
                #endif
                if list.contains(where: {$0 == element}) {
                    list.removeAll(where: {$0 == element})
                } else {
                    list.append(element)
                }
            }
        }, label: {
            Group {
                if colorScheme == .dark {
                    Text(label)
                        .foregroundStyle(shouldHighlight ? .black : .white)
                } else {
                    Text(label)
                        .foregroundStyle(shouldHighlight ? .white : .black)
                }
            }
                .font(.system(size: 15))
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background {
                    if shouldHighlight {
                        Rectangle()
                            .fill(colorScheme == .dark ? .white : .black.opacity(0.5))
                    } else {
                        Rectangle()
                            .fill(.thinMaterial)
                    }
                }
                .clipShape(.capsule)
        }).buttonStyle(.plain)
            .clipShape(.capsule)
            .opacity(0.9)
            .fixedSize(horizontal: false, vertical: true)
    }
}
//Button(action: {
//    print("e")
//}, label: {
//    Group {
//        if colorScheme == .dark {
//            Text("label")
//                .foregroundStyle(.white)
//        } else {
//            Text("label")
//                .foregroundStyle(.black)
//        }
//    }
//        .font(.system(size: 15))
//        .padding(.horizontal, 13)
//        .padding(.vertical, 9)
//        .background {
//            
//            Rectangle()
//                .fill(.thinMaterial)
//        }
//        .clipShape(.capsule)
//})
//
//.buttonStyle(.plain)
////                .buttonBorderShape(.capsule)
//
//.clipShape(.capsule)
//.controlSize(.small)
//    .opacity(0.9)
