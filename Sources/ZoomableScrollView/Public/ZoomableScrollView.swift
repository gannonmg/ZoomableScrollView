//
//  ZoomableScrollView 2.swift
//  ZoomableScrollView
//
//  Created by Matt Gannon on 9/2/26.
//

import SwiftUI

/// Thin wrapper around `ZoomableScrollUIView` to manage `scrollViewport` and pass it into the environment
public struct ZoomableScrollView<Content: View>: View {
    @State private var scrollViewport: CGRect = .zero

    let zoomRange: ClosedRange<CGFloat>
    let showsScrollIndicators: Bool
    let onZoomEvent: ((ZoomEvent) -> Void)?
    let zoomResetCommit: ZoomResetCommit?
    let content: () -> Content

    public init(
        zoomRange: ClosedRange<CGFloat> = 1.0...3.0,
        showsScrollIndicators: Bool = false,
        onZoomEvent: ((ZoomEvent) -> Void)? = nil,
        zoomResetCommit: ZoomResetCommit? = nil,
        content: @escaping () -> Content
    ) {
        self.zoomRange = zoomRange
        self.showsScrollIndicators = showsScrollIndicators
        self.onZoomEvent = onZoomEvent
        self.zoomResetCommit = zoomResetCommit
        self.content = content
    }

    public var body: some View {
        ZoomableScrollUIView(
            zoomRange: zoomRange,
            showsScrollIndicators: showsScrollIndicators,
            onZoomEvent: onZoomEvent,
            zoomResetCommit: zoomResetCommit,
            onViewportChange: { scrollViewport = $0 },
            content: {
                content()
                    .environment(\.scrollViewport, scrollViewport)
            }
        )
        .onChange(of: zoomResetCommit) {
            // Ensures that consumers have a fresh viewport after a zoom scale reset.
            guard let zoomResetCommit else { return }
            scrollViewport = zoomResetCommit.viewportAfterReset
        }
    }
}
