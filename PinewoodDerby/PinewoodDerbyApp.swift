//
//  PinewoodDerbyApp.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 9/29/21.
//

import SwiftUI

@main
struct PinewoodDerbyApp: App {
   
    init() {
        let dictionary = Bundle.main.infoDictionary!
        Derby.shared.appName = dictionary["CFBundleName"] as! String
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        Derby.shared.appVersion = "\(version).\(build)"
        log("\(Derby.shared.appName) \(Derby.shared.appVersion)")
        
        log("screen \(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
        
        Derby.shared.initStateMachine()
        
        // install sample files and documentation
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for f in ["racers", "groups"] {
            let fileUrl = Bundle.main.url(forResource:f, withExtension: "csv")!
            let destUrl = docsDir.appendingPathComponent(f + ".csv")
            if !FileManager.default.fileExists(atPath: destUrl.path) {
                do {
                    try FileManager.default.copyItem(at: fileUrl, to: destUrl)
                    log("Copied \(f)")
                } catch {
                    log("error: \(error.localizedDescription)")
                }
            }
        }
        var f = "Pinewood Derby"
        var fileUrl = Bundle.main.url(forResource:f, withExtension: "pdf")!
        var destUrl = docsDir.appendingPathComponent(f + ".pdf")
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
        f = "PDServer"
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
