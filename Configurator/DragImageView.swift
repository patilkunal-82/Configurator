//
//  DrageImageView.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

protocol DragImageViewDelegate {
    func didDragImage(url: URL)
}
class DragImageView: NSView {

    var delegate: DragImageViewDelegate?
    private var fileTypeIsOk = false
    private let acceptedFileExtensions = ["jpg", "png", "jpeg"]
    private let supportedTypes: [NSPasteboard.PasteboardType] = [.tiff, .color, .string, .fileURL, .png, .pdf]
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        self.registerForDraggedTypes(supportedTypes)
//    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForDraggedTypes(supportedTypes)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        fileTypeIsOk = checkExtension(drag: sender)
        return []
    }
    
    //3
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    //4
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = sender.draggedFileURL else {
            return false
        }
        delegate?.didDragImage(url: draggedFileURL)
        return true
    }
    
    //5
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let fileExtension = drag.draggedFileURL?.pathExtension.lowercased() else {
            return false
        }
        
        return acceptedFileExtensions.contains(fileExtension)
    }
    
}
let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]

extension NSDraggingInfo {
    var draggedFileURL: URL? {
        let pasteboard = draggingPasteboard
        
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            return urls.first
        }
        return nil
    }
}
