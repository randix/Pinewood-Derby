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
        Settings.shared.appName = dictionary["CFBundleName"] as! String
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        Settings.shared.appVersion = "\(version).\(build)"
        log("\(Settings.shared.appName) \(Settings.shared.appVersion)")
        
        Settings.shared.readData()
        Derby.shared.readDerbyData()
        Derby.shared.readHeatsData()
        Settings.shared.findTimer()
        
        //BTManager.shared.startAdvertisementScan(Advertisement.shared.adverisement(_:_:_:_:_:))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
