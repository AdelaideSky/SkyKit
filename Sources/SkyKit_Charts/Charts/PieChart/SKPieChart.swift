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

public struct SKPieChart<Value: StringProtocol & Plottable>: ChartRepresentable, View {
    public var id = UUID()
        
    private let sourceData: [SKPieChartData<Value>]
    private var data: [TransformedData] {
        var answer: [TransformedData] = []
        var lastIndex: Int = 0
        
        for category in sourceData.map { $0.categories }.flatMap {$0}.uniqued {
            let count = sourceData.filter({ $0.categories.contains(category)}).count
            answer.append(.init(value: category, count: count, range: lastIndex...lastIndex+count))
            lastIndex+=count
        }
        return answer
    }
    
    public var label: LocalizedStringKey
    
    public var body: some View {
        smallRepresentation
    }
    
    private var mostPresent: String {
        String(data.sorted(by: { $0.count > $1.count}).first!.value)
    }
    
    @State private var selection: Int? = nil
    
    private var selectedItem: TransformedData? {
        var precedentValue: Int = 0
        for item in data.sorted(using: KeyPathComparator(\.count)) {
            if (precedentValue...(precedentValue+item.count)).contains(selection ?? -1) {
                return item
            }
            precedentValue+=item.count
        }
        return nil
    }
    
    public var smallRepresentation: some View {
        VStack {
            Text("\(data.sorted(using: KeyPathComparator(\.count)).map { $0.count }.description)")
            Text(selectedItem?.value ?? "idfk")
            Chart(data.sorted(using: KeyPathComparator(\.count))) { element in
                SectorMark(
                    angle: .value("Value", element.count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                ).foregroundStyle(by: .value("Name", element.value))
                    .cornerRadius(5)
                    .opacity(selectedItem != nil ? element.value == selectedItem?.value ? 1 : 0.3 : 1)
            }.chartAngleSelection(value: Binding<Int?>.init(get: {
                print("get")
                return selection
            }, set: { newValue in
                print(newValue)
                selection = newValue
            })).animation(.easeInOut(duration: 0.2), value: selection)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotAreaFrame]
                        VStack {
                            if let selection = selectedItem {
                                Text(selection.value)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Text("\(selection.count) present")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            } else {
                                Text("Most Present Value")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Text(mostPresent)
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
            }
        }
    }
    public var mediumRepresentation: some View {
        VStack {}
    }
    public var fullRepresentation: some View {
        HStack {}
    }
    
    public init(id: UUID = UUID(), data: [SKPieChartData<Value>], label: LocalizedStringKey) {
        self.id = id
        self.sourceData = data
        self.label = label
    }
    
    private class TransformedData: Identifiable {
        var id: Int = 0
        
        let value: Value
        var count: Int = 0
        var range: ClosedRange<Int> = 0...0
        
        init(value: Value, count: Int, range: ClosedRange<Int>) {
            self.value = value
            self.id = value.hash
            self.count = count
            self.range = range
        }
        
    }
    
}
