//
//  ColorfulView.swift
//  Colorful
//
//  Created by Lakr Aream on 2021/9/19.
//
import SwiftUI

public struct SKNuancedColorfulView: View {
    @State var size: CGSize = .init()
    @State var randomization: [PointRandomization]
    
    @State private var updating = true
    @State private var initialised = false
    
    var color: Color
    private let animation: Animation
    private let animated: Bool
    private let deferLaunch: Bool
    private let blurRadius: CGFloat
    
    private var timer = Timer
        .publish(every: 5, on: .main, in: .common)
        .autoconnect()
    
    public init(
        _ basecolor: Color = .red,
        animation: Animation = Animation.interpolatingSpring(stiffness: 50, damping: 1).speed(0.05),
        blurRadius: CGFloat = 1,
        amount: Int = 32,
        animated: Bool = true,
        speed: TimeInterval = 5,
        deferLaunch: Bool = true
    ) {
        assert(blurRadius > 0)
        assert(amount > 0)

        self.animation = animation
        self.deferLaunch = deferLaunch
        self.blurRadius = blurRadius
        self.animated = animated
        
        self.color = basecolor

        var builder = [PointRandomization]()
        for _ in 0 ..< amount {
            builder.append(.init())
        }
        _randomization = State(initialValue: builder)
        
        if animated {
            self.timer = Timer
                .publish(every: speed, on: .main, in: .common)
                .autoconnect()
        } else {
            self.timer = Timer.publish(every: .greatestFiniteMagnitude, on: .init(), in: .common).autoconnect()
        }
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(getItems(geo.size)) { configure in
                    Circle()
                        .foregroundColor(configure.nuance(color))
                        .opacity(0.5)
                        .frame(
                            width: configure.diameter,
                            height: configure.diameter
                        )
                        .offset(
                            x: configure.offsetX,
                            y: configure.offsetY
                        )
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if animated && deferLaunch {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            animatedReroll(geo.size)
                        }
                    }
                }
            .clipped()
            .blur(radius: blurRadius)
            .onReceive(timer) { _ in
                animatedReroll(geo.size)
            }
            .onChange(of: color) { _ in
                withAnimation(Animation
                    .interpolatingSpring(stiffness: 20, damping: 1)
                    .speed(0.2)) {
                        safeReroll(geo.size)
                }
            }
        }
    }
    
    func animatedReroll(_ size: CGSize) {
        withAnimation(animation) {
            safeReroll(size)
        }
    }
    
    func getItems(_ size: CGSize) -> [PointRandomization] {
        guard self.size != size else { return randomization }
        DispatchQueue.main.async {
            self.size = size
            safeReroll(size, bypassCooldown: true)
        }
        return randomization
    }
    
    func reroll(_ size: CGSize) {
        var randomizationBuilder = [PointRandomization]()
        for i in 0 ..< randomization.count {
            let randomizationElement: PointRandomization = {
                var builder = PointRandomization()
                builder.randomizeIn(size: size)
                builder.id = randomization[i].id
                return builder
            }()
            randomizationBuilder.append(randomizationElement)
        }
        randomization = randomizationBuilder
    }
    
    func safeReroll(_ size: CGSize, bypassCooldown: Bool = false) {
        if bypassCooldown {
            if !(!animated && initialised) {
                reroll(size)
                initialised = true
            } else {
                reroll(size)
            }
        }
        if updating {
            guard animated else { return }
            updating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updating = true
            }
            reroll(size)
        }
    }
}

#if os(iOS)

extension UIColor {
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
}

extension UIColor {
    func lighter(_ componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(_ componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -componentDelta)
    }
}
extension UIColor {
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}

extension Color {
    func lighter(_ componentDelta: CGFloat = 0.1) -> Color {
        return Color(uiColor: UIColor(self).lighter(componentDelta))
    }
    
    func darker(_ componentDelta: CGFloat = 0.1) -> Color {
        return Color(uiColor: UIColor(self).darker(componentDelta))
    }
}
#elseif os(macOS)

extension NSColor {
    private func makeColor(componentDelta: CGFloat) -> NSColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard let nsColor = self.usingColorSpace(.deviceRGB) else {
            return .clear
        }
        
        // Extract r,g,b,a components from the
        // current UIColor
        nsColor.getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return NSColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
}

extension NSColor {
    func lighter(_ componentDelta: CGFloat = 0.1) -> NSColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(_ componentDelta: CGFloat = 0.1) -> NSColor {
        return makeColor(componentDelta: -componentDelta)
    }
}
extension NSColor {
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}

extension Color {
    func lighter(_ componentDelta: CGFloat = 0.1) -> Color {
        return Color(nsColor: NSColor(self).lighter(componentDelta))
    }
    
    func darker(_ componentDelta: CGFloat = 0.1) -> Color {
        return Color(nsColor: NSColor(self).darker(componentDelta))
    }
}

#endif
