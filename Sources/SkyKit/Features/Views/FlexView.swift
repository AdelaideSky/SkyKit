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
    
    var alignment: HorizontalAlignment = .center
    let horizontalSpacing: Double
    let verticalSpacing: Double
    
    public init(horizontalSpacing: Double = 7, verticalSpacing: Double = 7, alignment: HorizontalAlignment = .leading) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.alignment = alignment
    }
    
    public init(spacing: Double = 7, alignment: HorizontalAlignment = .leading) {
        self.horizontalSpacing = spacing
        self.verticalSpacing = spacing
        self.alignment = alignment
        
    }

    public func makeCache(subviews: Subviews) -> Cache {
        return .init(rows: [], height: 0)
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let maxWidth = proposal.width ?? 0
        cache = caculateRows(maxWidth, proposal: proposal, subviews: subviews)
        return .init(width: maxWidth, height: cache.height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var origin = bounds.origin
        var subviews = subviews
        for row in cache.rows {
            //reset to the row beginning
            origin.x = getRowXOrigin(bounds: bounds, rowWidth: row.size.width)
            for size in row.viewsSizes {
                guard let view = subviews.popFirst() else { return }
                let width = size.width
                view.place(at: origin, proposal: .init(size))
                origin.x += width + horizontalSpacing
            }
            //move to the next row
            origin.y += row.size.height + verticalSpacing
        }
    }
    
    private func getRowXOrigin(bounds: CGRect, rowWidth: CGFloat) -> CGFloat {
        switch alignment {
        case .center: return (bounds.minX + bounds.maxX - rowWidth)/2
        case .trailing: return bounds.maxX - rowWidth
        default: return bounds.minX
        }
    }
    
    private func caculateRows(_ maxWidth: CGFloat, proposal: ProposedViewSize, subviews: Subviews) -> Cache {
        var rows : [Cache.Row] = []
        var height: CGFloat = 0
        var subviews = subviews
        while !subviews.isEmpty {
            guard let row = calculateRow(maxWidth, proposal: proposal, subviews: &subviews) else { break }
            rows.append(row)
            height += row.size.height + verticalSpacing
        }
        height -= verticalSpacing
        return .init(rows: rows, height: height)
    }
    
    
    private func calculateRow(_ maxWidth: CGFloat, proposal: ProposedViewSize, subviews: inout Subviews) -> Cache.Row? {
        var viewSizes : [CGSize] = []
        var rowHeight : CGFloat = 0
        var origin = CGRect.zero.origin
        var hasSpace : (CGSize) -> Bool = {(origin.x + $0.width + horizontalSpacing) <= maxWidth}
        //keep iterating untill row is filled
        while true {
            // if no views left
            //if view size bigger than available space
            guard
                let size = subviews.first?.sizeThatFits(proposal),
                hasSpace(size)
            else {
                let rowSize = CGSize(width: origin.x - horizontalSpacing , height: rowHeight)
                return viewSizes.isEmpty ? nil : .init(viewsSizes: viewSizes, size: rowSize)
            }
            
            _ = subviews.popFirst()
            viewSizes.append(size)
            rowHeight = rowHeight > size.height ? rowHeight : size.height
            origin.x += (size.width + horizontalSpacing)
            
        }
        
        let rowSize = CGSize(width: origin.x - horizontalSpacing , height: rowHeight)
        return viewSizes.isEmpty ? nil : .init(viewsSizes: viewSizes, size: rowSize)
    }
    
    
}


extension SKFlexHStack {
    
    public struct Cache {
        let rows: [Row]
        let height: CGFloat
        
        struct Row {
            let viewsSizes: [CGSize]
            let size : CGSize
        }
    }
    
}
