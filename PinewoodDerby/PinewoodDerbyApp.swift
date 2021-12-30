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
        Settings.shared.appName = dictionary["CFBundleName"] as! String
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        Settings.shared.appVersion = "\(version).\(build)"
        log("\(Settings.shared.appName) \(Settings.shared.appVersion)")
        
        log("screen \(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
        
        REST.shared.readFilesFromServer()
        //let beacon = BeaconListener()
       // beacon.start()
        
        Settings.shared.readSettings()
        derby.readGroups()
        derby.readRacers()
        derby.readHeats()
       
        
        //BTManager.shared.startAdvertisementScan(Advertisement.shared.adverisement(_:_:_:_:_:))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
