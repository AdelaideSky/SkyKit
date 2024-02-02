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
import AudioToolbox
#endif

public enum SKVibration {
    
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    case oldSchool
    
    #if os(macOS)
    public static func vibrate(with type: SKVibration) {
        print("Vibrations are not yet supported on macOS !")
    }
    #elseif canImport(UIKit)
    public static func vibrate(with type: SKVibration, intensity: CGFloat = 1) {
        switch type {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: intensity)
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: intensity)
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: intensity)
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: intensity)
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: intensity)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    #endif
    
}

