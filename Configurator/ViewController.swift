//
//  ViewController.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

class ViewController: NSViewController {

    static var pathToBooksPlist: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDirectory()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func setupDirectory() {
        let fileManager = FileManager()
        guard let srcroot = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let cloudContentPath = srcroot.path.appending("/CloudContent")
        do {
            try fileManager.createDirectory(atPath: cloudContentPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Couldn't create document directory \(error)")
            return
        }

        let pathPlist = cloudContentPath.appending("/books.plist")
        if fileManager.createFile(atPath: pathPlist, contents: nil, attributes: nil) {
            Self.pathToBooksPlist = pathPlist
        }
    }
}

