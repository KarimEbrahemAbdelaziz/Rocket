//
//  StatusMenuController.swift
//  Rocket
//
//  Created by Sofiane Beors on 02/05/2018.
//  Copyright © 2018 Sofiane Beors. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var addProjectItem: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    var projectIsTracked = false
    var trackedProject: URL!
    
    override func awakeFromNib() {
        setupMenu()
    }
    
    @IBAction func quitDidClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func setupMenu() {
        statusItem.title = "🚀"
        if projectIsTracked == false { addProjectItem.isHidden = false } else { addProjectItem.isHidden = true }
        statusMenu.autoenablesItems = true
        statusItem.menu = statusMenu
    }
    
    func addActions() {
        let quitItem = statusMenu.items.last
        statusMenu.removeAllItems()

        let fileArray = self.trackedProject.absoluteString.components(separatedBy: "/").dropLast()
        statusMenu.addItem(withTitle: fileArray.last!, action: nil, keyEquivalent: "")
        statusMenu.addItem(NSMenuItem.separator())
        let availableActions = FastlaneManager.getFastlaneActions(forPath: self.trackedProject)

        for action in availableActions {
            let item = NSMenuItem(title: action, action: #selector(runAction(_:)), keyEquivalent: "")
            item.isEnabled = true
            item.target = self
            statusMenu.addItem(item)
        }
        let loadAnotherItem = NSMenuItem(title: "Load an other project", action: #selector(addProject(_:)), keyEquivalent: "")
        loadAnotherItem.isEnabled = true
        loadAnotherItem.target = self
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(loadAnotherItem)
        statusMenu.addItem(quitItem!)
        statusMenu.update()
    }
    
    @IBAction func addProject(_ sender: Any) {
        guard let window = NSApplication.shared.windows.first else { return }
        let filePanel = NSOpenPanel()
        filePanel.canChooseDirectories = true
        filePanel.canChooseFiles = false
        
        filePanel.beginSheetModal(for: window) { (result) in
            if result == .OK {
                self.projectIsTracked = true
                self.trackedProject = filePanel.urls[0]
                self.addActions()
            }
            
            if result == .cancel {
                print("Canceled")
            }
            
            if result == .abort {
                print("Aborted")
            }
        }
    }
    
    @objc func runAction(_ action: NSMenuItem) {
        let args = "cd \(self.trackedProject!.path) && \(action.title)"
        let script = """
        tell application "Terminal" \n\
        do script "\(args)" \n\
        activate \n\
        end tell
        """
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil)
    }
}
