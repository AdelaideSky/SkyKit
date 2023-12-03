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

public struct SKAsyncDepthPicture<S: Shape>: View {
    @Environment(\.isEnabled) var isEnabled
    
    @State var image: UIImage? = nil
    @State var foreground: UIImage? = nil
    
    var imageData: Data
    var foregroundData: Data? = nil
    
    
    var clipShape: S
    var magnitude: Double
    @State var manager = SKMotionManager()
    
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
            }
        }.clipShape(clipShape)
            .animation(.easeInOut, value: isEnabled)
            .animation(.easeInOut, value: foregroundData)
            .task(id: imageData) {
                DispatchQueue(label: "SKAsyncDepthPicture").async {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.sync { self.image = image }
                }
            }
            .task(id: foregroundData) {
                DispatchQueue(label: "SKAsyncDepthPicture").async {
                    if let foregroundData {
                        let image = UIImage(data: foregroundData)
                        DispatchQueue.main.sync { self.foreground = image }
                    } else {
                        DispatchQueue.main.sync { self.foreground = nil }
                    }
                }
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
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var manager: SKMotionManager
    var magnitude: Double
    var active: Bool = true
    
    func body(content: Content) -> some View {
        Group {
            if active {
                content
                    .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
                    .animation(.easeInOut(duration: 0.3), value: manager.roll+manager.pitch)
            } else {
                content
            }
        }
        .onAppear() {
            manager.start()
        }
        .onDisappear() {
            manager.stop()
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .inactive:
                manager.stop()
            case .background:
                manager.stop()
            case .active:
                manager.start()
            default:
                break
            }
        }
    }
}

@Observable
class SKMotionManager: ObservableObject {

    var pitch: Double = 0.0
    var roll: Double = 0.0
    
    @ObservationIgnored
    private var manager: CMMotionManager
    
    @ObservationIgnored
    private var active: Bool = true
    
    func stop() {
        self.manager.stopDeviceMotionUpdates()
    }
    
    func start() {
        self.manager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            guard error == nil else {
                print(error!)
                return
            }

            if let motionData = motionData {
                self.pitch = motionData.attitude.pitch
                self.roll = motionData.attitude.roll
            }
        }
    }

    init() {
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1/60
    }
}


#endif
