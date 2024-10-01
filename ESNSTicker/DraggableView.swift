//
//  DraggableView.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI

struct DraggableView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let panGesture = NSPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        @objc func handlePan(_ gesture: NSPanGestureRecognizer) {
            guard let window = gesture.view?.window else { return }
            let translation = gesture.translation(in: gesture.view)
            var newOrigin = window.frame.origin
            newOrigin.x += translation.x
            newOrigin.y -= translation.y
            window.setFrameOrigin(newOrigin)
            gesture.setTranslation(.zero, in: gesture.view)
        }
    }
}
