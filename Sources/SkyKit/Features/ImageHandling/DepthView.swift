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
                    .shadow(color: .black, radius: 10)
                    .modifier(SKParallaxMotionModifier(manager: manager, magnitude: magnitude*3))
            }
        }.clipShape(clipShape)
            .animation(.easeInOut, value: isEnabled)
            .animation(.easeInOut, value: foreground)
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
    
    @ObservedObject var manager: SKMotionManager
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
class SKMotionManager: ObservableObject {

    var pitch: Double = 0.0
    var roll: Double = 0.0
    
    @ObservationIgnored
    private var manager: CMMotionManager

    init() {
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1/60
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
}


#endif
