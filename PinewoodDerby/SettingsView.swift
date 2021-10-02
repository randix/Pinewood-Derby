//
//  SettingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct SettingsView: View {
    
    let derby = Derby.shared
    
    let fontSize = CGFloat(18)
    let iconSize = CGFloat(14)
    
    @State var pin: String = ""
    @FocusState private var nameIsFocused: Bool
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Settings").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:30)
            
            HStack {
                Spacer().frame(width: 20)
                Image(systemName: "123.rectangle").font(.system(size: fontSize)).frame(width: 30)
                Text("Pin: ").font(.system(size: fontSize))
                TextField("0000", text: $pin).font(.system(size: fontSize))
                    .frame(width:60)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    .keyboardType(.numberPad)
                    .focused($nameIsFocused)
                //.background(.red)
                Button(action: {
                    derby.isMaster = pin == derby.pin
                    pin = ""
                    nameIsFocused = false
                }) {
                    Image(systemName: pin == derby.pin ? "checkmark.square.fill" : "checkmark").font(.system(size: fontSize)).frame(width: 30)
                }
            }
            
            if derby.isMaster {
                Text("This device is the Timer Master").font(.system(size:fontSize))
            } else {
                Text("This device is a Timer Observer").font(.system(size:fontSize))
            }
            
            Spacer()
        }
    }
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
