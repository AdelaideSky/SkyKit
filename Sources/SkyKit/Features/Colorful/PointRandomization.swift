//
//  PointRandomization.swift
//  Colorful
//
//  Created by Lakr Aream on 2021/9/19.
//

import SwiftUI
import SkyKitC
extension SKColorfulView {
    struct PointRandomization: Equatable, Hashable, Identifiable {
        var id = UUID()

        var diameter: CGFloat = 0
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0

        mutating func randomizeIn(size: CGSize) {
            let answer = SkyKitC.randomizeIn(Float(size.width), Float(size.width))
            self.diameter = CGFloat(answer.diameter)
            self.offsetX = CGFloat(answer.offsetX)
            self.offsetY = CGFloat(answer.offsetY)
        }
        
        mutating func set(from: PointRandomization) {
            diameter = from.diameter
            offsetX = from.offsetX
            offsetY = from.offsetY
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(diameter)
            hasher.combine(offsetX)
            hasher.combine(offsetY)
        }

        static func == (lhs: PointRandomization, rhs: PointRandomization) -> Bool {
            lhs.diameter == rhs.diameter &&
                lhs.offsetX == rhs.offsetX &&
                lhs.offsetY == rhs.offsetY
        }
    }
}
extension SKNuancedColorfulView {
    struct PointRandomization: Equatable, Hashable, Identifiable {
        var id = UUID()

        var diameter: CGFloat = 0
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        var variant: Variant = .normal

        mutating func randomizeIn(size: CGSize) {
            let answer = SkyKitC.randomizeIn(Float(size.width), Float(size.width))
            self.diameter = CGFloat(answer.diameter)
            self.offsetX = CGFloat(answer.offsetX)
            self.offsetY = CGFloat(answer.offsetY)
        }
        
        mutating func set(from: PointRandomization) {
            diameter = from.diameter
            offsetX = from.offsetX
            offsetY = from.offsetY
            variant = from.variant
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(diameter)
            hasher.combine(offsetX)
            hasher.combine(offsetY)
        }

        static func == (lhs: PointRandomization, rhs: PointRandomization) -> Bool {
            lhs.diameter == rhs.diameter &&
                lhs.offsetX == rhs.offsetX &&
                lhs.offsetY == rhs.offsetY
        }
        
        func nuance(_ color: Color) -> Color {
            switch self.variant {
            case .darker:
                return color.darker(0.07)
            case .dark:
                return color.darker(0.03)
            case .normal:
                return color
            case .light:
                return color.lighter(0.15)
            case .lighter:
                return color.lighter(0.25)
            }
        }
        
        init() {
            variant = Variant.allCases.randomElement()!
        }
        
        enum Variant: CaseIterable {
            case darker
            case dark
            case normal
            case light
            case lighter
        }
    }
}
