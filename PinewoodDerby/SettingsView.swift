//
//  SettingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct SettingsView: View {
    
    let derby = Derby.shared
    let settings = Settings.shared
    
    let settingsName = "settings.csv"
    
    let fontSize = CGFloat(18)
    let iconSize = CGFloat(14)
    
    @State var pin: String = ""
    @State var tracks: Int =  0
    
    @FocusState private var nameIsFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Settings").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:30)
            
            Text("\(Settings.shared.appName) \(Settings.shared.appVersion)")
                .font(.system(size: fontSize))
            Spacer().frame(height:30)
            
            HStack {
                //Spacer().frame(width: 20)
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
                    settings.isMaster = pin == derby.pin
                    pin = ""
                    nameIsFocused = false
                    Settings.shared.saveData()
                }) {
                    Image(systemName: pin == derby.pin ? "checkmark.square.fill" : "checkmark").font(.system(size: fontSize)).frame(width: 30)
                }
            }
            if settings.isMaster {
                Text("This device is the Timer Master").font(.system(size:fontSize))
            } else {
                Text("This device is a Timer Observer").font(.system(size:fontSize))
            }
            Spacer().frame(height:30)
            
            // Number of tracks
            HStack {
                Image(systemName: "rectangle.grid.1x2").font(.system(size: fontSize)).frame(width: 30)
                Text("Tracks: ").font(.system(size: fontSize))
                Picker(selection: $tracks,
                       label: Text("Tracks"),
                       content: {
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
                    Text("6").tag(6)
                })
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: tracks) { _ in
                        settings.trackCount = tracks
                        settings.saveData()
                    }
            }
            
            // Generate times for all heats
            //TODO: test time and rankings
            
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


class Settings: ObservableObject {
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let settingsName = "settings.txt"
    
    var appName: String = ""
    var appVersion: String = ""
    
    var minimumTime =  1.0
    var maximumTime = 20.0
    
    @Published var isMaster: Bool = false
    @Published var trackCount = 4
    
    static let shared = Settings()
    private init() {}
    
    func readData() {
        log("Settings.readData")
        let name = docDir.appendingPathComponent(settingsName)
        var settings: String
        do {
            settings = try String(contentsOf: name)
        } catch {
            log("error: \(error)")
            settings = ""
        }
        let items = settings.components(separatedBy: ",")
        if items.count == 2 {
            let isMast = items[0].components(separatedBy: "=")
            
            isMaster = false
            if isMast[1] == "true" {
                isMaster = true
            }
            print("isMaster = \(isMaster)")
            let tracks = items[1].components(separatedBy: "=")
            trackCount = Int(tracks[1].trimmingCharacters(in: .whitespacesAndNewlines))!
            print("trackCount = \(trackCount)")
        }
        self.objectWillChange.send()
    }
    
    func saveData() {
        log("Settings.saveData")
        let settings = "isMaster=\(isMaster),trackCount=\(trackCount)\n"
        let name = docDir.appendingPathComponent(settingsName)
        try! settings.write(toFile: name.path, atomically: true, encoding: .utf8)
        log("saved settings data")
    }
}
