//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 27/09/2023.
//

import SwiftUI

struct SKSwipeRecogniser: ViewModifier {
    var left: () -> () = {}
    var right: () -> () = {}
    var up: () -> () = {}
    var down: () -> () = {}
    
    var minDistance: CGFloat
    
    init(left: @escaping () -> Void = {}, right: @escaping () -> Void = {}, up: @escaping () -> Void = {}, down: @escaping () -> Void = {}, minimumDistance: CGFloat = 3) {
        self.left = left
        self.right = right
        self.up = up
        self.down = down
        self.minDistance = minimumDistance
    }
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: minDistance, coordinateSpace: .local)
                .onEnded { value in
                    switch(value.translation.width, value.translation.height) {
                    case (...0, -30...30):
                        left()
                    case (0..., -30...30):
                        right()
                    case (-100...100, ...0):
                        up()
                    case (-100...100, 0...):
                        down()
                    default:
                        break
                    }
                }
            )
    }
}

public extension View {
    func onSwipe(left: @escaping () -> Void = {}, right: @escaping () -> Void = {}, up: @escaping () -> Void = {}, down: @escaping () -> Void = {}, minimumDistance: CGFloat = 3) -> some View {
        self
            .modifier(SKSwipeRecogniser(left: left, right: right, up: up, down: down, minimumDistance: minimumDistance))
    }
}
