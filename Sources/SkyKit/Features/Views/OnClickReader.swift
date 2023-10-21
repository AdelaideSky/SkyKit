//
//  OnClickReader.swift
//  
//
//  Created by Adélaïde Sky on 20/06/2023.
//

import SwiftUI

public struct OnClickReader<Content: View>: View {
    @State private var isClicking = false
    let content: (Bool) -> Content
    
    public init(content: @escaping (Bool) -> Content) {
         self.content = content
    }
    
    public var body: some View {
        content(isClicking)
            .gesture(
                LongPressGesture(minimumDuration: 0.0001)
                    .onChanged { value in
                        isClicking = value
                    }
                    .onEnded {_ in
                        isClicking = false
                    }
            )
    }
}

public struct TestThing<Content: View, OtherContent: View>: View {
    @State private var isClicking = false
    let content: (Bool) -> Content
    let otherContent: (Bool) -> OtherContent
    
    public init(content: @escaping (Bool) -> Content, otherContent: @escaping (Bool) -> OtherContent) {
        self.content = content
        self.otherContent = otherContent
    }
    
    public var body: some View {
        otherContent(isClicking)
        content(isClicking)
            .gesture(
                LongPressGesture(minimumDuration: 0.0001)
                    .onChanged { value in
                        isClicking = value
                    }
                    .onEnded {_ in
                        isClicking = false
                    }
            )
    }
}
