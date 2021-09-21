//
//  Pinewood_DerbyApp.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 8/9/21.
//

import SwiftUI

@main
struct Pinewood_DerbyApp: App {
    
    init() {
        log("Pinewood_DerbyApp.init")
        BTManager.shared.startAdvertisementScan(Advertisement.shared.adverisement(_:_:_:_:_:))
        let _ = Persist.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
