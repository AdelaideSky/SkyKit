//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 04/07/2023.
//

import Foundation
import SwiftUI
import SkyKitC

public extension Color {
    var hex: String {
        autoreleasepool {
            let components = self.getRGB()
            guard let str = rgbToHexString(Double(components.0), Double(components.1), Double(components.2)) else { return "ERROR" }
            let answer = String(cString: str)
            freeHex(str)
            return answer
        }
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
