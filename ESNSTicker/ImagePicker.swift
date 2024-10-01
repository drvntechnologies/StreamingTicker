//
//  ImagePicker.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI

struct ImagePicker: NSViewControllerRepresentable {
    @Binding var image: NSImage?
    
    func makeNSViewController(context: Context) -> NSOpenPanelController {
        let controller = NSOpenPanelController()
        controller.completionHandler = { selectedImage in
            self.image = selectedImage
        }
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSOpenPanelController, context: Context) {}
}

class NSOpenPanelController: NSViewController {
    var completionHandler: ((NSImage?) -> Void)?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                self.completionHandler?(nsImage)
            } else {
                self.completionHandler?(nil)
            }
            self.dismiss(nil)
        }
    }
}
