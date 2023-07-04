//
//  SKColorWheel.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI
import SkyKitC

public struct SKColorWheel: View {
    @Environment(\.self) var environment
    
    @Binding var selection: Color
    var geo: GeometryProxy
    var showingKnob: Bool = true
    var onSubmit: () -> Void
    
    @State private var knobPosition: CGPoint
    @State private var isDragging: Bool = false
    
    var brightness: Double {
        return Double(selection.getHSB().2)
    }
    
    let doublePi = CGFloat.pi*2
    
    public init(_ selection: Binding<Color>, geo: GeometryProxy, showingKnob: Bool = true, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.geo = geo
        
        let hsb = selection.wrappedValue.getHSB()
        
        let pos = calcPos(hsb.0, hsb.1, geo.size.height, geo.size.width)
        
        self._knobPosition = .init(initialValue: .init(x: pos.x, y: pos.y))
        self.showingKnob = showingKnob
        self.onSubmit = onSubmit
    }
    
    
    var y0: CGFloat {
        geo.size.height/2
    }
    var x0: CGFloat {
        geo.size.width/2
    }
    
    func r(_ pos: CGPoint, angle: CGFloat) -> CGFloat {
        return calcR(pos.x, pos.y, geo.size.width, geo.size.height, angle)
    }

    
    func angle(_ pos: CGPoint) -> CGFloat {
        return calcAngle(Double(pos.x), Double(pos.y), Double(x0), Double(y0))
    }
    
    let knobSize: CGFloat = 30
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                Wheel(brightness: brightness)
                    .overlay {
                        Group {
                            if showingKnob {
                                Circle()
                                    .stroke(isDragging ? Color.primary : Color.secondary, lineWidth: 2)
                                    .background {
                                        Circle()
                                            .foregroundStyle(.tertiary)
                                            .opacity(0.3)
                                    }
                                    .frame(width: isDragging ? 25 : 20, height: isDragging ? 25 : 20)
                                    .animation(.spring, value: isDragging)
                                    .position(knobPosition)
                            }
                        }.animation(.easeInOut, value: showingKnob)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let newPos = CGPoint(x: min(max(value.location.x, 10), geo.size.width-10), y: min(max(value.location.y, 10), geo.size.height-10))
                                let angle = angle(newPos)
                                selection = .init(hue: angle, saturation: r(newPos, angle: angle), brightness: brightness)
                            }
                            .onEnded { _ in
                                isDragging = false
                                onSubmit()
                            }
                    )
                    .onChange(of: geometry.size) { newValue in
                        updatePosition()
                    }
                    .onChange(of: selection.description) { newValue in
                        updatePosition()
                    }
            }
            
        }.frame(minHeight: 100)
    }
    
    func updatePosition() {
        autoreleasepool {
            let hsb = selection.getHSB()

            let pos = calcPos(hsb.0, hsb.1, geo.size.height, geo.size.width)
            
            
            self.knobPosition = .init(x: pos.x, y: pos.y)
        }
    }
}
