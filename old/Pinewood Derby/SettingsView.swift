//
//  ResultsView.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import SwiftUI

struct SettingsView: View {
    
    let settings = Settings.shared
    
    var body: some View {
        VStack {
            Text("Settings")
            // 
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
    
    // TODO: clear times (archive and "Are you sure?")
    // TODO: generate heats (archive and "Ary you sure?)
    
    // number of tracks
    // minimum time, if less than, discard and mark
    // maximum time, if more than, discard and mark
    
    // ask for PIN, become server
    // show IP address
    // start server for files
    // display connections and successful transfers
    
    // No Pin
    // enter IP address
    // copy derby.csv and heats.csv from server
    // display successful transfer

}

// clear times, clear all data

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
        print(docDir)
    }
    
    func saveData() {
        
    }
}
