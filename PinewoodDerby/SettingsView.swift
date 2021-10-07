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
    
    let configName = "config.txt"
    
    let fontSize = CGFloat(18)
    let iconSize = CGFloat(14)
    
    @State var pin: String = ""
    @State var ipAddress: String = ""
    
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
                Spacer().frame(width:40)
                Text("Timer IP Address:").font(.system(size: 18))
                TextField("192.168.42.16", text: $ipAddress).font(.system(size: 18))
                    .textFieldStyle(.roundedBorder)
                Spacer().frame(width:40)
            }
            
            
            // TODO: put these behind a "Test" entry started with a pin entry...
            Button(action: {
                derby.clearTimes()
            }) {
                Text("Clear Times").font(.system(size: fontSize))
            }
            Spacer().frame(height:30)
            
            Button(action: {
                derby.generateTestTimes()
            }) {
                Text("Generate Test Times").font(.system(size: fontSize))
            }
            Spacer().frame(height:30)
           
            Spacer()
        }
    }
}

// TODO: clear times (archive and "Are you sure?")
// TODO: archive before generate heats (archive)

// TODO: minimum time, if less than, discard and mark
// maximum time, if more than, discard and mark

// TODO: ask for PIN, become server
  // show IP address
  // start server for files
  // display connections and successful transfers

// TODO: No Pin, become slave
  // enter IP address
  // copy derby.csv and heats.csv from server
  // display successful transfer

class Settings {
    
    let derby = Derby.shared
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let configName = "config.txt"
    
    var appName = ""
    var appVersion = ""
    
    var title = ""
    var subtitle = ""
    
    var minimumTime =  1.0
    var maximumTime = 20.0
    
    static let shared = Settings()
    private init() {}
    
    func readData() {
        log("Settings.readData")
        let name = docDir.appendingPathComponent(configName)
        var config: String
        do {
            config = try String(contentsOf: name)
        } catch {
            log("error: \(error)")
            config = "Title=Pinewood Derby\nSubtitle=Event\nNumberOfTracks=4\n"
            try! config.write(to: name, atomically: true, encoding: .utf8)
        }
        
        let lines = config.components(separatedBy: "\n")
        for i in 0..<lines.count {
            let keyValue = lines[i].components(separatedBy: "=")
            if keyValue.count < 2 {
                continue
            }
            print("'\(keyValue[0])' '\(keyValue[1])'")
            switch keyValue[0] {
            case "Title":
                title = keyValue[1]
                log("Title=\(title)")
            case "Subtitle":
                subtitle = keyValue[1]
                log("Subtitle=\(subtitle)")
            case "NumberOfTracks":
                derby.trackCount = Int(keyValue[1])!
                log("NumberOfTracks=\(derby.trackCount)")
            default:
                log("incorrect format: \(config)")
            }
        }
        //self.objectWillChange.send()
    }
}
