//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 22/09/2023.
//

import SwiftUI

public struct SKTogglableLabelElement<Element: Equatable>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var element: Element
    @Binding var list: [Element]
    var label: String
    
    public init(_ element: Element, label: String, list: Binding<[Element]>) {
        self.element = element
        self._list = list
        self.label = label
    }
    public var body: some View {
        Group {
            if colorScheme == .dark {
                Text(label)
                    .foregroundStyle(list.contains(where: {$0 == element}) ? .black : .white)
            } else {
                Text(label)
                    .foregroundStyle(list.contains(where: {$0 == element}) ? .white : .black)
            }
        }
            .font(.system(size: 15))
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background {
                if colorScheme == .dark {
                    Capsule()
                        .fill(list.contains(where: {$0 == element}) ? .white : .gray.opacity(0.3))
                } else {
                    Capsule()
                        .fill(list.contains(where: {$0 == element}) ? .black.opacity(0.5) : .white)
                }
            }
            .onTapGesture {
                performHaptic()
                if list.contains(where: {$0 == element}) {
                    list.removeAll(where: {$0 == element})
                } else {
                    list.append(element)
                }
            }
            .opacity(0.9)
    }
}
