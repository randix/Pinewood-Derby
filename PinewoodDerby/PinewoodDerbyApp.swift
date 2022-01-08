//
//  PinewoodDerbyApp.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 9/29/21.
//

import SwiftUI

@main
struct PinewoodDerbyApp: App {
    
    let derby = Derby.shared
   
    init() {
        let dictionary = Bundle.main.infoDictionary!
        derby.appName = dictionary["CFBundleName"] as! String
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        derby.appVersion = "\(version).\(build)"
        log("\(derby.appName) \(derby.appVersion)")
        
        log("screen \(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
        
        // install sample files and documentation
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var f = "derby"
        var fileUrl = Bundle.main.url(forResource:f, withExtension: "txt")!
        var destUrl = docsDir.appendingPathComponent(f + ".txt")
        if !FileManager.default.fileExists(atPath: destUrl.path) {
            do {
                try FileManager.default.copyItem(at: fileUrl, to: destUrl)
                log("Copied \(f)")
            } catch {
                log("error: \(error.localizedDescription)")
            }
        }
        f = "Pinewood Derby"
        fileUrl = Bundle.main.url(forResource:f, withExtension: "pdf")!
        destUrl = docsDir.appendingPathComponent(f + ".pdf")
        if !FileManager.default.fileExists(atPath: destUrl.path) {
            do {
                try FileManager.default.copyItem(at: fileUrl, to: destUrl)
                log("Copied \(f).pdf")
            } catch {
                log("error: \(error.localizedDescription)")
            }
        }
        fileUrl = Bundle.main.url(forResource:"README", withExtension: "md")!
        destUrl = docsDir.appendingPathComponent(f + ".md")
        if !FileManager.default.fileExists(atPath: destUrl.path) {
            do {
                try FileManager.default.copyItem(at: fileUrl, to: destUrl)
                log("Copied \(f).pdf")
            } catch {
                log("error: \(error.localizedDescription)")
            }
        }
        f = "PDTimer"
        fileUrl = Bundle.main.url(forResource:f, withExtension: "tar")!
        destUrl = docsDir.appendingPathComponent(f + ".tar")
        if !FileManager.default.fileExists(atPath: destUrl.path) {
            do {
                try FileManager.default.copyItem(at: fileUrl, to: destUrl)
                log("Copied \(f).tar")
            } catch {
                log("error: \(error.localizedDescription)")
            }
        }
    }
   
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
