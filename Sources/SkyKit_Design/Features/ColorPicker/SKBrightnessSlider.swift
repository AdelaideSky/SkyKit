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
    
    var hue: Double {
        return Double(selection.getHSB().0)
    }
    var saturation: Double {
        return Double(selection.getHSB().1)
    }
    var brightness: Double {
        return Double(selection.getHSB().2)
    }
    
    public init(_ selection: Binding<Color>) {
        self._selection = selection
        
        let hsb = selection.wrappedValue.getHSB()
              
    }
    
    public var body: some View {
        GeometryReader { geo in
            VStack {
                Wave(strength: (10*brightness), frequency: geo.size.width/7)
                    .stroke(LinearGradient(gradient: Gradient(stops: [
                        Gradient.Stop(color: .primary, location: brightness),
                        Gradient.Stop(color: .secondary.opacity(0.7), location: brightness),
                    ]), startPoint: .leading, endPoint: .trailing), lineWidth: 3)
                    .padding(.vertical, 5)
                    .clipped()
            }.overlay {
                HStack {
                    Spacer()
                        .frame(width: geo.size.width*brightness)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                        .padding(.vertical, -5)
                        .frame(width: 15, height: geo.size.height)
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
                        selection = .init(hue: hue, saturation: saturation, brightness: min(max(value.location.x, 0.01), geo.size.width)/geo.size.width+0.1)
                    }
            )
        }
    }
}
