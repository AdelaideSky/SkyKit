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
        autoreleasepool {
            let path = CGMutablePath()
            
            // calculate some important values up front
            let width = Double(rect.width)
            let height = Double(rect.height)
            let midHeight = height / 2

            // start at the left center
            path.move(to: CGPoint(x: 0, y: midHeight))
            
            // Call the C function to get the wave data
            let data = wave(width, height, frequency, strength, midHeight)
            
            // Convert the C array to a Swift array for easier iteration
            let dataArray = Array(UnsafeBufferPointer(start: data, count: Int(width)))
            
            // Iterate over the data array
            for point in dataArray {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }
            
            // Free the allocated memory
            freeWave(data)
            
            return Path(path)
        }
    }
}
