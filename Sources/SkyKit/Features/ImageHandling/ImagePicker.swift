//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 20/11/2023.
//

import SwiftUI
import PhotosUI

#if canImport(UIKit)

public enum SKShapeType {
    case circle
    case square
}

public struct SKImagePickerModifier: ViewModifier {
    let onDismiss: (UIImage?) -> ()
    
    let shape: SKShapeType
    
    @Binding var isShown: Bool
    
    @State var image: UIImage? = nil
    @State var photoItem: PhotosPickerItem? = nil
    
    @State var displayPicker: Bool = false
    @State var displayCrop: Bool = false
    
    public init(_ isShown: Binding<Bool>, onDismiss: @escaping (UIImage?) -> Void, shape: SKShapeType) {
        self.onDismiss = onDismiss
        self.shape = shape
        self._isShown = isShown
    }
    
    public func body(content: Content) -> some View {
        content
            .photosPicker(isPresented: $displayPicker, selection: $photoItem, matching: .images)
            .fullScreenCover(isPresented: $displayCrop) {
                Group {
                    if let image {
                        CropView(image, shape: shape) { result in
                            if let result {
                                onDismiss(result)
                                
                            }
                        }.onDisappear() {
                            self.image = nil
                            self.photoItem = nil
                            isShown = false
                        }
                    } else {
                        VStack {
                            Spacer()
                            ProgressView()
                                .padding(5)
                            Text("Downloading from iCloud")
                                .foregroundStyle(.secondary)
                                .font(.caption2)
                                .opacity(0.8)
                            Spacer()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThickMaterial)
                            .ignoresSafeArea()
                            .overlay {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button("Cancel", systemImage: "xmark") {
                                            displayCrop = false
                                        }.buttonStyle(.bordered)
                                            .buttonBorderShape(.circle)
                                            .labelStyle(.iconOnly)
//                                            .tint(.thinMaterial)
                                    }
                                    Spacer()
                                }.padding()
                            }
                    }
                }.animation(.easeInOut, value: image)
                    .interactiveDismissDisabled(true)
            }
            .task(id: photoItem) {
                displayPicker = false
                
                if let photoItem {
                    displayCrop = true
                    if let data = try? await photoItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        self.image = image
                    }
                }
            }
            .onChange(of: displayPicker) {
                if photoItem == nil && !displayPicker { isShown = false }
            }
            .onChange(of: isShown) {
                if isShown {
                    displayPicker = true
                }
            }
    }
}

extension View {
    @ViewBuilder
    func skImagePicker(_ isShown: Binding<Bool>, onDismiss: @escaping (UIImage?) -> Void, shape: SKShapeType = .square) -> some View {
        self
            .modifier(SKImagePickerModifier(isShown, onDismiss: onDismiss, shape: shape))
    }
}
    
public struct SKImagePicker<Content: View>: View {
    @ViewBuilder let content: () -> (Content)
    
    @State var image: UIImage? = nil
    @State var photoItem: PhotosPickerItem? = nil
    
    @State var displayPicker: Bool = false
    @State var displayCrop: Bool = false
    
    let onDismiss: (UIImage?) -> ()
    
    let shape: SKShapeType
    
    public init(shape: SKShapeType = .circle, onDismiss: @escaping (UIImage?) -> (), _ content: @escaping () -> Content) {
        self.content = content
        self.onDismiss = onDismiss
        self.shape = shape
    }
    
    public var body: some View {
        
        Button(action: {
            displayPicker = true
        }, label: {
            content()
                .foregroundStyle(.tint)
        }).buttonStyle(.plain)
            .photosPicker(isPresented: $displayPicker, selection: $photoItem, matching: .images)
            .fullScreenCover(isPresented: $displayCrop) {
                ZStack {
                    VStack {
                        Spacer()
                        ProgressView()
                            .padding(5)
                        Text("Downloading from iCloud")
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                            .opacity(0.8)
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThickMaterial)
                        .ignoresSafeArea()
                        .overlay {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button("Cancel", systemImage: "xmark") {
                                        displayCrop = false
                                    }.buttonStyle(.bordered)
//                                            .tint(.thinMaterial)
                                }
                                Spacer()
                            }.safeAreaPadding()
                        }
                    if let image {
                        CropView(image, shape: shape) { result in
                            if let result {
                                onDismiss(result)
                            }
                        }.onDisappear() {
                            self.image = nil
                            self.photoItem = nil
                        }
                    }
                }.animation(.easeInOut, value: image)
                    .interactiveDismissDisabled(true)
            }
            .task(id: photoItem) {
                displayPicker = false
                
                if let photoItem {
                    displayCrop = true
                    if let data = try? await photoItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        self.image = image
                    }
                }
            }
    }
}

