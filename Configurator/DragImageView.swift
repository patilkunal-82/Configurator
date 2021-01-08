//
//  DrageImageView.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa
import AVKit
import SceneKit
import AVFoundation




protocol DragImageViewDelegate {
    func didDragImage(url: URL, in dragView: DragImageView)
}
class DragImageView: NSView {

    var delegate: DragImageViewDelegate?
    let coverImage: Bool
    let anchorIdentifier: String
    let contentIdentifier: String?
    var isFilled = false
    private var fileTypeIsOk = false
    private let acceptedFileExtensions = ["jpg", "png", "jpeg", "MP4", "mp4"]
    private let supportedTypes: [NSPasteboard.PasteboardType] = [.tiff, .color, .string, .fileURL, .png, .pdf, .URL, .fileContents, .sound]
    private var imageView = NSImageView()
    private let videoView = NSData()
    private let nsView = NSView()
    
    
    init(frame frameRect: NSRect, anchorID: String, coverImage: Bool = false, contentIdentifier: String? = nil) {
        self.coverImage = coverImage
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
        
        guard let draggedFileURL = sender.draggedFileURL else {return false}
        print("dragged file: \(draggedFileURL.absoluteURL)")
        
        switch draggedFileURL.pathExtension {
        case "jpg", "png", "JPEG", "HEIC":
            let nsImage = NSImage(contentsOfFile: draggedFileURL.path)
            imageView.frame = self.bounds
            self.addSubview(imageView)
            imageView.image = nsImage
            delegate?.didDragImage(url: draggedFileURL, in: self)
            isFilled = true
            return true
            
        case "mp4":
            
            let avAsset = AVAsset(url: draggedFileURL.absoluteURL)
            let assetView = AVAssetImageGenerator(asset: avAsset)
            assetView.appliesPreferredTrackTransform = true
            assetView.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
            let cmTime = CMTime(seconds: 0.5, preferredTimescale: 60)
            var avImage: CGImage?
            do {
                avImage = try assetView.copyCGImage(at: cmTime, actualTime: nil)
                print("inside do catch")
            } catch let error {
                print("Error: \(error)")
                
            }
            let aspectRatio = Float(avImage!.width) / Float(avImage!.height)
            let avImageSize = NSSize(width: self.bounds.width, height: self.bounds.width/CGFloat(aspectRatio))
            let asImage = NSImage(cgImage: avImage!, size: avImageSize)
            imageView.frame = self.bounds
            imageView.image = asImage
            self.addSubview(imageView)
           
            delegate?.didDragImage(url: draggedFileURL, in: self)
            isFilled = true
            return true
            
            
        default:
            return true
            
        }
    
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
