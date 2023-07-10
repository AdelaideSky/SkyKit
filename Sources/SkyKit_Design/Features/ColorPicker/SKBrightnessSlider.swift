//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI

@available(macOS, introduced: 12)
public struct SKBrightnessSlider: View {
    @Binding var selection: Color
    @Binding var isDragging: Bool
    var onSubmit: () -> Void
        
    var scrollControls: Bool
    
    var brightness: Double {
        return Double(selection.getHSB().2)
    }
    
    public init(_ selection: Binding<Color>, isDragging: Binding<Bool> = .constant(false), scrollControls: Bool = true, onSubmit: @escaping () -> Void = {}) {
        self._selection = selection
        self._isDragging = isDragging
        self.onSubmit = onSubmit
        self.scrollControls = scrollControls
    }
    
        
    public var content: some View {
        GeometryReader { geo in
            VStack {
                Wave(strength: (10*brightness), frequency: geo.size.width/8)
                    .stroke(LinearGradient(gradient: Gradient(stops: [
                        Gradient.Stop(color: .primary.opacity(0.7), location: brightness),
                        Gradient.Stop(color: .secondary.opacity(0.5), location: brightness),
                    ]), startPoint: .leading, endPoint: .trailing), lineWidth: 4)
                    .padding(.vertical, 7)
                    .clipped()
            }.overlay {
                HStack {
                    Spacer()
                        .frame(width: geo.size.width*brightness)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .padding(.vertical, -5)
                        .frame(width: 10, height: geo.size.height-3)
                    Spacer()
                }
            }
            .background {
                SKNoiseTexture()
                    .opacity(0.1)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.vertical, 5)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        DispatchQueue(label: "SKBrightnessSliderUpdate").async {
                            let hsb = selection.getHSB()
                            let newValue = Color(hue: hsb.0, saturation: hsb.1, brightness: min(max(value.location.x, 0.01), geo.size.width)/geo.size.width)
                            DispatchQueue.main.async { selection = newValue }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        onSubmit()
                    }
            )
        }
    }
    
    public var body: some View {
        GeometryReader { geo in
            Group {
                if scrollControls {
                    BindableScrollReader(0.001...geo.size.width, value: .init(get: {
                        return .init(width: brightness*geo.size.width, height: 0)
                    }, set: { val in
                        DispatchQueue(label: "SKBrightnessSliderUpdate").async {
                            let hsb = selection.getHSB()
                            let newSelection = Color(hue: hsb.0, saturation: hsb.1, brightness: val.width/geo.size.width)
                            if newSelection != selection {
                                DispatchQueue.main.async {
                                    isDragging = true
                                    selection = newSelection
                                }
                            } else { DispatchQueue.main.async { isDragging = false } }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isDragging = false
                            }
                        }
                    }), axis: .horizontal) {
                        content
                    }
                } else {
                    content
                }
            }.gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        DispatchQueue(label: "SKBrightnessSliderUpdate").async {
                            let hsb = selection.getHSB()
                            let newValue = Color(hue: hsb.0, saturation: hsb.1, brightness: min(max(value.location.x, 0.01), geo.size.width)/geo.size.width)
                            DispatchQueue.main.async { selection = newValue }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        onSubmit()
                    }
            )
        }
    }
}
