//
//  ColorfulView.swift
//  Colorful
//
//  Created by Lakr Aream on 2021/9/19.
//
import SwiftUI

public struct SKNuancedColorfulView: View {
    @Environment(\.isEnabled) var isEnabled
    
    @State var size: CGSize = .init()
    @State var randomization: [PointRandomization] = []
    
    @State private var updating = true
    @State private var initialised = false
    
    var color: Color
    private let animation: Animation
    private let animated: Bool
    private let deferLaunch: Bool
    private let blurRadius: CGFloat
    private let amount: Int
    
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
        self.amount = amount

        if deferLaunch {
            var builder = [PointRandomization]()
            for _ in 0 ..< amount {
                builder.append(.init())
            }
            _randomization = State(initialValue: builder)
        }
        
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
                ForEach(randomization) { configure in
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
                            Task {
                                await animatedReroll(geo.size)
                            }
                        }
                    } else {
                        Task {
                            await setup(geo.size)
                        }
                    }
                }
            .onReceive(timer) { _ in
                Task {
                    guard isEnabled else { return }
                    await animatedReroll(geo.size)
                }
            }
            .clipped()
            .blur(radius: blurRadius)
            .task(id: color) {
                await colorChanged(geo.size)
            }
        }
    }
    func colorChanged(_ size: CGSize) async {
        if let reroll = await safeReroll(size) {
            withAnimation(Animation
                .interpolatingSpring(stiffness: 20, damping: 1)
                .speed(0.2)) {
                    self.randomization = reroll
            }
        }
    }
    func animatedReroll(_ size: CGSize) async {
        if let reroll = await safeReroll(size) {
            withAnimation(animation) {
                self.randomization = reroll
            }
        }
    }
    
//    func getItems(_ size: CGSize) -> [PointRandomization] {
//        guard self.size != size else { return randomization }
//        DispatchQueue.main.async {
//            self.size = size
//        }
//        if let reroll = safeReroll(size, bypassCooldown: true)
//        return randomization
//    }
    
    func reroll(_ size: CGSize) async -> [PointRandomization] {
        var randomizationBuilder = [PointRandomization]()
        for i in 0 ..< randomization.count {
            let randomizationElement: PointRandomization = await {
                var builder = PointRandomization()
                await builder.randomizeIn(size: size)
                builder.id = randomization[i].id
                return builder
            }()
            randomizationBuilder.append(randomizationElement)
        }
        
        return randomizationBuilder
    }
    
    func setup(_ size: CGSize) async {
        var builder = [PointRandomization]()
        for _ in 0 ..< amount {
            let randomizationElement: PointRandomization = await {
                var builder = PointRandomization()
                await builder.randomizeIn(size: size)
                return builder
            }()
            builder.append(randomizationElement)
        }
        randomization = builder
    }
    
    func safeReroll(_ size: CGSize, bypassCooldown: Bool = false) async -> [PointRandomization]? {
        guard isEnabled else { return nil }
        if bypassCooldown {
            if !(!animated && initialised) {
                let reroll = await reroll(size)
                initialised = true
                return reroll
            } else {
                return await reroll(size)
            }
        }
        if updating {
            guard animated else { return nil }
            updating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updating = true
            }
            return await reroll(size)
        }
        return nil
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
