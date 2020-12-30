//
//  BookViewController.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

class BookViewController: NSViewController, DragImageViewDelegate, NSTextFieldDelegate {
    
    func didDragImage(url: URL, in dragView: DragImageView) {
        guard !dragView.coverImage else {
            saveCoverImage(url: url, fromView: dragView)
            return
        }
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
    @IBOutlet weak var newAnchorButton: NSButton!
    @IBOutlet weak var publishBookButton: NSButton!
    private let anchorSize = CGSize(width: 250, height: 250)
    private var anchors: [[DragImageView : [DragImageView]]] = []
    private let fileManager = FileManager()
    private var destinationPath: URL?
    private var titleAdded = false
    private var booksDictionary: [String : [String : String]] = [:]
    private var anchorsPlistDictionary: [String : [String]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        bookTitle.delegate = self
    }
    
    private func setupNextAnchorContentPlaceholder() {
        setupAnchorHolder()
        setupNextContentHolder()
    }
    
    private func setupAnchorHolder() {
        let imageFrame = NSRect(x: 16, y: 16, width: anchorSize.width, height: anchorSize.height)
        let dragImageView = DragImageView(frame: imageFrame, anchorID: "anchor" + String(anchors.count), contentIdentifier: nil)
        dragImageView.delegate = self
        scrollView.documentView?.addSubview(dragImageView)
        var dict: [DragImageView : [DragImageView]] = [:]
        dict[dragImageView] = []
        anchors.append(dict)
    }
    
    private func setupNextContentHolder() {
        var currentAnchorDict = anchors[anchors.count - 1]
        let imageFrame = NSRect(x: 48 + anchorSize.width, y: (16 + anchorSize.height) * CGFloat(currentContentCount) + 16, width: anchorSize.width, height: anchorSize.height)
        let anchorID = "anchor" + String(anchors.count - 1)
        let contentID = anchorID + "content" + String(currentAnchorDict.values.first?.count ?? 0)
        let dragImageView = DragImageView(frame: imageFrame, anchorID: anchorID, contentIdentifier: contentID)
        dragImageView.delegate = self
        let count = currentContentCount + 1
        scrollView.documentView?.frame.size = NSSize(width: contentView.bounds.size.width, height: 16 + (16 + anchorSize.height) * CGFloat(count) + 1)
        scrollView.documentView?.addSubview(dragImageView)
        guard let anchorView = currentAnchorDict.keys.first else { return }
        currentAnchorDict[anchorView]?.append(dragImageView)
        anchors[anchors.count - 1] = currentAnchorDict
        
        newAnchorButton.isEnabled = shouldEnableNewAnchorButton
        publishBookButton.isEnabled = shouldEnableNewAnchorButton
    }
    
    private func addCoverImageHolder() {
        let origin = CGPoint(x: (scrollView.bounds.width - anchorSize.width) * 0.5, y: (scrollView.bounds.height - anchorSize.height) * 0.5)
        let coverImageView = DragImageView(frame: CGRect(origin: origin, size: anchorSize), anchorID: "", coverImage: true)
        let label = NSTextView()
        label.isEditable = false
        label.string = "Add cover image"
        label.sizeToFit()
        label.frame.origin = CGPoint(x: (coverImageView.bounds.width - label.bounds.size.width) * 0.5, y: (coverImageView.bounds.height - label.bounds.size.height) * 0.5)
        coverImageView.addSubview(label)
        coverImageView.delegate = self
        scrollView.addSubview(coverImageView)
    }
    
    private var shouldEnableNewAnchorButton: Bool {
        var currentAnchorContentCount = 0
        let currentAnchor = anchors[anchors.count - 1]
        guard let contentArray = currentAnchor.values.first else { return false }
        for content in contentArray {
            if content.isFilled { currentAnchorContentCount += 1 }
        }
        return currentAnchorContentCount > 0 && ((currentAnchor.keys.first?.isFilled) != nil)
    }
    
    private var totalContentCount: Int {
        var count = 0
        for anchor in anchors {
            count += anchor.values.first?.count ?? 0
        }
        return count
    }
    
    private var currentContentCount: Int {
        let anchor = anchors.last
        return anchor?.values.first?.count ?? 0
    }
    
    private func addBook(withCoverImage coverImageName: String) {
        if booksDictionary.keys.contains(uuid.uuidString) {
            booksDictionary.removeValue(forKey: uuid.uuidString)
        }
        var thisBook: [String : String] = [:]
        thisBook[KeyConstants.bookName] = bookTitle.stringValue
        thisBook[KeyConstants.coverImageName] = coverImageName
        booksDictionary[uuid.uuidString] = thisBook
    }
    
    private func saveCoverImage(url: URL, fromView coverImageView: DragImageView) {
        let name = bookTitle.stringValue
        let fileName = name + "." + url.pathExtension
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
        addBook(withCoverImage: fileName)
        coverImageView.removeFromSuperview()
        setupNextAnchorContentPlaceholder()
    }
    
    @IBAction func startNewAnchor(_ sender: Any) {
        guard newAnchorButton.isEnabled else { return }
        guard let documentView = scrollView.documentView else { return }
        for subview in documentView.subviews {
            subview.removeFromSuperview()
        }
        setupNextAnchorContentPlaceholder()
    }
    
    @IBAction func publishBook(_ sender: Any) {
        guard publishBookButton.isEnabled else { return }
        let lastPath = "/" + bookTitle.stringValue + ".plist"
        guard let path = ViewController.pathToCloudContent?.appending(lastPath) else { return }

        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: anchorsPlistDictionary, format: .xml, options: 0)
            try plistData.write(to: URL(fileURLWithPath: path))
        } catch {
            print("Could not write updated plist \(error)")
        }
        guard let plistPath = ViewController.pathToBooksPlist, let plist = fileManager.contents(atPath: plistPath) else { return }
        if !plist.isEmpty {
            do {
                booksDictionary = try PropertyListSerialization.propertyList(from: plist, options: .mutableContainersAndLeaves, format: nil) as! [String : [String : String]]
            } catch {
                print("could not read plist into dictionary \(error)")
            }
        }
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
        bookTitle.isEnabled = false
        addCoverImageHolder()
    }
}
