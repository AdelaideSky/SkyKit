//
//  PointRandomization.swift
//  Colorful
//
//  Created by Lakr Aream on 2021/9/19.
//

import SwiftUI
import Observation

extension SKColorfulView {
    struct PointRandomization: Equatable, Hashable, Identifiable {
        var id = UUID()

        var diameter: CGFloat = 0
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0

        mutating func randomizeIn(size: CGSize) {
            let decision = (size.width + size.height) / 4
            diameter = CGFloat.random(in: (decision * 0.25) ... (decision * 0.75))
            offsetX = CGFloat.random(in: -(size.width / 2) ... +(size.width / 2))
            offsetY = CGFloat.random(in: -(size.height / 2) ... +(size.height / 2))
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

class PointRandomization: Equatable, Hashable, Identifiable {
    var id = UUID()

    var diameter: CGFloat = 0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var variant: Variant = .normal

    func randomizeIn(size: CGSize) async {
        let decision = (size.width + size.height) / 4
        diameter = CGFloat.random(in: (decision * 0.25) ... (decision * 0.75))
        offsetX = CGFloat.random(in: -(size.width / 2) ... +(size.width / 2))
        offsetY = CGFloat.random(in: -(size.height / 2) ... +(size.height / 2))
        
    }
    
    func set(from: PointRandomization) {
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

@Observable
class RandomizationManager {
    var points: [PointRandomization]
    var count: Int
    
    init(count: Int) {
        self.count = count
        
        var builder = [PointRandomization]()
        for _ in 0 ..< count {
            builder.append(.init())
        }
        
        points = builder
    }
    
    func reroll(_ size: CGSize, withAnimation animation: Animation? = nil) async {
        let builder = points
        for index in 0...count-1 {
            await builder[index].randomizeIn(size: size)
        }
        
        withAnimation(animation) {
            points = builder
        }
    }
}