extension UIImage: Identifiable {}

struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let image: UIImage
    private let onComplete: (UIImage?) -> Void
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageSizeInView: CGSize = .zero
    private let maskRadius: CGFloat = 130
    
    @State var blur: CGFloat = 10
    
    @State var timer: Timer? = nil
    
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
        NavigationView {
            VStack {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .opacity(0.7)
                        .overlay(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        imageSizeInView = geometry.size
                                        
                                        lastScale = 1
                                        let maxScaleValues = calculateMagnificationGestureMaxValues()
                                        scale = min(max(self.scale, maxScaleValues.0), maxScaleValues.1)
                                    }
                            }
                        )
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(blur == 0 ? 0 : 0.9)
                        .ignoresSafeArea()
                    
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
                                case .square:
                                    RoundedRectangle(cornerRadius: 10)
                                }
                            }.frame(width: maskRadius * 2, height: maskRadius * 2)
                        )
                        .overlay(
                            Group {
                                switch shape {
                                case .circle:
                                    Circle()
                                        .stroke(.secondary, lineWidth: 1)
                                case .square:
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.secondary, lineWidth: 1)
                                }
                            }.frame(width: maskRadius * 2, height: maskRadius * 2)
                                .opacity(0.3)
                        )
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            timer?.invalidate()
                            timer = nil
                            withAnimation(.easeInOut(duration: 0.2)) {
                                blur = 0
                            }
                            
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
                            self.timer = .scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                                withAnimation(.easeInOut) {
                                    blur = 10
                                }
                            }
                        }
                        .simultaneously(
                            with: DragGesture()
                                .onChanged { value in
                                    timer?.invalidate()
                                    timer = nil
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        blur = 0
                                    }
                                    
                                    let maxOffsetPoint = calculateDragGestureMax()
                                    let newX = min(max(value.translation.width + lastOffset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
                                    let newY = min(max(value.translation.height + lastOffset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
                                    offset = CGSize(width: newX, height: newY)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                    self.timer = .scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                                        withAnimation(.easeInOut) {
                                            blur = 10
                                        }
                                    }
                                }
                        )
                )
                Spacer()
            }
            .background(.ultraThickMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Move and scale")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Cancel") {
                        dismiss()
                    }.buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
//                        .tint(.thinMaterial)
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text("Cancel")
//                            .foregroundStyle(.background)
//                            .padding(.vertical, 5)
//                            .frame(width: 80)
//                            .background {
//                                Capsule()
//                                    .fill(Color(uiColor: UIColor.label).opacity(0.9))
//                            }
//                    }
                    Spacer()
                    Button("Save") {
                        onComplete(crop(image))
                        dismiss()
                    }.buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
//                        .tint(.thinMaterial)
//                    Button {
//                        onComplete(crop(image))
//                        dismiss()
//                    } label: {
//                        Text("Save")
//                            .foregroundStyle(.background)
//                            .padding(.vertical, 5)
//                            .frame(width: 60)
//                            .background {
//                                Capsule()
//                                    .fill(Color(uiColor: UIColor.label).opacity(0.9))
//                            }
//                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    func calculateDragGestureMax() -> CGPoint {
        let yLimit = ((imageSizeInView.height / 2) * scale) - maskRadius
        let xLimit = ((imageSizeInView.width / 2) * scale) - maskRadius
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let minScale = (maskRadius * 2) / min(imageSizeInView.width, imageSizeInView.height)
        return (minScale, 4.0) // Assuming maxMagnificationScale is always 4.0
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
