//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 16/02/2024.
//

import SwiftUI
import Observation
#if canImport(UIKit)
public struct ImageTintViewModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(ImageTintControler.self) var controler: ImageTintControler?
    
    //Its a bit hacky but it works SURPRISINGLY WELL (i mean not using any weird api or exploit bugs, its just a reasonning i never saw anywhere else and i feel it should be avoided because edges cases can be annoying, but in this case consequences will be at worst unnacurate transitions on tints or wrong tints so..) It works by looking if a parent already used the modifier by checking if a controler isnt already there, if not fallbacks to its own controler that will go in the environment of the children. This allows usecases where a child modify the image, leading to a fallback to the old image tint before updating.
    
    var data: Data
    
    @State var referenceControler: ImageTintControler = .init()
    
    public func body(content: Content) -> some View {
//        #if os(visionOS)
//        content
//        #else
        if controler != nil {
            content
                .task(id: data) {
                    await loadColor()
                }
        } else {
            content
                .environment(referenceControler)
                .tint(referenceControler.tint?.lighter(colorScheme == .dark ? 0.45 : 0.25) ?? .accentColor)
                .task(id: data) {
                    await loadColor()
                }
        }
//        #endif
    }
    
    func loadColor() async {
        if let controler {
            controler.tint = await getColor()
        } else {
            referenceControler.tint = await getColor()
        }
    }
    
    func getColor() async -> Color? {
        
        var image: UIImage? = nil
        
        if let cached = SKImageCache.shared.getImage(for: data.hashValue) {
            image = cached
        } else {
            if let uiImage = UIImage(data: data) {
                SKImageCache.shared.setImage(uiImage, for: data.hashValue)
                image = uiImage
            }
        }
        
        if let image, let uiColor = await image.averageColor {
            return Color(uiColor: uiColor)
        }
        
        return nil
    }
}

@Observable
public class ImageTintControler {
    var tint: Color? = nil
}

extension View {
    @ViewBuilder
    public func imageTint(_ data: Data?) -> some View {
        if let data {
            modifier(ImageTintViewModifier(data: data))
        } else {
            self
        }
    }
    
    @ViewBuilder
    public func imageTint(_ data: Data?, isOn: Bool) -> some View {
        if isOn, let data {
            modifier(ImageTintViewModifier(data: data))
        } else {
            self
        }
    }
}

public extension UIImage {
    var averageColor: UIColor? {
        get async {
            guard let inputImage = CIImage(image: self) else { return nil }
            let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

            guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
            guard let outputImage = filter.outputImage else { return nil }

            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext()
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

            return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
        }
    }
    
}

#endif
