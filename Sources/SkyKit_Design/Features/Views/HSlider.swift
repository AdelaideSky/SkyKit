//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 20/09/2023.
//

import SwiftUI

#if os(iOS)
fileprivate let performHaptic = {
    autoreleasepool {
        var feedbackgen = UISelectionFeedbackGenerator()
        feedbackgen.prepare()
        feedbackgen.selectionChanged()
    }
}
#else
fileprivate let performHaptic = { NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .drawCompleted) }
#endif

public struct SKHSlider: View {
    
    @Binding var value: Float // a number from 1 to 100
    
    var range: ClosedRange<CGFloat> = 0...100
    
    let image: String
    //    let channel: ChannelName
    var sliderHeight: Float = 40
    var onSubmit: () -> Void = {}
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(_ value: Binding<Float>, in range: ClosedRange<CGFloat> = 0...100, image: String = "", height: Float = 40, onSubmit: @escaping () -> Void = {}) {
        self._value = value
        self.range = range
        self.image = image
        self.onSubmit = onSubmit
        self.sliderHeight = height
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                Capsule()
//                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundStyle(.gray.opacity(0.5).shadow(.inner(radius: 5)))
                Circle()
                    .foregroundColor(.white)
                    .frame(width: CGFloat(self.sliderHeight), height: CGFloat(self.sliderHeight*0.85), alignment: .trailing)
                    .offset(x: offset(geometry))
                    .foregroundStyle(.primary.shadow(.drop(radius: 3)))
            }.frame(height: CGFloat(self.sliderHeight))
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        let knobHalfWidth = CGFloat(self.sliderHeight / 2)
                        let touchZoneWidth = geometry.size.width - CGFloat(self.sliderHeight)
                        
                        // Calculate newValue within the adjusted touch zone
                        let newValue = min(max(range.lowerBound, (value.location.x - knobHalfWidth) / touchZoneWidth * (range.upperBound - range.lowerBound) + range.lowerBound), range.upperBound)
                        
                        
                        
                        
                        if Int(newValue) != Int(self.value) {
                            if newValue == range.upperBound {performHaptic()}
                            else if newValue == range.lowerBound {performHaptic()}
                        }
                        self.value = Float(newValue)
                    })
                        .onEnded() {_ in
                            onSubmit()
                        })
            
            
            
        }.frame(height: CGFloat(sliderHeight))
    }
    public func offset(_ geo: GeometryProxy) -> CGFloat {
        var answer = CGFloat((CGFloat(self.value) - range.lowerBound) / (range.upperBound - range.lowerBound)) * (geo.size.width - CGFloat(self.sliderHeight))
        
        answer = max(min(answer-CGFloat(self.sliderHeight)*0.05, geo.size.width-(CGFloat(self.sliderHeight)*1.1)), -CGFloat(self.sliderHeight)*0.05)
        return answer
    }
}
