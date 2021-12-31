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
    }
   
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
