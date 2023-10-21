//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 09/10/2023.
//

import Foundation
import SwiftUI
import Charts

extension Array where Element: Hashable {
    var uniqued: Self {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
    
    var unorderedUniqued: Self {
        let result = Set(self)
        
        return Array(result)
    }
}

public struct SKPieChartData<Value: StringProtocol & Plottable>: ChartData {
    public var id: Int {
        timestamp.hashValue
    }
    
    public var timestamp: Date = .now
    
    public var categories: [Value] = [["One", "Two", "Three", "Four", "Five", "Six"].randomElement() ?? ""]
    
    public init() { }
    
    public init(_ categories: [Value], timestamp: Date = .now) {
        self.categories = categories
        self.timestamp = timestamp
    }
}
public class SKPieChartTransformedData<Value: StringProtocol & Plottable>: Identifiable {
    public var id: Int = 0
    
    public let value: Value
    public var count: Int = 0
    public var range: ClosedRange<Int> = 0...0
    
    init(value: Value, count: Int, range: ClosedRange<Int>) {
        self.value = value
        self.id = value.hash
        self.count = count
        self.range = range
    }
    
}
public struct SKPieChart<Value: StringProtocol & Plottable, 
                        CenterContent: View,
                        SmallContent: View,
                        ContentLabel: View>: ChartRepresentable, View {
    public typealias TransformedData = SKPieChartTransformedData<Value>
    public let id: UUID
    let title: String
        
    private let sourceData: [SKPieChartData<Value>]
    private var data: [TransformedData]
    
    public var label: ContentLabel
    @ViewBuilder let centerView: (TransformedData?, TransformedData?) -> CenterContent?
    @ViewBuilder let smallContent: (TransformedData?) -> SmallContent?
    
    public var body: some View {
        NavigationLink(destination: {fullRepresentation}) {
            smallRepresentation.padding()
        }.buttonStyle(.plain)
    }
    
    private var mostPresent: TransformedData? {
        data.sorted(by: { $0.count > $1.count}).first
    }
    
    @State private var selection: Int? = nil
    
    private var selectedItem: TransformedData? {
        data.first(where: { $0.range.contains(selection ?? -1) })
    }
    
    public var smallRepresentation: some View {
        GroupBox(content: {
            HStack {
                smallContent(mostPresent)
                Spacer()
                Chart(data) { element in
                    SectorMark(
                        angle: .value("Value", element.count),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    ).foregroundStyle(by: .value("Name", element.value))
                        .cornerRadius(5)
                        .opacity(element.value == mostPresent?.value ? 1 : 0.3)
                }.chartLegend(.hidden)
                    .aspectRatio(1, contentMode: .fit)
            }
        }, label: {
            HStack {
                label
                Spacer()
                Group {
                    Text("Last 5 minutes")
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .bold()
                }.font(.caption)
                    .foregroundStyle(.secondary)
            }
        }).frame(height: 150)
    }
    public var mediumRepresentation: some View {
        VStack {}
    }
    public var fullRepresentation: some View {
        VStack {
            Chart(data) { element in
                SectorMark(
                    angle: .value("Value", element.count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                ).foregroundStyle(by: .value("Name", element.value))
                    .cornerRadius(5)
                    .opacity(selectedItem != nil ? element.value == selectedItem?.value ? 1 : 0.3 : 1)
            }.chartAngleSelection(value: $selection)
                .animation(.easeInOut(duration: 0.2), value: selection)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        centerView(selectedItem, mostPresent)
                            .frame(width: frame.width*0.618, height: frame.height*0.618)
                        .position(x: frame.midX, y: frame.midY)
                    }
            }
        }.navigationTitle(title)
    }
    
    public init(id: UUID = UUID(),
                _ title: String,
                data: [SKPieChartData<Value>],
                label: ContentLabel,
                @ViewBuilder centerView: @escaping (TransformedData?, TransformedData?) -> CenterContent? = { _, _ in nil },
                @ViewBuilder smallContent: @escaping (TransformedData?) -> SmallContent? = { _ in nil }) {
        self.id = id
        self.sourceData = data
        self.label = label
        
        var answer: [TransformedData] = []
        
        
        for category in sourceData.map { $0.categories }.flatMap {$0}.unorderedUniqued {
            let count = sourceData.filter({ $0.categories.contains(category)}).count
            answer.append(.init(value: category, count: count, range: 0...1))
        }
        
        var lastIndex: Int = 0
        self.data = answer.sorted(by: {$0.count > $1.count}).map { item in
            let range = lastIndex...lastIndex+item.count
            lastIndex+=item.count
            return .init(value: item.value, count: item.count, range: range)
        }
        self.centerView = centerView
        self.smallContent = smallContent
        self.title = title
    }
    
}
