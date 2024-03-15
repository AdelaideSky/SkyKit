//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 04/06/2023.
//
import Foundation
import SwiftUI
#if os(macOS)
public struct SKEffectsView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    public init(_ material: NSVisualEffectView.Material, blendingMode: NSVisualEffectView.BlendingMode) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    public func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
#elseif os(iOS)
struct VisualEffect: UIViewRepresentable {
    var effect: UIVisualEffect?
    let effectView = UIVisualEffectView(effect: nil)

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        effectView.effect = effect
        return effectView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { }
}
#endif
