//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 22/09/2023.
//

import SwiftUI

public struct SKFlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    @State var availableWidth: CGFloat = 0
    let data: Data
    let spacing: Double
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    public init(_ data: Data, spacing: Double = 10, alignment: HorizontalAlignment = .leading, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    public var body : some View {
        SKFlexHStack(horizontaleSpacing: spacing, verticalSpacing: spacing) {
            ForEach(data, id:\.hashValue) { element in
                content(element)
            }
        }
    }
}

@available(iOS 16.0, *)
public struct SKFlexHStack: Layout {
    let horizontaleSpacing: Double
    let verticalSpacing: Double
    
    public init(horizontaleSpacing: Double, verticalSpacing: Double) {
        self.horizontaleSpacing = horizontaleSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    public init(spacing: Double) {
        self.horizontaleSpacing = spacing
        self.verticalSpacing = spacing
        
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let nbRows = Double(calculateNumberOrRow(for: subviews, with: proposal.width!))
        let minHeight = subviews.map { $0.sizeThatFits(proposal).height }.reduce(0) { max($0, $1).rounded(.up) }
        let height = nbRows * minHeight + max(nbRows - 1, 0) * verticalSpacing

        return CGSize(width: proposal.width!, height: height + 6)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let minHeight = subviews.map { $0.sizeThatFits(proposal).height }.reduce(0) { max($0, $1).rounded(.up) }
        var pt = CGPoint(x: bounds.minX, y: bounds.minY + 3)
    
        for subview in subviews.sorted(by: { $0.priority > $1.priority }) {
            let width = subview.sizeThatFits(proposal).width
        
            if (pt.x +  width) > bounds.maxX {
                pt.x = bounds.minX
                pt.y += minHeight + verticalSpacing
            }
        
            subview.place(at: pt, anchor: .topLeading, proposal: proposal)
            pt.x += width + horizontaleSpacing
        }
    }

    func calculateNumberOrRow(for subviews: Subviews, with width: Double) -> Int {
        var nbRows = 0
        var x: Double = 0
    
        for subview in subviews {
            let addedX = subview.sizeThatFits(.unspecified).width + horizontaleSpacing
        
            let isXWillGoBeyondBounds =  x + addedX > width
            if isXWillGoBeyondBounds {
                x = 0
                nbRows += 1
            }
        
            x += addedX
        }
    
        if x > 0 {
            nbRows += 1
        }
    
        return nbRows
    }
}
