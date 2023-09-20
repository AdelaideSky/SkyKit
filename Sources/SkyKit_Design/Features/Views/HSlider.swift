//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 20/09/2023.
//

import SwiftUI

public struct SKHSlider: View {
    
    @Binding var value: Float // a number from 1 to 100
    
    var range: ClosedRange<CGFloat> = 0...100
    
    let image: String
    //    let channel: ChannelName
    var sliderHeight: Float = 30
    var onSubmit: () -> Void = {}
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(_ value: Binding<Float>, in range: ClosedRange<CGFloat> = 0...100, image: String = "", onSubmit: @escaping () -> Void = {}) {
        self._value = value
        self.range = range
        self.image = image
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                Capsule()
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Circle()
                    .foregroundColor(.white)
                    .frame(width: CGFloat(self.sliderHeight), height: CGFloat(self.sliderHeight*0.85), alignment: .trailing)
                    .offset(x: (CGFloat(self.value)/range.upperBound)*(geometry.size.width-CGFloat(self.sliderHeight))-2)
            }.frame(height: CGFloat(self.sliderHeight))
                .gesture(DragGesture(minimumDistance: 0.1)
                    .onChanged({ value in
                        let newValue = min(max(range.lowerBound, CGFloat(value.location.x / geometry.size.width * range.upperBound)), range.upperBound)
                        
                        if Int(newValue) != Int(self.value) {
                            if newValue == range.upperBound {NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .drawCompleted)}
                            else if newValue == range.lowerBound {NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .drawCompleted)}
                        }
                        self.value = Float(newValue)
                        
                    })
                        .onEnded() {_ in
                            onSubmit()
                        })
            
            
            
        }.frame(height: CGFloat(sliderHeight))
    }
}
