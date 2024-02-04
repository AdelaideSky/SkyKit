//
//  AnimateOnAppear.swift
//
//
//  Created by Adélaïde Sky on 04/02/2024.
//

import SwiftUI

struct AnimateOnAppearModifier: ViewModifier {
    let animation: Animation
    
    @State var animate: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onAppear { animate.toggle() }
            .animation(animation) { content in
                content
                    .opacity(animate ? 1 : 0)
                
            }
    }
}

extension View {
    func appearAnimation(_ animation: Animation) -> some View {
        modifier(AnimateOnAppearModifier(animation: animation))
    }
}
