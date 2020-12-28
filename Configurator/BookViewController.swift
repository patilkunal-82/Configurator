//
//  BookViewController.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

class BookViewController: NSViewController, DragImageViewDelegate, NSTextFieldDelegate {
    
    func didDragImage(url: URL) {
//        fileManager.copyItem(at: url, to: destinationPath!)
    }
    let uuid = UUID()
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var bookTitle: NSTextField!
    private let anchorSize = CGSize(width: 250, height: 250)
    private var anchors: [DragImageView] = []
    private let fileManager = FileManager()
    private var destinationPath: URL?
    private var titleAdded = false
    private var booksDictionary: [String : String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        bookTitle.delegate = self
        setupAnchorHolder()
    }
    
    private func setupAnchorHolder() {
        let dragImageView = DragImageView(frame: NSRect(x: 16, y: contentView.bounds.height - (16 + anchorSize.height) * CGFloat(anchors.count + 1) + 16, width: anchorSize.width, height: anchorSize.height))
        dragImageView.delegate = self
        contentView.addSubview(dragImageView)
        anchors.append(dragImageView)
    }
    
    private func addBook() {
        guard let plistPath = ViewController.pathToBooksPlist, let plist = fileManager.contents(atPath: plistPath) else { return }
        if !plist.isEmpty {
            do {
                booksDictionary = try PropertyListSerialization.propertyList(from: plist, options: .mutableContainersAndLeaves, format: nil) as! [String : String]
            } catch {
                print("could not read plist into dictionary \(error)")
            }
        }
        if booksDictionary.keys.contains(uuid.uuidString) {
            booksDictionary.removeValue(forKey: uuid.uuidString)
        }
        booksDictionary[uuid.uuidString] = bookTitle.stringValue
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: booksDictionary, format: .xml, options: 0)
            try plistData.write(to: URL(fileURLWithPath: plistPath))
        } catch {
            print("Could not write updated plist \(error)")
        }
    }
    
    //Mark: NSTextFieldDelegate
    func controlTextDidEndEditing(_ obj: Notification) {
        defer { titleAdded = true }
        addBook()
        bookTitle.isEnabled = false
    }
}
