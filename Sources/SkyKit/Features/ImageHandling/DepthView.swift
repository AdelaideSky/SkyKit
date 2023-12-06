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

public struct SKDepthPicture<S: Shape>: View {
    @Environment(\.isEnabled) var isEnabled
    
    var image: UIImage
    var foreground: UIImage? = nil
    var clipShape: S
    var magnitude: Double
    @State var manager = SKMotionManager()
    
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
                .modifier(SKParallaxMotionModifier(manager: manager, magnitude: magnitude, active: isEnabled && foreground != nil))
            if let foreground, isEnabled {
                Image(uiImage: foreground)
                    .resizable()
                    .scaledToFit()
                    .padding(-5)
                    .shadow(radius: 10)
                    .modifier(SKParallaxMotionModifier(manager: manager, magnitude: magnitude*3))
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
    
    @State var image: UIImage? = nil
    @State var foreground: UIImage? = nil
    
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
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(-10)
                    .blur(radius: foreground == nil || !isEnabled ? 0 : 3)
//                    .modifier(SKParallaxMotionModifier(magnitude: magnitude, active: isEnabled && foreground != nil))
                if let foreground, isEnabled {
                    Image(uiImage: foreground)
                        .resizable()
                        .scaledToFit()
                        .padding(-5)
                        .shadow(radius: 15)
                        .modifier(SKParallaxMotionModifier(magnitude: magnitude*3))
                }
            }
        }.clipShape(clipShape)
//            .animation(.easeInOut, value: isEnabled)
//            .animation(.easeInOut, value: foregroundData)
            .task(id: imageData) {
                self.image = await imageData.uiImage
            }
            .task(id: foregroundData) {
                foreground = await foregroundData?.uiImage
            }
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
    
    @ObservationIgnored
    private var queue = OperationQueue()
    
    public func stop() async {
        self.manager.stopDeviceMotionUpdates()
    }
    
    public func start() async {
        if manager.isDeviceMotionAvailable {
            self.manager.deviceMotionUpdateInterval = 1.0 / 30.0
            self.manager.showsDeviceMovementDisplay = true
            
            self.manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
                                                 to: self.queue, withHandler: { (data, error) in
                if let validData = data {
                    self.roll = validData.attitude.roll
                    self.pitch = validData.attitude.pitch
                }
            })
        }
    }
}


#endif
