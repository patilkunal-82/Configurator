//
//  ViewController.swift
//  Configurator
//
//  Created by Kunal Patil on 12/24/20.
//

import Cocoa

class ViewController: NSViewController {

    static var pathToBooksPlist: String?
    static var pathToCloudContent: String?
    
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
        defer {
            Self.pathToCloudContent = cloudContentPath
            createBooksList()
        }
        var isDirectory: ObjCBool = false
        guard !fileManager.fileExists(atPath: cloudContentPath, isDirectory: &isDirectory) || !isDirectory.boolValue else { return }
        
        do {
            try fileManager.createDirectory(atPath: cloudContentPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Couldn't create document directory \(error)")
            return
        }
    }
    
    private func createBooksList() {
        guard let cloudContentPath = Self.pathToCloudContent else { return }
        let fileManager = FileManager()
        let pathPlist = cloudContentPath.appending("/books.plist")
        guard !fileManager.fileExists(atPath: pathPlist) else {
            Self.pathToBooksPlist = pathPlist
            return
        }
        if fileManager.createFile(atPath: pathPlist, contents: nil, attributes: nil) {
            Self.pathToBooksPlist = pathPlist
        }
    }
}

