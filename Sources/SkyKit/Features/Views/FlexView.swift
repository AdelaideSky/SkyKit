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
        SKFlexHStack(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(data, id:\.hashValue) { element in
                content(element)
            }
        }
    }
}

@available(iOS 16.0, *)
public struct SKFlexHStack: Layout {
    let horizontalSpacing: Double
    let verticalSpacing: Double

    public init(horizontalSpacing: Double, verticalSpacing: Double) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    public init(spacing: Double) {
        self.horizontalSpacing = spacing
        self.verticalSpacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Use lazy evaluation to avoid unnecessary calculations
        let minHeight = subviews.lazy.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        let nbRows = calculateNumberOrRow(for: subviews.lazy.map { $0.sizeThatFits(proposal) }, with: proposal.width!)

        // Calculate height using lazy evaluation
        let height = Double(nbRows) * minHeight + max(Double(nbRows - 1), 0) * verticalSpacing

        return CGSize(width: proposal.width!, height: height + 6)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Use lazy evaluation to avoid unnecessary calculations
        let minHeight = subviews.lazy.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        var pt = CGPoint(x: bounds.minX, y: bounds.minY + 3)

        for subview in subviews.sorted(by: { $0.priority > $1.priority }) {
            let width = subview.sizeThatFits(proposal).width

            // Lazy evaluation for x position
            let isXWillGoBeyondBounds = pt.x + width > bounds.maxX
            if isXWillGoBeyondBounds {
                pt.x = bounds.minX
                pt.y += minHeight + verticalSpacing
            }

            subview.place(at: pt, anchor: .topLeading, proposal: proposal)
            pt.x += width + horizontalSpacing
        }
    }

    func calculateNumberOrRow(for subviewSizes: LazyMapSequence<Subviews, CGSize>, with width: Double) -> Int {
        var nbRows = 0
        var x: Double = 0

        for subviewSize in subviewSizes {
            let addedX = subviewSize.width + horizontalSpacing

            // Lazy evaluation for x position
            if x + addedX > width {
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
