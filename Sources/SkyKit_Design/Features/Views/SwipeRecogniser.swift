//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 27/09/2023.
//

import SwiftUI

struct SKSwipeRecogniser: ViewModifier {
    enum Progress {
        case inactive
        case started
        case changed
    }
    @GestureState private var progress: Progress = .inactive
    
    var left: () -> () = {}
    var right: () -> () = {}
    var up: () -> () = {}
    var down: () -> () = {}
    
    var minDistance: CGFloat
    
    init(left: @escaping () -> Void = {}, right: @escaping () -> Void = {}, up: @escaping () -> Void = {}, down: @escaping () -> Void = {}, triggerDistance: CGFloat = 20) {
        self.left = left
        self.right = right
        self.up = up
        self.down = down
        self.minDistance = triggerDistance
    }
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: minDistance, coordinateSpace: .local)
                .updating($progress) { (value, state, transaction) in
                    switch state {
                    case .inactive:
                        state = .started
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
                    case .started:
                        state = .changed
                    default:
                        break
                    }
                }
            )
    }
}

public extension View {
    func onSwipe(left: @escaping () -> Void = {}, right: @escaping () -> Void = {}, up: @escaping () -> Void = {}, down: @escaping () -> Void = {}, triggerDistance: CGFloat = 20) -> some View {
        self
            .modifier(SKSwipeRecogniser(left: left, right: right, up: up, down: down, triggerDistance: triggerDistance))
    }
}
