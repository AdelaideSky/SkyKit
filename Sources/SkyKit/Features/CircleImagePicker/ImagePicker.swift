//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 20/11/2023.
//

import SwiftUI
import PhotosUI

#if os(iOS)

public enum SKShapeType {
    case circle
    case square
}

public struct SKImagePicker<Content: View>: View {
    @ViewBuilder let content: () -> (Content)
    
    @State var image: UIImage? = nil
    
    @State var photoItem: PhotosPickerItem? = nil
    
    let onDismiss: (UIImage?) -> ()
    
    let shape: SKShapeType
    
    public init(shape: SKShapeType = .circle, onDismiss: @escaping (UIImage?) -> (), _ content: @escaping () -> Content) {
        self.content = content
        self.onDismiss = onDismiss
        self.shape = shape
    }
    
    public var body: some View {
        
        PhotosPicker(selection: $photoItem, matching: .images, label: content)
        .fullScreenCover(isPresented: .init(get: { !(photoItem == nil) }, set: { newValue in
            if !newValue {
                photoItem = nil
            }
        }), content: {
            Group {
                if let image {
                    CropView(image, shape: shape) { result in
                        if let result {
                            onDismiss(result)
                        }
                    }.onDisappear() {
                        self.image = nil
                        self.photoItem = nil
                    }
                } else {
                    Rectangle()
                        .fill(.background)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView()
                                .padding()
                        }
                }
            }.animation(.easeInOut, value: image)
        })
        .task(id: photoItem) {
            if let photoItem, let data = try? await photoItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
}
struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let image: UIImage
    private let onComplete: (UIImage?) -> Void
    @State var scale: CGFloat = 1.0
    @State var lastScale: CGFloat = 1.0
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    @State var circleSize: CGSize = .zero

    let maxMagnificationScale: CGFloat = 4.0
    @State var imageSizeInView: CGSize = .zero
    var maskRadius: CGFloat = 130
    
    let shape: SKShapeType
    
    init(
        _ image: UIImage,
        shape: SKShapeType,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self.image = image
        self.onComplete = onComplete
        self.shape = shape
    }
    
    var body: some View {
        VStack {
            Text("Move and scale")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .padding(.top, 80)
                .zIndex(1)
            
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .opacity(0.5)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    imageSizeInView = geometry.size
                                }
                        }
                    )
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .mask(
                        Group {
                            switch shape {
                            case .circle:
                                Circle()
                                    .frame(width: maskRadius * 2, height: maskRadius * 2)
                            case .square:
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: maskRadius * 2, height: maskRadius * 2)
                                
                            }
                        }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        let maxScaleValues = calculateMagnificationGestureMaxValues()
                        
                        scale = min(max(self.scale * delta, maxScaleValues.0), maxScaleValues.1)
                        
                        let maxOffsetPoint = calculateDragGestureMax()
                        let newX = min(max(lastOffset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
                        let newY = min(max(lastOffset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
                        offset = CGSize(width: newX, height: newY)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        lastOffset = offset
                    }
                    .simultaneously(
                        with: DragGesture()
                            .onChanged { value in
                                let maxOffsetPoint = calculateDragGestureMax()
                                let newX = min(max(value.translation.width + lastOffset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
                                let newY = min(max(value.translation.height + lastOffset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
                                offset = CGSize(width: newX, height: newY)
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
            )
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.background)
                }.font(.system(size: 15))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background {
                        Capsule()
                            .foregroundStyle(.primary)
                            .opacity(0.8)
                    }
                
                Spacer()
                
                Button {
                    onComplete(crop(image))
                    dismiss()
                } label: {
                    Text("Save")
                        .foregroundStyle(.background)
                }.font(.system(size: 15))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background {
                        Capsule()
                            .foregroundStyle(.primary)
                            .opacity(0.8)
                    }
            }.padding()
            .frame(maxWidth: .infinity, alignment: .bottom)
        }.ignoresSafeArea()
        .background(.background)
    }
    func calculateDragGestureMax() -> CGPoint {
        let yLimit = ((imageSizeInView.height / 2) * scale) - maskRadius
        let xLimit = ((imageSizeInView.width / 2) * scale) - maskRadius
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    /**
     Calculates the maximum magnification values that are applied when zooming the image, so that the image can not be zoomed out of its own size.
     - Returns: A tuple (CGFloat, CGFloat) representing the minimum and maximum magnification scale values. The first value is the minimum scale at which the image can be displayed without being smaller than its own size. The second value is the preset maximum magnification scale.
     */
    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let minScale = (maskRadius * 2) / min(imageSizeInView.width, imageSizeInView.height)
        return (minScale, maxMagnificationScale)
    }
    
    /**
     Crops the image to the part that is dragged/zoomed inside the view. Cropped image will **always** be a square, no matter what mask shape is used.
     - Parameters:
     - image: The UIImage to crop
     - Returns: A cropped UIImage if the cropping operation is successful; otherwise nil.
     */
    func crop(_ image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }
        // The relation factor of the originals image width/height and the width/height of the image displayed in the view (initial)
        let factor = min((orientedImage.size.width / imageSizeInView.width), (orientedImage.size.height / imageSizeInView.height))
        let centerInOriginalImage = CGPoint(x: orientedImage.size.width / 2, y: orientedImage.size.height / 2)
        // Calculate the crop radius inside the original image which based on the mask radius
        let cropRadiusInOriginalImage = (maskRadius * factor) / scale
        // The x offset the image has by dragging
        let offsetX = offset.width * factor
        // The y offset the image has by dragging
        let offsetY = offset.height * factor
        // Calculates the x coordinate of the crop rectangle inside the original image
        let cropRectX = (centerInOriginalImage.x - cropRadiusInOriginalImage) - (offsetX / scale)
        // Calculates the y coordinate of the crop rectangle inside the original image
        let cropRectY = (centerInOriginalImage.y - cropRadiusInOriginalImage) - (offsetY / scale)
        let cropRectCoordinate = CGPoint(x: cropRectX, y: cropRectY)
        // Cropped rects dimension is twice its radius (diameter), since it's always a square it's used both for width and height
        let cropRectDimension = cropRadiusInOriginalImage * 2
        
        let cropRect = CGRect(
            x: cropRectCoordinate.x,
            y: cropRectCoordinate.y,
            width: cropRectDimension,
            height: cropRectDimension
        )
        
        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: result)
    }
}
private extension UIImage {
    /**
     A UIImage instance with corrected orientation. If the instance's orientation is already `.up`, it simply returns the original.
     - Returns: An optional UIImage that represents the correctly oriented image.
     */
    var correctlyOriented: UIImage? {
        if imageOrientation == .up { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
#endif