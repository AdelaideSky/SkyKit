//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 04/07/2023.
//

import Foundation
import SwiftUI


public extension Color {
    var hex: String {
        let components = self.getRGB()
        let rgb: Int = (Int)(components.0*255)<<16 | (Int)(components.1*255)<<8 | (Int)(components.2*255)<<0
        
        return NSString(format:"%06x", rgb) as String
    }
    
    init?(hex: String) {
        guard !hex.contains(where: { !$0.isHexDigit }) && (hex.count == 6 || hex.count == 8) else { return nil }
        
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
