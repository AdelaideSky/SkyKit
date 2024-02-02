//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 01/02/2024.
//

import SwiftUI
import CoreHaptics



public protocol HapticPattern {
    func pattern() -> CHHapticPattern?
    func play(withEngine engine: CHHapticEngine)
}

public protocol HapticTransientEvent {
    func event() -> CHHapticEvent? // Should stay transient.
}

public protocol HapticContinuousEvent {
    func event() -> CHHapticEvent? // Should stay transient.
    func sharpnessPoint() -> CHHapticParameterCurve.ControlPoint
    func intensityPoint() -> CHHapticParameterCurve.ControlPoint
    
    var relativeTime: TimeInterval { get }
}

fileprivate extension CHHapticEngine? {
    mutating func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self = try CHHapticEngine()
            self?.isAutoShutdownEnabled = true
            try self?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
}

public struct HapticModifier: ViewModifier {
    @State var engine: CHHapticEngine? = nil
    
    let patterns: () -> [HapticPattern]

    public func body(content: Content) -> some View {
        content.onAppear {
            engine.prepare()

            if let engine {
                for pattern in patterns() {
                    pattern.play(withEngine: engine)
                }
            }
        }
    }
    
}

public struct HapticTriggerModifier<Trigger: Equatable>: ViewModifier {
    
    var trigger: Trigger
    
    @State var engine: CHHapticEngine? = nil
    
    let patterns: () -> [HapticPattern]

    public func body(content: Content) -> some View {
        content.onChange(of: trigger) {
            engine.prepare()

            if let engine {
                for pattern in patterns() {
                    pattern.play(withEngine: engine)
                }
            }
        }
    }
}

public struct HapticDynamicTriggerModifier<Trigger: Equatable>: ViewModifier {
    
    var trigger: Trigger
    
    @State var engine: CHHapticEngine? = nil
    
    let patterns: (Trigger) -> [HapticPattern]

    public func body(content: Content) -> some View {
        content.onChange(of: trigger) {
            engine.prepare()

            if let engine {
                for pattern in patterns(trigger) {
                    pattern.play(withEngine: engine)
                }
            }
        }
    }
}

public extension View {
    func haptic(@HapticBuilder patterns: @escaping () -> [HapticPattern]) -> some View {
        self.modifier(HapticModifier(patterns: patterns))
    }
    
    func haptic<V: Equatable>(trigger: V, @HapticBuilder patterns: @escaping () -> [HapticPattern]) -> some View {
        self.modifier(HapticTriggerModifier(trigger: trigger, patterns: patterns))
    }
    
    func haptic<V: Equatable>(trigger: V, @HapticBuilder patterns: @escaping (V) -> [HapticPattern]) -> some View {
        self.modifier(HapticDynamicTriggerModifier(trigger: trigger, patterns: patterns))
    }
}


//MARK: - ResultBuilders
@resultBuilder
public struct HapticBuilder {
    public static func buildBlock(_ patterns: HapticPattern...) -> [HapticPattern] {
        patterns
    }
    
    public static func buildBlock(_ patterns: [HapticPattern]...) -> [HapticPattern] {
        patterns.flatMap { $0 }
    }
    
    public static func buildEither(first patterns: [HapticPattern]) -> [HapticPattern] {
        patterns
    }
    
    public static func buildEither(second patterns: [HapticPattern]) -> [HapticPattern] {
        patterns
    }
}

@resultBuilder
public struct HapticTransientEventsBuilder {
    public static func buildBlock(_ events: HapticTransientEvent...) -> [HapticTransientEvent] {
        events
    }
    
    public static func buildBlock(_ events: [HapticTransientEvent]...) -> [HapticTransientEvent] {
        events.flatMap { $0 }
    }
    
    public static func buildEither(first events: [HapticTransientEvent]) -> [HapticTransientEvent] {
        events
    }
    
    public static func buildEither(second events: [HapticTransientEvent]) -> [HapticTransientEvent] {
        events
    }
}

@resultBuilder
public struct HapticContinuousEventsBuilder {
    public static func buildBlock(_ events: HapticContinuousEvent...) -> [HapticContinuousEvent] {
        events
    }
    
    public static func buildBlock(_ events: [HapticContinuousEvent]...) -> [HapticContinuousEvent] {
        events.flatMap { $0 }
    }
    
    public static func buildEither(first events: [HapticContinuousEvent]) -> [HapticContinuousEvent] {
        events
    }
    
    public static func buildEither(second events: [HapticContinuousEvent]) -> [HapticContinuousEvent] {
        events
    }
    
}

//MARK: - Patterns

public struct TransientHapticsPattern: HapticPattern {
    var events: () -> [HapticTransientEvent]
    
    public init(@HapticTransientEventsBuilder events: @escaping () -> [HapticTransientEvent]) {
        self.events = events
    }
    
    public func pattern() -> CHHapticPattern? {
        let events = self.events().compactMap { $0.event() }
        return try? CHHapticPattern(events: events, parameters: [])
    }
    
