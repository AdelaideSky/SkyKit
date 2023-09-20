//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 19/08/2023.
//

import SwiftUI
#if os(iOS)
@available(iOS, introduced: 16)
public struct SKSlideOverNavigaionView<Content: View, SidebarContent: View>: View {
    @Binding var isShown: Bool
    @State private var offset: CGFloat = 0
    var content: () -> Content
    var sidebar: () -> SidebarContent
    
    public init(isShown: Binding<Bool>, content: @escaping () -> Content, sidebar: @escaping () -> SidebarContent) {
        self._isShown = isShown
        self.content = content
        self.sidebar = sidebar
    }
    
    var screenWidth = UIScreen.main.bounds.width
    @State var xOffset: CGFloat = 0
    @State var currentXOffset: CGFloat = 0
    @Environment(\.colorScheme) var scheme
    
    public var body: some View {
        GeometryReader { reader in
            ZStack() {
                HStack {
                    sidebar()
                        .frame(width: screenWidth * 0.75)
                    Spacer()
                }
                
                ZStack {
                    Color.white
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .shadow(radius: 5)
                        .offset(x: min(max(xOffset, 0), screenWidth * 0.75))
                        .animation(.default, value: xOffset)
                    content()
                        .offset(x: min(max(xOffset, 0), screenWidth * 0.75))
                        .animation(.default, value: xOffset)
                        .frame(width: screenWidth)
                    
//                    (Color.gray)
//                        .opacity(xOffset == screenWidth * 0.75 ? 0.2 : 0)
//                        .ignoresSafeArea()
//                        .offset(x: xOffset)
//                        .animation(.default, value: xOffset)
                }
                    
            }
            .onAppear {
                if isShown {
                    xOffset = screenWidth * 0.75
                    currentXOffset = xOffset
                } else {
                    xOffset = 0
                    currentXOffset = xOffset
                }
            }
            .onChange(of: isShown) { newValue in
                if newValue {
                    xOffset = screenWidth * 0.75
                } else {
                    xOffset = 0
                }
            }
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        if value.translation.width > 0 && xOffset != screenWidth * 0.75 { // left to right
                            if value.startLocation.x < screenWidth*0.25 {
                                withAnimation {
                                    xOffset = currentXOffset + value.translation.width
                                }
                            }
                        } else if value.translation.width < 0 && xOffset != 0 {
                            withAnimation {
                                xOffset = currentXOffset + value.translation.width
                            }
                        }
                    })
                    .onEnded({ value in
                        if value.translation.width > 0 { // left to right
                            if value.startLocation.x < screenWidth*0.25 {
                                withAnimation {
                                    xOffset = screenWidth * 0.75
                                    isShown = true
                                }
                            }
                        } else {
                            withAnimation {
                                xOffset = 0
                                isShown = false
                            }
                        }
                        currentXOffset = xOffset
                    })
            )
        }
            
    }
}
#endif
