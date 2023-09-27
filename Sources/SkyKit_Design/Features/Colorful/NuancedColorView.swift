//
//  ColorfulView.swift
//  Colorful
//
//  Created by Lakr Aream on 2021/9/19.
//
import SwiftUI

public struct SKNuancedColorfulView: View {
    // MARK: - PROPERTY

    @State var randomization: [PointRandomization]
    @State var size: CGSize = .init()

    var color: Color
    private let animation: Animation
    private let animated: Bool
    private let blurRadius: CGFloat
    
    @State private var updating = true
    @State private var alreadyInitialised = false

    private var timer = Timer
        .publish(every: 5, on: .main, in: .common)
        .autoconnect()

    // MARK: - INIT

    public init(
        _ basecolor: Color = .red,
        animation: Animation = .bouncy,
        blurRadius: CGFloat = 1,
        amount: Int = 32,
        animated: Bool = true,
        speed: TimeInterval = 5
    ) {
        assert(blurRadius > 0)
        assert(amount > 0)

        self.animation = animation
        self.blurRadius = blurRadius
        self.animated = animated
        
        self.color = basecolor

        var builder = [PointRandomization]()
        for _ in 0 ..< amount {
            builder.append(.init())
        }
        _randomization = State(initialValue: builder)
        self.timer = Timer
            .publish(every: speed, on: .main, in: .common)
            .autoconnect()
    }
    // MARK: - VIEW

    public var body: some View {
        GeometryReader { reader in
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
            }
            .onChange(of: reader.size) { _ in
                if self.size == reader.size { return }
                self.size = reader.size
                
                var randomizationBuilder = [PointRandomization]()
                for i in 0 ..< randomization.count {
                    let randomizationElement: PointRandomization = {
                        var builder = PointRandomization()
                        builder.randomizeIn(size: reader.size)
                        builder.id = randomization[i].id
                        return builder
                    }()
                    randomizationBuilder.append(randomizationElement)
                }
                randomization = randomizationBuilder
            }
            .onAppear {
                if !(!animated && alreadyInitialised) {
                    issueSizeUpdate(withValue: reader.size)
                    alreadyInitialised = true
                }
            }
            .frame(width: reader.size.width,
                   height: reader.size.height)
        }
        .clipped()
        .blur(radius: blurRadius)
        .onReceive(timer) { _ in
            dispatchUpdate()
        }
        .onChange(of: color) { _ in
            withAnimation(Animation
                .interpolatingSpring(stiffness: 20, damping: 1)
                .speed(0.2)) {
                randomizationStart()
            }
        }
        
    }

    // MARK: - FUNCTION

    private func dispatchUpdate() {
        guard animated else { return }
        withAnimation(animation) {
            randomizationStart()
        }
    }

    private func randomizationStart() {
        if updating {
            updating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updating = true
            }
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
    }

    private func obtainRangeAndUpdate(size: CGSize) -> [PointRandomization] {
        issueSizeUpdate(withValue: size)
        return randomization
    }

    private func issueSizeUpdate(withValue size: CGSize) {
        if self.size == size { return }
        DispatchQueue.main.async {
            self.size = size
            self.dispatchUpdate()
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
