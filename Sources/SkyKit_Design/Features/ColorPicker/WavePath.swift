//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 02/07/2023.
//

import SwiftUI
import SkyKitC

struct Wave: Shape {
    // how high our waves should be
    var strength: Double

    // how frequent our waves should be
    var frequency: Double
    
    func path(in rect: CGRect) -> Path {
        let path = CGMutablePath()
        
        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midHeight = height / 2


        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        let data = wave(width, height, frequency, strength, midHeight)
        
//        data.se

        // now count across individual horizontal points one by one
        for point in Array(UnsafeBufferPointer(start: data, count: Int(width))) {
            
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }

        return Path(path)
    }
}
