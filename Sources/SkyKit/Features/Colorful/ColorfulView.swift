//
//  ColorfulView.swift
//  Colorful
//
//  Created by Lakr Aream on 2021/9/19.
//

import SwiftUI

public struct SKColorfulView: View {
    // MARK: - PROPERTY

    @State var randomization: [PointRandomization]
    @State var size: CGSize = .init()

    var colorElements: [Color]
    private let animated: Bool
    private let animation: Animation
    private let blurRadius: CGFloat
    
    @State private var updating = true
    @State private var alreadyInitialised = false

    private let timer = Timer
        .publish(every: 5, on: .main, in: .common)
        .autoconnect()

    // MARK: - INIT

    public init(
        animated: Bool = defaultAnimated,
        animation: Animation = defaultAnimation,
        blurRadius: CGFloat = defaultBlurRadius,
        colors: [Color] = defaultColorList,
        colorCount: Int = defaultColorCount
    ) {
        assert(colors.count > 0)
        assert(colorCount > 0)
        assert(blurRadius > 0)

        self.animated = animated
        self.animation = animation
        self.blurRadius = blurRadius

        
        colorElements = colors

        var builder = [PointRandomization]()
        for _ in 0 ..< colorCount {
            builder.append(.init())
        }
        _randomization = State(initialValue: builder)
    }

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        public init(
            animated: Bool = defaultAnimated,
            animation: Animation = defaultAnimation,
            blurRadius: CGFloat = defaultBlurRadius,
            nsColors: [NSColor],
            colorCount: Int = defaultColorCount
        ) {
            self.init(
                animated: animated,
                animation: animation,
                blurRadius: blurRadius,
                colors: nsColors.map { Color($0) },
                colorCount: colorCount
            )
        }
    #endif

    #if canImport(UIKit)
        public init(
            animated: Bool = defaultAnimated,
            animation: Animation = defaultAnimation,
            blurRadius: CGFloat = defaultBlurRadius,
            uiColors: [UIColor],
            colorCount: Int = defaultColorCount
        ) {
            self.init(
                animated: animated,
                animation: animation,
                blurRadius: blurRadius,
                colors: uiColors.map { Color($0) },
                colorCount: colorCount
            )
        }
    #endif

    // MARK: - VIEW

    public var body: some View {
        GeometryReader { reader in
            ZStack {
                ForEach(obtainRangeAndUpdate(size: reader.size)) { configure in
                    Circle()
                        .foregroundColor(colorElements.randomElement()!)
                        .animation(.easeInOut(duration: 2), value: colorElements)
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
            .frame(width: reader.size.width,
                   height: reader.size.height)
        }
        .clipped()
        .blur(radius: blurRadius)
        .onReceive(timer) { _ in
            dispatchUpdate()
        }
        .onChange(of: colorElements) { _, _ in
            withAnimation(Animation
                .interpolatingSpring(stiffness: 20, damping: 1)
                .speed(0.2)) {
                randomizationStart()
            }
        }
        .onAppear {
            if !(animated && alreadyInitialised) {
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
                alreadyInitialised = true
            }
        }
    }

    // MARK: - FUNCTION

    private func dispatchUpdate() {
        if !animated { return }
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
    func mapValueToIndex(value: Int, maxValue: Int, maxIndex: Int) -> Int {
        // Ensure the value is within the range [0, maxValue]
        let clampedValue = max(0, min(value, maxValue))
        
        // Calculate the index using proportionate scaling
        let index = Int((clampedValue / maxValue) * maxIndex + 1)
        
        // Ensure the index is within the bounds [0, maxIndex]
        return max(0, min(index, maxIndex))
    }
}
