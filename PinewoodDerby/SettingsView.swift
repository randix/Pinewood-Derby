//
//  SettingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Settings").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:10)
            
            Spacer()
        }
    }
}

class Settings {
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let settingsName = "settings.txt"
    
    var appName: String = ""
    var appVersion: String = ""
    
    var minimumTime =  1.0
    var maximumTime = 20.0
    
    var numberOfTracks = 4  // 4 or 6
    
    static let shared = Settings()
    private init() {}
    
    func readData() {
        log("Settings.readData")
        log(docDir.path)
    }
    
    func saveData() {
        
    }
}
