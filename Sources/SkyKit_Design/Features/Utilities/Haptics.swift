//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 26/09/2023.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum SKVibration {
    
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    
    #if os(macOS)
    static func vibrate(with type: SKVibration) {
        print("Vibrations are not yet supported on macOS !")
    }
    #elseif canImport(UIKit)
    static func vibrate(with type: SKVibration) {
        switch type {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    #endif
    
}

