//
//  BookViewController.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

class BookViewController: NSViewController, DragImageViewDelegate, NSTextFieldDelegate {
    
    func didDragImage(url: URL, in dragView: DragImageView) {
        let fileName = (dragView.contentIdentifier == nil ? dragView.anchorIdentifier : dragView.contentIdentifier!) + "." + url.pathExtension
        let lastPath = "/" + fileName
        guard let path = ViewController.pathToCloudContent?.appending(lastPath) else { return }
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                print("can't delete file at: \(path): \(error)")
            }
        }
        do {
            try fileManager.copyItem(at: url, to: URL(fileURLWithPath: path))
        } catch {
            print("error copying file: \(error)")
        }
        if let _ = dragView.contentIdentifier {
            for anchorKey in anchorsPlistDictionary.keys {
                if anchorKey.contains(dragView.anchorIdentifier) {
                    anchorsPlistDictionary[anchorKey]?.append(fileName)
                }
            }
            setupNextContentHolder()
        } else {
            var anchorExists = false
            for anchorKey in anchorsPlistDictionary.keys {
                if anchorKey.contains(dragView.anchorIdentifier) {
                    let contentArray = anchorsPlistDictionary[anchorKey]
                    anchorsPlistDictionary.removeValue(forKey: anchorKey)
                    anchorsPlistDictionary[fileName] = contentArray
                    anchorExists = true
                    break
                }
            }
            if !anchorExists {
                anchorsPlistDictionary[fileName] = []
            }
        }
    }
    
    private let uuid = UUID()
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var bookTitle: NSTextField!
    private let anchorSize = CGSize(width: 250, height: 250)
    private var anchors: [[DragImageView : [DragImageView]]] = []
    private let fileManager = FileManager()
    private var destinationPath: URL?
    private var titleAdded = false
    private var booksDictionary: [String : String] = [:]
    private var anchorsPlistDictionary: [String : [String]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        bookTitle.delegate = self
        setupNextAnchorContentPlaceholder()
    }
    
    private func setupNextAnchorContentPlaceholder() {
        setupAnchorHolder()
        setupNextContentHolder()
    }
    
    private func setupAnchorHolder() {
        let imageFrame = NSRect(x: 16, y: (16 + anchorSize.height) * CGFloat(anchors.count) + 16, width: anchorSize.width, height: anchorSize.height)
        let dragImageView = DragImageView(frame: imageFrame, anchorID: "anchor" + String(anchors.count), contentIdentifier: nil)
        dragImageView.delegate = self
        scrollView.documentView?.addSubview(dragImageView)
        var dict: [DragImageView : [DragImageView]] = [:]
        dict[dragImageView] = []
        anchors.append(dict)
    }
    
    private func setupNextContentHolder() {
        var currentAnchorDict = anchors[anchors.count - 1]
        let imageFrame = NSRect(x: 48 + anchorSize.width, y: (16 + anchorSize.height) * CGFloat(totalContentCount) + 16, width: anchorSize.width, height: anchorSize.height)
        let anchorID = "anchor" + String(anchors.count - 1)
        let contentID = anchorID + "content" + String(currentAnchorDict.values.first?.count ?? 0)
        let dragImageView = DragImageView(frame: imageFrame, anchorID: "anchor" + String(anchors.count), contentIdentifier: contentID)
        dragImageView.delegate = self
//        contentView.bounds.size = NSSize(width: contentView.bounds.size.width, height: 16 + (16 + anchorSize.height))
        let count = totalContentCount + 1
        scrollView.documentView?.frame.size = NSSize(width: contentView.bounds.size.width, height: 16 + (16 + anchorSize.height) * CGFloat(count) + 1)
        scrollView.documentView?.addSubview(dragImageView)
        guard let anchorView = currentAnchorDict.keys.first else { return }
        currentAnchorDict[anchorView]?.append(dragImageView)
        anchors[anchors.count - 1] = currentAnchorDict
    }
    
    private var totalContentCount: Int {
        var count = 0
        for anchor in anchors {
            count += anchor.values.first?.count ?? 0
        }
        return count
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
