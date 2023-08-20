//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 19/08/2023.
//

import SwiftUI

@available(iOS, introduced: 16)
public struct SKSlideOverNavigaionView<Content: View, SidebarContent: View>: View {
    @Binding var isShown: Bool
    var content: () -> Content
    var sidebar: () -> SidebarContent
    
    public init(isShown: Binding<Bool>, content: @escaping () -> Content, sidebar: @escaping () -> SidebarContent) {
        self._isShown = isShown
        self.content = content
        self.sidebar = sidebar
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    sidebar()
                        .frame(width: geo.size.width*0.75)
                    Spacer()
                }
                content()
                    .frame(width: geo.size.width)
                    .shadow(radius: 5)
                    .offset(x: isShown ? geo.size.width*0.75 : 0)
            }
        }.animation(.default, value: isShown)
    }
}
