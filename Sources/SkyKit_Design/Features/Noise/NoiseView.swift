//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 03/06/2023.
//

import SwiftUI

public struct SKNoiseTexture: View {
    
    @State var image: Image?
    
    @State var generator = SKNoiseGenerator()
    
    public init() {
        
    }
    
    private func regenerate(geo: GeometryProxy) {
        generator.image(width: Int(geo.size.width), height: Int(geo.size.height), completionHandler: { noise in
            if noise != nil {
                #if os(iOS)
                image = Image(uiImage: noise!)
                #else
                image = Image(nsImage: noise!)
                #endif
            }
        })
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                
                if image != nil {
                    image!
                        .resizable(resizingMode: .tile)
                        .scaledToFill()
                }
                
            }.onChange(of: geo.size) { _, _ in
                regenerate(geo: geo)
            }
            .onAppear {
                regenerate(geo: geo)
            }
        }
    }
}
