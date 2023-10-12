//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 08/10/2023.
//

import Foundation
import SwiftUI

public struct ExpandableChartRepresentationView<Chart: ChartRepresentable>: View {
    var chart: Chart
    
    @State var isExpanded: Bool = false
    
    public var body: some View {
        DisclosureGroup(chart.label, isExpanded: $isExpanded) {}
        if isExpanded {
            chart.mediumRepresentation
        } else {
            chart.smallRepresentation
        }
    }
}

public struct SheetExpandableChartRepresentationView<Chart: ChartRepresentable>: View {
    var chart: Chart
    
    @State var isExpanded: Bool = false
    
    public var body: some View {
        chart.mediumRepresentation
            .onTapGesture() { isExpanded.toggle() }
            .sheet(isPresented: $isExpanded) {
                chart.fullRepresentation
            }
    }
}

public struct NavExpandableChartRepresentationView<Chart: ChartRepresentable>: View {
    var chart: Chart
    
    @State var isExpanded: Bool = false
    
    public var body: some View {
        chart.mediumRepresentation
            .onTapGesture() { isExpanded.toggle() }
            .navigationDestination(isPresented: $isExpanded, destination: { chart.fullRepresentation })
    }
}

public enum SKChartsRepresentation {
    case small
    case expandable
    case medium
    case full
    case sheetExpandable
    case navExpandable
}

public protocol ChartRepresentable: Identifiable {
    var label: LocalizedStringKey { get set }
    
    associatedtype SmallRepresentation: SwiftUI.View
    associatedtype MediumRepresentation: SwiftUI.View
    associatedtype FullRepresentation: SwiftUI.View

    @ViewBuilder @MainActor var smallRepresentation: Self.SmallRepresentation { get }
    @ViewBuilder @MainActor var mediumRepresentation: Self.MediumRepresentation { get }
    @ViewBuilder @MainActor var fullRepresentation: Self.FullRepresentation { get }
}
