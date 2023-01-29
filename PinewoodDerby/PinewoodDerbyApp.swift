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
    let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
   
    init() {
        print(docsDir)
        let dictionary = Bundle.main.infoDictionary!
        derby.appName = dictionary["CFBundleName"] as! String
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        derby.appVersion = "\(version).\(build)"
        log("\(derby.appName) \(derby.appVersion)")
        
        log("screen \(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
        
        // install sample files and documentation
        copyBundleToDocs("derby", ".txt")
        copyBundleToDocs("Pinewood Derby Manual", ".pdf")
        copyBundleToDocs("README", ".md")
        copyBundleToDocs("PDTimer", ".tar")
    }
    
    func copyBundleToDocs(_ name: String, _ ext: String) {
        let fileUrl = Bundle.main.url(forResource:name, withExtension: ext)!
        let destUrl = docsDir.appendingPathComponent(name + ext)
        if !FileManager.default.fileExists(atPath: destUrl.path) {
            do {
                try FileManager.default.copyItem(at: fileUrl, to: destUrl)
                log("Copied \(name)\(ext)")
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
