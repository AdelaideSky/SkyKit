//
//  SKColorWheel.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI
import SkyKitC

fileprivate func calcPosition(_ color: Color, size: CGSize) -> CGPoint {
    autoreleasepool {
        let hsb = color.getHSB()
        let pos = calcPos(hsb.0, hsb.1, size.height, size.width)
        return .init(x: pos.x, y: pos.y)
    }
}

public struct SKColorWheel: View {
    @Environment(\.self) var environment
    
    @Binding var selection: Color
    var geo: GeometryProxy
    var showingKnob: Bool = true
    var onSubmit: () -> Void
    var scrollControls: Bool
    
    @State private var knobPosition: CGPoint
    @State var isDragging: Bool = false
    
    var brightness: Double {
        return Double(selection.getHSB().2)
    }
    
    
    public init(_ selection: Binding<Color>, geo: GeometryProxy, showingKnob: Bool = true, isDragging: State<Bool>, scrollControls: Bool = true, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self.geo = geo
        
        self._knobPosition = .init(initialValue: calcPosition(selection.wrappedValue, size: geo.size))
        self.showingKnob = showingKnob
        self.onSubmit = onSubmit
        self._isDragging = isDragging
        self.scrollControls = scrollControls
    }
    
    
    var y0: CGFloat {
        geo.size.height/2
    }
    var x0: CGFloat {
        geo.size.width/2
    }
    
    func r(_ pos: CGPoint, angle: CGFloat) -> CGFloat {
        autoreleasepool {
            return calcR(pos.x, pos.y, geo.size.width, geo.size.height, angle)
        }
    }

    
    func angle(_ pos: CGPoint) -> CGFloat {
        autoreleasepool {
            return calcAngle(Double(pos.x), Double(pos.y), Double(x0), Double(y0))
        }
    }
    
    let knobSize: CGFloat = 30
    
    var content: some View {
        Wheel(brightness: brightness)
            .overlay {
                if showingKnob {
                    Circle()
                        .fill( Color(.tertiarySystemFill).opacity(0.3) )
                        .stroke(isDragging ? Color.primary : Color.secondary, lineWidth: 2)
                        .frame(width: isDragging ? 25 : 20, height: isDragging ? 25 : 20)
                        .animation(.spring, value: isDragging)
                        .animation(.easeInOut, value: showingKnob)
                        .position(knobPosition)
                }
            }
            .onChange(of: geo.size) { newValue, _ in
                DispatchQueue(label: "SKColorWheelUpdate").async {
                    updatePosition()
                }
            }
            .onChange(of: selection.description) { newValue, _ in
                DispatchQueue(label: "SKColorWheelUpdate").async {
                    updatePosition()
                }
            }
    }
    
    public var body: some View {
        #if os(macOS)
        if scrollControls {
            BindableScrollReader(xRange: 10...(geo.size.width-10), yRange: 10...(geo.size.height-10), value: .init(get: {
                return .init(width: knobPosition.x, height: knobPosition.y)
            }, set: { val in
                DispatchQueue(label: "SKColorWheelUpdate").async {
                    autoreleasepool {
                        let newPos = CGPoint(x: val.width, y: val.height)
                        let angle = angle(newPos)
                        let newSelection = Color(hue: angle, saturation: r(newPos, angle: angle), brightness: brightness)
                        if newSelection != selection {
                            DispatchQueue.main.async {
                                isDragging = true
                                selection = newSelection
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isDragging = false
                        }
                        
                    }
                }
            })) {
                content
                
            }.simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        DispatchQueue(label: "SKColorWheelUpdate").async {
                            autoreleasepool {
                                let newPos = CGPoint(x: min(max(value.location.x, 10), geo.size.width-10), y: min(max(value.location.y, 10), geo.size.height-10))
                                let angle = angle(newPos)
                                let newSelection = Color(hue: angle, saturation: r(newPos, angle: angle), brightness: brightness)
                                DispatchQueue.main.async {
                                    selection = newSelection
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        onSubmit()
                    }
            )
        } else {
            content.simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        DispatchQueue(label: "SKColorWheelUpdate").async {
                            autoreleasepool {
                                let newPos = CGPoint(x: min(max(value.location.x, 10), geo.size.width-10), y: min(max(value.location.y, 10), geo.size.height-10))
                                let angle = angle(newPos)
                                let newSelection = Color(hue: angle, saturation: r(newPos, angle: angle), brightness: brightness)
                                DispatchQueue.main.async {
                                    selection = newSelection
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        onSubmit()
                    }
            )
        }
        #else
        content.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    DispatchQueue(label: "SKColorWheelUpdate").async {
                        autoreleasepool {
                            let newPos = CGPoint(x: min(max(value.location.x, 10), geo.size.width-10), y: min(max(value.location.y, 10), geo.size.height-10))
                            let angle = angle(newPos)
                            let newSelection = Color(hue: angle, saturation: r(newPos, angle: angle), brightness: brightness)
                            DispatchQueue.main.async {
                                selection = newSelection
                            }
                        }
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    onSubmit()
                }
        )
        #endif
    }
    
    func updatePosition() {
        DispatchQueue(label: "SKColorWheelUpdate").async {
            let newValue = calcPosition(selection, size: geo.size)
            
            DispatchQueue.main.async {
                self.knobPosition = newValue
            }
        }
    }
}
