//
//  OnHoverReader.swift
//
//
//  Created by Adélaïde Sky on 20/06/2023.
//

import SwiftUI

public struct OnHoverReader<Content: View>: View {
    @State private var isHovering = false
    let content: (Bool) -> Content
    
    public init(content: @escaping (Bool) -> Content) {
         self.content = content
    }
    
    public var body: some View {
        content(isHovering)
            .onHover(perform: { isHovering = $0 })
    }
}
