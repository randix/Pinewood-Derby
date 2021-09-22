//
//  Pinewood_DerbyApp.swift
//
//  Created by Rand Dow on 8/9/21.
//

import SwiftUI

@main
struct Pinewood_DerbyApp: App {
    
    init() {
        log("Pinewood_DerbyApp.init")
        Settings.shared.readData()
        Derby.shared.readData()
        Heats.shared.readData()
        
        BTManager.shared.startAdvertisementScan(Advertisement.shared.adverisement(_:_:_:_:_:))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
