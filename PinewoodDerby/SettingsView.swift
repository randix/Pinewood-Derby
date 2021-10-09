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
    let rest = REST.shared
    
    @State var pin: String = ""
    @State var ipAddress: String = ""
    
    var body: some View {
        VStack {
            
            Group {
                HStack {
                    Spacer()
                    Text("Settings").font(.system(size: 20)).bold()
                    Spacer()
                }
                Spacer().frame(height:30)
            }
            
            Group {
                Text("\(Settings.shared.appName) \(Settings.shared.appVersion)")
                    .font(.system(size: 18))
                Spacer().frame(height:30)
                
                if let serverAddress = rest.serverAddress {
                    Text("Timer IP Address: \(serverAddress)").font(.system(size: 18))
                } else {
                    Text("Timer Server Not Found!").font(.system(size: 18))
                }
                Spacer().frame(height:30)
            }
            
            Group {
                Button(action: {
                    rest.readFilesFromServer()
                })  {
                    Text("Update Configuration").font(.system(size:18))
                }
                Spacer().frame(height:30)
            }
            
            // TODO: put these behind a "Test" entry started with a pin entry...
            Group {
                Button(action: {
                    rest.saveFilesToServer()
                })  {
                    Text("Send Configuration").font(.system(size:18))
                }
                Spacer().frame(height:30)
            }
            
            
            Button(action: {
                derby.clearTimes()
            }) {
                Text("Clear Times").font(.system(size: 18))
            }
            Spacer().frame(height:30)
            
            Button(action: {
                derby.generateTestTimes()
            }) {
                Text("Generate Test Times").font(.system(size: 18))
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

class Settings {
    
    let derby = Derby.shared
    let rest = REST.shared
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
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
        let name = docDir.appendingPathComponent(rest.configName)
        var config: String
        do {
            config = try String(contentsOf: name)
        } catch {
            log("error: \(error)")
            config = "Title=Pinewood Derby\nSubtitle=Event\nNumberOfTracks=4\nIPAddress=192.168.12.125"
            try! config.write(to: name, atomically: true, encoding: .utf8)
        }
        
        let lines = config.components(separatedBy: "\n")
        for i in 0..<lines.count {
            let keyValue = lines[i].components(separatedBy: "=")
            if keyValue.count < 2 {
                continue
            }
            //print("'\(keyValue[0])' '\(keyValue[1])'")
            switch keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines) {
            case "Title":
                title = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("Title=\(title)")
            case "Subtitle":
                subtitle = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("Subtitle=\(subtitle)")
            case "NumberOfTracks":
                derby.trackCount = Int(keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines))!
                log("NumberOfTracks=\(derby.trackCount)")
            case "IPAddress":
                rest.ipAddress = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("IPAddress=\(rest.ipAddress)")
            default:
                log("incorrect format: \(config)")
            }
        }
        //self.objectWillChange.send()
    }
    
    
}
