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

class SKImageCache {
    static let shared = SKImageCache()
    private var cache = NSCache<SKCacheItem, UIImage>()

    func getImage(for hash: Int) -> UIImage? {
        return cache.object(forKey: .init(hash))
    }

    func setImage(_ image: UIImage, for hash: Int) {
        print("Setting for \(hash)")
        cache.setObject(image, forKey: .init(hash))
    }
    
    func purge() {
        cache.removeAllObjects()
    }
    
    class SKCacheItem: Equatable {
        static func == (lhs: SKImageCache.SKCacheItem, rhs: SKImageCache.SKCacheItem) -> Bool {
            lhs.id == rhs.id
        }
        
        let id: Int
        
        init(_ id: Int) {
            self.id = id
        }
    }
}

struct SKAsyncPictureView: View {
    let data: Data?
    @State var image: Image? = nil
    
    init(_ data: Data?) {
        self.data = data
    }
    
    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .opacity(0.8)
            }
        }.task(id: data) {
            try? await generateImage()
        }
    }
    
    func generateImage() async throws {
        try Task.checkCancellation()
        if let data {
            if let cached = SKImageCache.shared.getImage(for: data.hashValue) {
                image = Image(uiImage: cached)
                
                print("found image for \(data.hashValue)")
            } else {
                print("Didn't found image for \(data.hashValue)")
                if let uiImage = UIImage(data: data) {
                    SKImageCache.shared.setImage(uiImage, for: data.hashValue)
                    image = Image(uiImage: uiImage)
                }
            }
        }
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
                .padding(-10)
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

public struct SKAsyncDepthPicture<S: Shape>: View {
    @Environment(\.isEnabled) var isEnabled

    var imageData: Data
    var foregroundData: Data? = nil
    
    var clipShape: S
    var magnitude: Double
    
    public init(_ image: Data, foreground: Data? = nil, clipShape: S = RoundedRectangle(cornerRadius: 10), magnitude: Double = 3) {
        self.imageData = image
        self.foregroundData = foreground
        self.clipShape = clipShape
        self.magnitude = magnitude
    }
    
    public var body: some View {
        ZStack {
            SKAsyncPictureView(imageData)
                .padding(-10)
                .blur(radius: foregroundData == nil || !isEnabled ? 0 : 3)
//                    .modifier(SKParallaxMotionModifier(magnitude: magnitude, active: isEnabled && foreground != nil))
            if let foregroundData, isEnabled {
                SKAsyncPictureView(foregroundData)
                    .padding(-5)
                    .shadow(radius: 15)
                    .modifier(SKParallaxMotionModifier(magnitude: magnitude*3))
            }
        }.clipShape(clipShape)
//            .animation(.easeInOut, value: isEnabled)
//            .animation(.easeInOut, value: foregroundData)
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
    @State var manager: SKMotionManager = .shared
    var magnitude: Double
    var active: Bool = true
    
    func body(content: Content) -> some View {
        if active {
            content
                .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
                .animation(.easeInOut(duration: 0.3), value: manager.roll+manager.pitch)
        } else {
            content
        }
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
