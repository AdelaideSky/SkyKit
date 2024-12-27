//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 03/12/2023.
//

import SwiftUI
import Observation

#if canImport(UIKit)
import CoreMotion

//@MainActor
public class SKImageCache {
    public static let shared = SKImageCache()
    private var cache = NSCache<SKCacheItem, UIImage>()

    public func getImage(for hash: Int) -> UIImage? {
        return cache.object(forKey: .init(hash))
    }

    public func setImage(_ image: UIImage, for hash: Int) {
//        print("Setting for \(hash)")
        cache.setObject(image, forKey: .init(hash))
    }
    
    public func purge() {
        cache.removeAllObjects()
    }
    
    final public class SKCacheItem: NSObject {
        
        public override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? SKCacheItem else {
                return false
            }
            return id == other.id
        }
        
        public override var hash: Int {
            return id
        }
        
        let id: Int
        
        init(_ id: Int) {
            self.id = id
        }
    }
}

public struct SKAsyncPictureView<Placeholder: View>: View {
    let data: Data?
    let contentMode: ContentMode?
    let animation: Animation?
    let priority: TaskPriority
    @State var image: Image? = nil
    
    @ViewBuilder var placeholder: () -> Placeholder
    
    public init(_ data: Data?, @ViewBuilder placeholder: @escaping () -> Placeholder, contentMode: ContentMode? = .fit, animation: Animation? = nil, priority: TaskPriority = .background) {
        self.data = data
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.animation = animation
        self.priority = priority
    }
    
    public var body: some View {
        ZStack {
            if let animation {
                content
                    .animation(animation, value: image)
            } else {
                content
            }
            
        }.task(id: data, priority: priority) {
            try? await generateImage()
        }
    }
    
    @ViewBuilder
    var content: some View {
        if data != nil {
            if let image {
                if let contentMode {
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .transition(.opacity)
                } else {
                    image
                        .resizable()
                        .transition(.opacity)
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .opacity(0.8)
                        Spacer()
                    }
                    Spacer()
                }
            }
        } else {
            placeholder()
        }
    }
    
    func generateImage() async throws {
        try Task.checkCancellation()
        if let data {
            if let cached = SKImageCache.shared.getImage(for: data.hashValue) {
                image = Image(uiImage: cached)
                
//                print("found image for \(data.hashValue)")
            } else {
//                print("Didn't found image for \(data.hashValue)")
                if let uiImage = UIImage(data: data) {
                    SKImageCache.shared.setImage(uiImage, for: data.hashValue)
                    image = Image(uiImage: uiImage)
                }
            }
        }
    }
}

extension SKAsyncPictureView where Placeholder == Spacer {
    public init(_ data: Data?, contentMode: ContentMode? = .fit, animation: Animation? = nil, priority: TaskPriority = .background) {
        self.data = data
        self.placeholder = { Spacer() }
        self.contentMode = contentMode
        self.animation = animation
        self.priority = priority
    }
    
}


public struct SKDepthPicture<S: Shape>: View {
    @Environment(\.isEnabled) var isEnabled
    
    var image: UIImage
    var foreground: UIImage? = nil
    var clipShape: S
    var magnitude: Double
    
    public init(_ image: UIImage, foreground: UIImage? = nil, clipShape: S = RoundedRectangle(cornerRadius: 10), magnitude: Double = 3) {
        self.image = image
        self.foreground = foreground
        self.clipShape = clipShape
        self.magnitude = magnitude
    }
    
    public var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(isEnabled ? -10 : 0)
                .blur(radius: foreground == nil || !isEnabled ? 0 : 5)
            if let foreground, isEnabled {
                Image(uiImage: foreground)
                    .resizable()
                    .scaledToFit()
                    .padding(-5)
                    .shadow(radius: 10)
                    .modifier(SKParallaxMotionModifier(magnitude: magnitude*3))
            }
        }.clipShape(clipShape)
            .animation(.easeInOut, value: isEnabled)
            .animation(.easeInOut, value: foreground)
    }
}

public extension Data {
    
    // https://arc.net/l/quote/bxfpblgf -> From this Tech Talk session, I learned that to prevent hangs and main thread overload, you need to get async tasks off mainactor by setting the functions called async. That's what i'm doing here by doing async getters.
    var uiImage: UIImage? {
        get async {
            UIImage(data: self)
        }
    }
    
    #if canImport(UIKit)
    
    var image: Image? {
        get async {
            if let uiImage = UIImage(data: self) {
                return Image(uiImage: uiImage)
            } else {
                return nil
            }
        }
    }
    
    #endif
}

public struct SKAsyncDepthPicture<S: Shape, Placeholder: View>: View {
    @Environment(\.isEnabled) var isEnabled
    
    @ViewBuilder var placeholder: () -> Placeholder

