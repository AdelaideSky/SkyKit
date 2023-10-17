//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 03/06/2023.
//

#if os(macOS)
import Foundation
import AppKit

public extension SKWindow.SKWindowStyle {
    static var transparentTopPanel: Self {
        .init(
            backgroundColor: .clear,
            hasShadow: false,
            titlebarAppearsTransparent: true,
            level: .screenSaver,
            removeTitleBar: true,
            customAction: { window in
                window.styleMask.insert(.borderless)
                window.isMovableByWindowBackground = true
            }
        )
    }
    static var transparent: Self {
        .init(
            backgroundColor: .clear,
            titlebarAppearsTransparent: true
        )
    }
}
#endif
