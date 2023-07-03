//
//  SwiftUIView.swift
//  
//
//  Created by Adélaïde Sky on 03/07/2023.
//

import SwiftUI

@available(macOS, introduced: 12.0)
protocol ScrollViewDelegateProtocol {
  /// Informs the receiver that the mouse’s scroll wheel has moved.
  func scrollWheel(with event: NSEvent);
}

/// The AppKit view that captures scroll wheel events
@available(macOS, introduced: 12.0)
fileprivate class ScrollView: NSView {
    
    fileprivate init(_ axis: Axis?) {
        super.init(frame: CGRectZero)
        self.wantedAxis = axis
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var wantedAxis: Axis?
    /// Connection to the SwiftUI view that serves as the interface to our AppKit view.
    var delegate: ScrollViewDelegateProtocol!
    /// Let the responder chain know we will respond to events.
    override var acceptsFirstResponder: Bool { true }
    /// Informs the receiver that the mouse’s scroll wheel has moved.
    override func scrollWheel(with event: NSEvent) {
        // pass the event on to the delegate
        let horizontal = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY)
        
        if (horizontal && wantedAxis == .horizontal) || (!horizontal && wantedAxis == .vertical){
            delegate.scrollWheel(with: event)
        }
        if let cgEvent: CGEvent = event.cgEvent?.copy() {
            if wantedAxis == .horizontal {
                cgEvent.setDoubleValueField(.scrollWheelEventDeltaAxis2, value: Double(event.scrollingDeltaY/8))
                
                if let nsEvent = NSEvent(cgEvent: cgEvent) {
                    self.nextResponder?.scrollWheel(with: nsEvent)
                }
            } else if wantedAxis == .vertical {

                cgEvent.setDoubleValueField(.scrollWheelEventDeltaAxis1, value: Double(event.scrollingDeltaX/8))
                if let nsEvent = NSEvent(cgEvent: cgEvent) {
                    self.nextResponder?.scrollWheel(with: nsEvent)
                }
                
            } else {
                self.nextResponder?.scrollWheel(with: event)
            }  
        }
        
    }
}

/// The SwiftUI view that serves as the interface to our AppKit view.
@available(macOS, introduced: 12.0)
fileprivate struct RepresentableScrollView: NSViewRepresentable, ScrollViewDelegateProtocol {
    /// The AppKit view our SwiftUI view manages.
    typealias NSViewType = ScrollView
    
    /// What the SwiftUI content wants us to do when the mouse's scroll wheel is moved.
    private var scrollAction: ((NSEvent) -> Void)?
    private var scrollAxis: Axis?
    
    fileprivate init(_ scrollAxis: Axis? = nil) {
        self.scrollAxis = scrollAxis
    }
    
    /// Creates the view object and configures its initial state.
    func makeNSView(context: Context) -> ScrollView {
        // Make a scroll view and become its delegate
        let view = ScrollView(scrollAxis)
        view.delegate = self;
        return view
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
    
    
    /// Informs the representable view  that the mouse’s scroll wheel has moved.
    func scrollWheel(with event: NSEvent) {
        if let scrollAction = scrollAction {
            scrollAction(event)
        }
    }
    
    /// Modifier that allows the content view to set an action in its context.
    func onScroll(_ action: @escaping (NSEvent) -> Void) -> Self {
        var newSelf = self
        newSelf.scrollAction = action
        return newSelf
    }
}

@available(macOS, introduced: 12.0)
public struct ScrollReader<Content: View>: View {
    let content: (CGSize) -> Content
    @State var offset: CGSize
    
    let bounds: ClosedRange<CGFloat>
    let invert: Bool
    let scrollDirection: Axis?
    
    public init(_ inRange: ClosedRange<CGFloat> = 0...0, axis: Axis? = nil, initialValue: CGSize = CGSize(width: 0.0, height: 0.0), invert: Bool = false, content: @escaping (CGSize) -> Content) {
        self.content = content
        self.bounds = inRange
        self._offset = .init(initialValue: initialValue)
        self.invert = invert
        self.scrollDirection = axis
    }
    
    var scrollView: some View {
        // A view that will update the offset state variable
        // when the scroll wheel moves
        RepresentableScrollView(scrollDirection)
          .onScroll { event in
              if self.bounds == 0...0 {
                  offset = CGSize(width: invert ? (offset.width - event.deltaX) : (offset.width + event.deltaX), height: invert ? (offset.height - event.deltaY) : (offset.height + event.deltaY))
              } else {
                  offset = CGSize(width: min(max(invert ? (offset.width - event.deltaX) : (offset.width + event.deltaX), bounds.lowerBound), bounds.upperBound),
                                  height: min(max(invert ? (offset.height - event.deltaY) : (offset.height + event.deltaY), bounds.lowerBound), bounds.upperBound))
              }
          }
      }
    
    public var body: some View {
        content(offset)
            .overlay {
                scrollView
            }
    }
}

@available(macOS, introduced: 12.0)
public struct BindableScrollReader<Content: View>: View {
    let content: () -> Content
    @Binding var offset: CGSize
    
    let bounds: ClosedRange<CGFloat>
    let invert: Bool
    let scrollDirection: Axis?
    
    public init(_ inRange: ClosedRange<CGFloat> = 0...0, value: Binding<CGSize>, axis: Axis? = nil, invert: Bool = false, content: @escaping () -> Content) {
        self.content = content
        self.bounds = inRange
        self._offset = value
        self.invert = invert
        self.scrollDirection = axis
    }
    
    var scrollView: some View {
        // A view that will update the offset state variable
        // when the scroll wheel moves
        RepresentableScrollView(scrollDirection)
          .onScroll { event in
              if self.bounds == 0...0 {
                  offset = CGSize(width: invert ? (offset.width - event.deltaX) : (offset.width + event.deltaX), height: invert ? (offset.height - event.deltaY) : (offset.height + event.deltaY))
              } else {
                  offset = CGSize(width: min(max(invert ? (offset.width - event.deltaX) : (offset.width + event.deltaX), bounds.lowerBound), bounds.upperBound),
                                  height: min(max(invert ? (offset.height - event.deltaY) : (offset.height + event.deltaY), bounds.lowerBound), bounds.upperBound))
              }
          }
      }
    
    public var body: some View {
        content()
            .overlay {
                scrollView
            }
    }
}
