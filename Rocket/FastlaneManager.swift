//
//  FastlaneManager.swift
//  Rocket
//
//  Created by Sofiane Beors on 02/05/2018.
//  Copyright © 2018 Sofiane Beors. All rights reserved.
//

import Foundation
import Cocoa

public class FastlaneManager {
    public class func getFastlaneActions(forPath: URL) -> [String] {
        var availableActions = [String]()
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: "\(forPath.path)/fastlane") {
                if fileManager.fileExists(atPath: "\(forPath.path)/fastlane/README.md") {
                    let readmeUrl = URL(string: "\(forPath.absoluteString)/fastlane/README.md")!
                    let readme = try String(contentsOf: readmeUrl)
                    if readme != "" {
                        if fileManager.fileExists(atPath: "\(forPath.path)/fastlane/Fastfile") {
                            let fastFile = try String(contentsOf: URL(string: "\(forPath.absoluteString)/fastlane/Fastfile")!)
                            
                            let platform = fastFile.components(separatedBy: "default_platform(:")[1].components(separatedBy: ")")[0]
                            let filtered = readme.lowercased().components(separatedBy: "## \(platform)\n")[1].components(separatedBy: "----")[0]
                            let actions = filtered.components(separatedBy: "### ios ")
                            
                            for action in actions {
                                for a in action.components(separatedBy: "```") {
                                    if a.contains("fastlane ") {
                                        availableActions.append(String(a.filter { !"\n".contains($0) }))
                                    }
                                }
                            }
                        } else {
                            print("Fastfile not found")
                        }
                    }
                } else {
                    print("README.md not found")
                    self.presentAlert(message: "README.md not found", description: "")
                }
            } else {
                print("Fastlane not found. Check if fastlane is setup on this project")
                self.presentAlert(message: "Fastlane not found. Check if fastlane is setup on this project", description: "run `fastlane init` to setup fastlane")
            }
        } catch {
            print("Failed")
        }
        return availableActions
    }
    
    private static func presentAlert(message: String, description: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = description
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