    var imageData: Data?
    var foregroundData: Data? = nil
    
    var clipShape: S
    var magnitude: Double
    
    public init(_ image: Data?, foreground: Data? = nil, clipShape: S = RoundedRectangle(cornerRadius: 10), magnitude: Double = 3, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.imageData = image
        self.foregroundData = foreground
        self.clipShape = clipShape
        self.magnitude = magnitude
        self.placeholder = placeholder
    }
    
    public var body: some View {
        if let imageData {
            ZStack {
                SKAsyncPictureView(imageData)
                    .padding(isEnabled ? -10 : 0)
                    .blur(radius: foregroundData == nil || !isEnabled ? 0 : 3)
                if let foregroundData, isEnabled {
                    SKAsyncPictureView(foregroundData)
                        .padding(-5)
                        .shadow(radius: 15)
//                        .modifier(SKFadedEdgesViewModifier())
                        .modifier(SKParallaxMotionModifier(magnitude: magnitude*3))
                }
            }.clipShape(clipShape)
        } else {
            placeholder()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct SKFadedEdgesViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: 7)
                .shadow(radius: 10)
            content
                .mask {
                    content
                        .scaleEffect(0.98, anchor: .center)
                        .blur(radius: 7)
                }
        }
    }
}

extension SKAsyncDepthPicture where Placeholder == Spacer {
    public init(_ image: Data?, foreground: Data? = nil, clipShape: S = RoundedRectangle(cornerRadius: 10), magnitude: Double = 3) {
        self.imageData = image
        self.foregroundData = foreground
        self.clipShape = clipShape
        self.magnitude = magnitude
        self.placeholder = { Spacer() }
    }
}

public struct SKDepthToggle: View {
    @Binding var enabled: Bool
    let state: SKAnalysisState
    
    public init(_ enabled: Binding<Bool>, state: SKAnalysisState) {
        self._enabled = enabled
        self.state = state
    }
    
    public var body: some View {
        Button(action: {
            enabled.toggle()
        }, label: {
            Group {
                switch state {
                case .unavailable:
                    Text("Depth Unavailable")
                case .inProgress:
                    Text("Detecting subject...")
                case .noSubject:
                    Text("No subject")
                case .successfull:
                    Text(enabled ? "Disable Depth" : "Enable Depth")
                }
            }.animation(.easeInOut(duration: 0.2), value: state)
        }).buttonStyle(.pill)
            .foregroundStyle(.tint)
            .disabled(state != .successfull)
    }
}

struct SKParallaxMotionModifier: ViewModifier {
    @State var orientation = UIDeviceOrientation.unknown
    @State var manager: SKMotionManager = .shared

    var magnitude: Double
    var active: Bool = true
    
    // State variables for relative motion
    @State private var lastRoll: Double = 0.0
    @State private var lastPitch: Double = 0.0
    @State private var xOffset: Double = 0.0
    @State private var yOffset: Double = 0.0

    func body(content: Content) -> some View {
        Group {
            if active {
                content
                    .offset(x: xOffset, y: yOffset)
                    .animation(.easeInOut(duration: 0.3), value: xOffset + yOffset)
            } else {
                content
            }
        }
        .onAppear {
            Task {
                await manager.start()
            }
        }
        .onDisappear {
            Task {
                await manager.start()
            }
        }
        #if !os(visionOS)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        #endif
        .onChange(of: manager.roll) { updateOffsets() }
        .onChange(of: manager.pitch) { updateOffsets() }
    }

    private func updateOffsets() {
        // Calculate changes in roll and pitch
        let rollChange = manager.roll - lastRoll
        let pitchChange = manager.pitch - lastPitch

        // Update relative offsets
        xOffset += rollChange * magnitude
        yOffset += pitchChange * magnitude

        // Clamp offsets within a range
        xOffset = min(max(xOffset, -magnitude), magnitude)
        yOffset = min(max(yOffset, -magnitude), magnitude)

        // Update last roll and pitch
        lastRoll = manager.roll
        lastPitch = manager.pitch
    }
}

@Observable
public class SKMotionManager: ObservableObject {

    static public let shared: SKMotionManager = .init()

    var pitch: Double = 0.0
    var roll: Double = 0.0

    @ObservationIgnored
    private var manager = CMMotionManager()

    @ObservationIgnored
    private var active: Bool = true

    public func stop() async {
        self.manager.stopDeviceMotionUpdates()
    }

    public func start() async {
        if manager.isDeviceMotionAvailable {
            self.manager.deviceMotionUpdateInterval = 1.0 / 20.0
            self.manager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let motion = data?.attitude else { return }
                
                self?.roll = motion.roll
                self?.pitch = motion.pitch
            }
        }
    }
}

#endif
