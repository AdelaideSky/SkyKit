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
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Circle()
                    .foregroundColor(.white)
                    .frame(width: CGFloat(self.sliderHeight), height: CGFloat(self.sliderHeight*0.85), alignment: .trailing)
                    .offset(x: CGFloat((CGFloat(self.value) - range.lowerBound) / (range.upperBound - range.lowerBound)) * (geometry.size.width - CGFloat(self.sliderHeight))-2)
            }.frame(height: CGFloat(self.sliderHeight))
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        let newValue = min(max(range.lowerBound, CGFloat(Float(value.location.x / geometry.size.width * (range.upperBound - range.lowerBound))) + range.lowerBound), range.upperBound)
                                            
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
}
