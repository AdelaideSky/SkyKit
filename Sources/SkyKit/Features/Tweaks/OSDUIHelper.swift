//
//  OSDUIHelper.swift
//
//
//  Created by Adélaïde Sky on 22/10/2023.
//
//  If you're from Apple and you want me to delete this just dm me ok LOL (even tho shouldnt be illegal bye)

import Foundation
#if os(macOS)
import AppKit

@objc public enum OSDImage: CLongLong, Hashable, CaseIterable {
    case none = 0
    case brightness = 1
//    case brightness2 = 2
    case volume = 3
    case noVolume = 4
    case volume2 = 5
    case eject = 6
//    case brightness3 = 7
//    case brightness4 = 8
    case noWifi = 9
    case noWifiWithAXmarkOnTop = 10
    case keyboardBacklit = 11
    case noKeyboardBacklit = 12
    case cantKeyboardBacklit = 13
    case cantNoKeyboardBacklit = 14
    case macProOpened = 15
    case noVol = 16
    case volume3 = 17
    case remoteNoBattery = 18 //Only works in fullscreen
    case link = 19
    case sleep = 20 //! - REALLY PUTS THE DEVICE TO SLEEP LOL - CAN BE USED IN FULLSCREEN
    case cantNoVolume = 21
    case cantVolume = 22
    case volume4 = 23
    case remoteLowBattery = 24 //Only works in fullscreen
//    case keyboardBacklit2 = 25
//    case noKeyboardBacklit2 = 26
//    case cantKeyboardBacklit2 = 27
//    case cantNoKeyboardBacklit2 = 28
}

@objc protocol OSDUIHelperProtocol {
//    "showImage:onDisplayID:priority:msecUntilFade:withText:"
    func showImage(_ img: OSDImage,
                   onDisplayID: CGDirectDisplayID,
                   priority: CUnsignedInt,
                   msecUntilFade: CUnsignedInt,
                   withText: String?)
    
    func showImage(_ img: OSDImage,
                   onDisplayID: CGDirectDisplayID,
                   priority: CUnsignedInt,
                   msecUntilFade: CUnsignedInt)
    
//    "showFullScreenImage:onDisplayID:priority:msecToAnimate:
    func showFullScreenImage(_ img: OSDImage, onDisplayID: CGDirectDisplayID, priority: CUnsignedInt, msecToAnimate: CUnsignedInt)
}

public struct SKSystemHUD {
    static func getHelper() -> OSDUIHelperProtocol {
        let connexion = NSXPCConnection(machServiceName: "com.apple.OSDUIHelper", options: [])
        connexion.remoteObjectInterface = NSXPCInterface(with: OSDUIHelperProtocol.self)
        connexion.interruptionHandler = { print("Interrupted!") }
        connexion.invalidationHandler = { print("Invalidated! Check if app isn't sandboxed!!") }
        connexion.resume()
        
        let target = connexion.remoteObjectProxyWithErrorHandler { print("Failed: \($0)") }
        guard let helper = target as? OSDUIHelperProtocol else { fatalError("Wrong type: \(target)") }
        return helper
    }
    
    public static func showImage(_ img: OSDImage,
                          onDisplayID: CGDirectDisplayID = CGMainDisplayID(),
                          priority: CUnsignedInt = 0x1f4,
                          msecUntilFade: CUnsignedInt = 2000,
                          withText: String?) {
        getHelper().showImage(img, onDisplayID: onDisplayID, priority: priority, msecUntilFade: msecUntilFade, withText: withText)
    }
    
    public static func showImage(_ img: OSDImage,
                          onDisplayID: CGDirectDisplayID = CGMainDisplayID(),
                          priority: CUnsignedInt = 0x1f4,
                          msecUntilFade: CUnsignedInt = 2000) {
        getHelper().showImage(img, onDisplayID: onDisplayID, priority: priority, msecUntilFade: msecUntilFade)
    }
    
    public static func showFullScreenImage(_ img: OSDImage,
                                    onDisplayID: CGDirectDisplayID = CGMainDisplayID(),
                                    priority: CUnsignedInt = 0x1f4,
                                    msecToAnimate: CUnsignedInt = 2000) {
        getHelper().showFullScreenImage(img, onDisplayID: onDisplayID, priority: priority, msecToAnimate: msecToAnimate)
    }
}
#endif
