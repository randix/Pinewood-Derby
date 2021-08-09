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
        print("init BTManager")
        let m = BTManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