    public func play(withEngine engine: CHHapticEngine) {
        if let pattern = pattern() {
            let player = try? engine.makePlayer(with: pattern)
            try? player?.start(atTime: CHHapticTimeImmediate)
        }
    }
}

public struct ContinuousHapticsPattern: HapticPattern {
    var events: () -> [HapticContinuousEvent]
    
    public init(@HapticContinuousEventsBuilder events: @escaping () -> [HapticContinuousEvent]) {
        self.events = events
    }
    
    public init(intensity: Float, sharpness: Float, duration: TimeInterval) {
        self.events = {
            [ContinuousHapticEvent(intensity: intensity, sharpness: sharpness, time: 0),
             ContinuousHapticEvent(intensity: intensity, sharpness: sharpness, time: duration-0.001),
             ContinuousHapticEvent(intensity: 0, sharpness: 0, time: duration)
            ]
        }
    }
    
    public func pattern() -> CHHapticPattern? {
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        let events = events().sorted(using: KeyPathComparator(\.relativeTime))

        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: events.map { $0.sharpnessPoint() },
            relativeTime: 0
        )
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: events.map { $0.intensityPoint() },
            relativeTime: 0
        )
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: events.last?.relativeTime ?? 0)

        return try? CHHapticPattern(events: [event], parameterCurves: [sharpnessCurve, intensityCurve])
    }
    
    public func play(withEngine engine: CHHapticEngine) {
        if let pattern = pattern() {
            let player = try? engine.makePlayer(with: pattern)
            try? player?.start(atTime: CHHapticTimeImmediate)
        }
    }
}

public struct FileHapticsPattern: HapticPattern {
    var file: URL?
    
    public init(_ url: URL) {
        self.file = url
    }
    
    /// Don't include extension.
    public init(named filename: String) {
        guard let path = Bundle.main.url(forResource: filename, withExtension: "ahap") else {
            return
        }
        
        self.file = path
    }
    
    public func pattern() -> CHHapticPattern? {
        if let file {
            return try? CHHapticPattern(contentsOf: file)
        } else {
            return nil
        }
    }
    
    public func play(withEngine engine: CHHapticEngine) {
        if let pattern = pattern() {
            let player = try? engine.makePlayer(with: pattern)
            try? player?.start(atTime: CHHapticTimeImmediate)
        }
    }
}

//MARK: - Events
public struct ImpactHapticEvent: HapticTransientEvent {
    let intensity: Float
    let sharpness: Float
    let relativeTime: TimeInterval
    
    public init(intensity: Float, sharpness: Float, time relativeTime: TimeInterval) {
        self.intensity = intensity
        self.sharpness = sharpness
        self.relativeTime = relativeTime
    }
    
    public init(_ style: TransientHapticEventStyle, time relativeTime: TimeInterval) {
        let values = style.parameters
        self.intensity = values.0
        self.sharpness = values.1
        self.relativeTime = relativeTime
    }
    
    public func event() -> CHHapticEvent? {
        CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        ], relativeTime: relativeTime)
    }
}

public struct ContinuousHapticEvent: HapticContinuousEvent {
    let intensity: Float
    let sharpness: Float
    public let relativeTime: TimeInterval
    
    public init(intensity: Float, sharpness: Float, time relativeTime: TimeInterval) {
        self.intensity = intensity
        self.sharpness = sharpness
        self.relativeTime = relativeTime
    }
    
    public func event() -> CHHapticEvent? {
        CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        ], relativeTime: relativeTime)
//        nil
    }
    
    public func sharpnessPoint() -> CHHapticParameterCurve.ControlPoint {
        CHHapticParameterCurve.ControlPoint(relativeTime: relativeTime, value: sharpness)
    }
    
    public func intensityPoint() -> CHHapticParameterCurve.ControlPoint {
        CHHapticParameterCurve.ControlPoint(relativeTime: relativeTime, value: intensity)
    }
}

public struct NullHapticEvent: HapticContinuousEvent, HapticTransientEvent {
    public let relativeTime: TimeInterval
    
    public init(time relativeTime: TimeInterval) {
        self.relativeTime = relativeTime
    }
    
    public func event() -> CHHapticEvent? {
        CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
        ], relativeTime: relativeTime)

    }
    
    public func sharpnessPoint() -> CHHapticParameterCurve.ControlPoint {
        CHHapticParameterCurve.ControlPoint(relativeTime: relativeTime, value: 0)
    }
    
    public func intensityPoint() -> CHHapticParameterCurve.ControlPoint {
        CHHapticParameterCurve.ControlPoint(relativeTime: relativeTime, value: 0)
    }
}


//MARK: - Styles

public enum TransientHapticEventStyle {
    case light
    case medium
    case hard
    case soft
    
    var parameters: (Float, Float) {
        switch self {
        case .light: return (0.3, 0.3)
        case .medium: return (0.7, 0.7)
        case .hard: return (1, 1)
        case .soft: return (1, 0)
        }
    }
}
