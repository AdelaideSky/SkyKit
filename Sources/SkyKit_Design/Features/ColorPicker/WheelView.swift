//
//  ColorWheel.swift
//  SwiftUIColorWheel
//
//  Created by mohamed nouri on 18/4/2021.
//

import SwiftUI

struct Wheel: View {
            
    let brightness: CGFloat
    
    let gradient: Gradient
    
    init(brightness: CGFloat) {
        self.gradient = Gradient(colors: Array(0...255).map { Color(hue:Double($0)/255 , saturation: 0.7, brightness: brightness) })
        self.brightness = brightness
    }
 
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(AngularGradient(gradient:gradient, center: .center))
                .blur(radius: 20)
                .shadow(radius: 2)
            SKNoiseTexture()
                .opacity(max(0.1*brightness, 0.0001))
        }.clipShape(RoundedRectangle(cornerRadius: 7))
     }
}
