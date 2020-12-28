//
//  BookViewController.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

class BookViewController: NSViewController, DragImageViewDelegate {
    
    func didDragImage(url: URL) {
//        fileManager.copyItem(at: url, to: destinationPath!)
    }
    let uuid = UUID()
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var contentView: NSView!
    private let anchorSize = CGSize(width: 250, height: 250)
    private var anchors: [DragImageView] = []
    private let fileManager = FileManager()
    private var destinationPath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupAnchorHolder()
        setupDirectory()
    }
    
    private func setupAnchorHolder() {
        let dragImageView = DragImageView(frame: NSRect(x: 16, y: (16 + anchorSize.height) * CGFloat(anchors.count), width: anchorSize.width, height: anchorSize.height))
        dragImageView.delegate = self
        contentView.frame = NSRect(x: 0, y: 0, width: view.bounds.width, height: (16 + anchorSize.height) * CGFloat(anchors.count) + 16)
        contentView.addSubview(dragImageView)
        anchors.append(dragImageView)
    }
    
    private func setupDirectory() {
//        fileManager.
    }
}
