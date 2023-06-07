//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 03/06/2023.
//
#if os(macOS)
import Foundation
import AppKit
import SwiftUI

public struct SKWindow {
    
    public struct SKWindowStyle {
        var backgroundColor: NSColor?
        var animationBehaviour: NSWindow.AnimationBehavior?
        var collectionBehavior: NSWindow.CollectionBehavior?
        var canHide: Bool?
        var hasShadow: Bool?
        var alphaValue: CGFloat?
        var titleVisibility: NSWindow.TitleVisibility?
        var titlebarAppearsTransparent: Bool?
        var styleMask: NSWindow.StyleMask?
        var level: NSWindow.Level?
        var canBecomeVisibleWithoutLogin: Bool?
        var removeTitleBar: Bool?
        var customAction: ((NSWindow) -> Void)?
    }
//    public func new(_ identifier: String) {
//
//    }
    
    public static func getWindow(_ identifier: String) -> NSWindow? {
        return NSApplication.shared.windows.first { $0.identifier?.rawValue == identifier }
    }
    
    public static func applyStyle(_ identifier: String, style: SKWindowStyle) {
        if let window = getWindow(identifier) {
            if let backgroundColor = style.backgroundColor {
                window.backgroundColor = backgroundColor
                if backgroundColor == .clear {
                    window.isOpaque = false
                }
            }
            if let animationBehaviour = style.animationBehaviour {
                window.animationBehavior = animationBehaviour
            }
            if let collectionBehaviour = style.collectionBehavior {
                window.collectionBehavior = collectionBehaviour
            }
            if let canHide = style.canHide {
                window.canHide = canHide
            }
            if let hasShadow = style.hasShadow {
                window.hasShadow = hasShadow
            }
            if let alphaValue = style.alphaValue {
                window.alphaValue = alphaValue
            }
            if let titleVisibility = style.titleVisibility {
                window.titleVisibility = titleVisibility
            }
            if let titlebartransparent = style.titlebarAppearsTransparent {
                window.titlebarAppearsTransparent = titlebartransparent
            }
            if let styleMask = style.styleMask {
                window.styleMask = styleMask
            }
            if let level = style.level {
                window.level = level
            }
            if let canBecomeVisibleWithoutLogin = style.canBecomeVisibleWithoutLogin {
                window.canBecomeVisibleWithoutLogin = canBecomeVisibleWithoutLogin
            }
            if style.removeTitleBar == true {
                window.titleVisibility = .hidden
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
            if style.customAction != nil {
                style.customAction!(window)
            }
        } else {
            print("no window")
        }
    }
}
struct WindowStyle: ViewModifier {
    var style: SKWindow.SKWindowStyle
    var id: String

    func body(content: Content) -> some View {
        content
            .task {
                SKWindow.applyStyle(id, style: style)
            }
    }
}
public extension View {
    func windowStyle(_ style: SKWindow.SKWindowStyle, id: String) -> some View {
        modifier(WindowStyle(style: style, id: id))
    }
}

#endif
