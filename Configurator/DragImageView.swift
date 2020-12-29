//
//  DrageImageView.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

protocol DragImageViewDelegate {
    func didDragImage(url: URL, in dragView: DragImageView)
}
class DragImageView: NSView {

    var delegate: DragImageViewDelegate?
    let anchorIdentifier: String
    let contentIdentifier: String?
    var isFilled = false
    private var fileTypeIsOk = false
    private let acceptedFileExtensions = ["jpg", "png", "jpeg"]
    private let supportedTypes: [NSPasteboard.PasteboardType] = [.tiff, .color, .string, .fileURL, .png, .pdf, .URL, .fileContents]
    private let imageView = NSImageView()
    
    init(frame frameRect: NSRect, anchorID: String, contentIdentifier: String?) {
        self.anchorIdentifier = anchorID
        self.contentIdentifier = contentIdentifier
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).setFill()
        dirtyRect.fill()
        self.registerForDraggedTypes(Array(supportedTypes))
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy

    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = sender.draggedFileURL, let nsImage = NSImage(contentsOfFile: draggedFileURL.path) else {
            return false
        }
        imageView.frame = self.bounds
        self.addSubview(imageView)
        imageView.image = nsImage
        delegate?.didDragImage(url: draggedFileURL, in: self)
        isFilled = true
        return true
    }
    
}

extension NSDraggingInfo {
    var draggedFileURL: URL? {
        let pasteboard = draggingPasteboard
        
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options:nil) as? [URL], urls.count > 0 {
            return urls.first
        }
        return nil
    }
}
