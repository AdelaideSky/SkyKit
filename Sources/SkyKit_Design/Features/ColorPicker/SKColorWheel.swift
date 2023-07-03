//
//  SKColorWheel.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

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
        let doublePi = CGFloat.pi*2
        let hDPi = hsb.0*doublePi
        
        let y2 = geo.size.height/2
        
        let sinHDPI = sin(hDPi)
        
        var w = (geo.size.height-(y2))*hsb.1
        
        let lim = atan(geo.size.height/geo.size.width)/(2*CGFloat.pi)
        
        if (hsb.0 >= lim && hsb.0 <= 0.5-lim) || (hsb.0 >= 0.5+lim && hsb.0 <= 1-lim) {
            w = abs(geo.size.height*hsb.1*0.5/sinHDPI)
            
        } else {
            w = abs(geo.size.width*hsb.1*0.5/cos(hDPi))
            
        }
        
        self._knobPosition = .init(initialValue: .init(x: (geo.size.width/2)+w*cos(hsb.0*CGFloat.pi*2), y: y2 + w * sinHDPI))
        self.showingKnob = showingKnob
        self.onSubmit = onSubmit
    }
    
    
    var y0: CGFloat {
        geo.size.height/2
    }
    var x0: CGFloat {
        geo.size.width/2
    }
    
    func r(_ pos: CGPoint) -> CGFloat {
        let angle = angle(pos)
        let lim = atan(geo.size.height/geo.size.width)/doublePi
        
        if (angle >= lim && angle <= 0.5-lim) || (angle >= 0.5+lim && angle <= 1-lim) {
            return abs((pos.y-y0)/(geo.size.height-y0))
        } else {
            return abs((pos.x-x0)/(geo.size.width-x0))
        }
    }

    
    func angle(_ pos: CGPoint) -> CGFloat {
        if pos.x == x0 {
            if y0 > pos.y {
                return 0.75
            } else {
                return 0.25
            }
        } else {
            if pos.x > x0 {
                if y0 >= pos.y {
                    return 1+(atan( (pos.y-y0) / (pos.x-x0) ) / doublePi)
                }
                return atan( (pos.y-y0) / (pos.x-x0) ) / doublePi
                
            } else if pos.x < x0 {
                return 0.5-(atan( (y0-pos.y) / (pos.x-x0) ) / doublePi)
                
            } else {
                return 0
            }
        }
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
                                selection = .init(hue: angle(newPos), saturation: r(newPos), brightness: brightness)
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
            let doublePi = CGFloat.pi*2
            let hDPi = hsb.0*doublePi
            
            let cosHDPI = cos(hDPi)
            let sinHDPI = sin(hDPi)
            
            var w = (geo.size.height-(geo.size.height/2))*hsb.1
            
            let lim = atan(geo.size.height/geo.size.width)/(2*CGFloat.pi)
            
            if (hsb.0 >= lim && hsb.0 <= 0.5-lim) || (hsb.0 >= 0.5+lim && hsb.0 <= 1-lim) {
                w = abs(geo.size.height*hsb.1*0.5/sinHDPI)
                
            } else {
                w = abs(geo.size.width*hsb.1*0.5/cosHDPI)
                
            }
            
            self.knobPosition = .init(x: (geo.size.width/2)+w*cos(hsb.0*CGFloat.pi*2), y: (geo.size.height/2) + w * sinHDPI)
        }
    }
}
