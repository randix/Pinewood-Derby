//
//  SettingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let derby = Derby.shared
    let settings = Settings.shared
    let rest = REST.shared
    
    @State var pin: String = ""
    @FocusState var pinIsFocused: Bool
    @State var myIpAddress: String = ""
    @FocusState var myIpAddressIsFocused: Bool
    @State var serverIpAddress: String = ""
    @FocusState var serverIpAddressIsFocused: Bool
    @State var serverPort: String = ""
    @FocusState var serverPortIsFocused: Bool
    
    @State var title = ""
    @State var event = ""
    @State var noTracks = ""
    
    var body: some View {
        VStack {
            
            Group {
                HStack {
                    Spacer()
                    Text("Settings").font(.system(size: 20)).bold()
                    Spacer()
                }
                Spacer().frame(height:20)
                
                Text("\(Settings.shared.appName) \(Settings.shared.appVersion)")
                    .font(.system(size: 14))
                Spacer().frame(height:20)
            }
            
            // --------------- Server Connection ---------------
            VStack(spacing: 0) {
                HStack {
                    Text("My IP Address:")
                        .font(.system(size: 18))
                        .frame(width:150, alignment: .trailing)
                    //.background(.yellow)
                    TextField("192.168.12.125", text: $myIpAddress)
                        .font(.system(size: 18))
                        .frame(width:150)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .focused($myIpAddressIsFocused)
                    //.background(.yellow)
                }
                HStack {
                    Text("Server IP Address:")
                        .font(.system(size: 18))
                        .frame(width:150, alignment: .trailing)
                    //.background(.yellow)
                    TextField("192.168.12.125", text: $serverIpAddress)
                        .font(.system(size: 18))
                        .frame(width:150)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .focused($serverIpAddressIsFocused)
                    //.background(.yellow)
                }
                HStack {
                    Text("Server Port:")
                        .font(.system(size: 18))
                        .frame(width:150, alignment: .trailing)
                    //.background(.yellow)
                    TextField("8080", text: $serverIpAddress)
                        .font(.system(size: 18))
                        .frame(width:70)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .focused($serverIpAddressIsFocused)
                    //.background(.yellow)
                    Spacer().frame(width: 80)
                }
                HStack {
                    Spacer().frame(width:15)
                    Text("Connected:")
                        .font(.system(size: 18))
                    Spacer().frame(width:20)
                    if serverIpAddress == rest.serverAddress {
                        Image(systemName: "checkmark.square").font(.system(size: 18))
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "x.square").font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                    Spacer().frame(width: 20)
                    Button(action: {}) {
                        Text("Rescan")
                            .font(.system(size: 18))
                            .frame(width:70)
                        //.background(.yellow)
                    }
                    
                }
                Spacer().frame(height:30)
            }
            
            // --------------- Server Data pull ---------------
            if !derby.isMaster {
                Group {
                    Button(action: {
                        rest.readFilesFromServer()
                    })  {
                        Text("Update Configuration From Server").font(.system(size:18))
                    }
                    Spacer().frame(height:30)
                }
            }
            
            // --------------- Server Data pull and master stuff ---------------
            if !derby.isMaster {
                HStack {
                    Spacer()
                    Image(systemName: "123.rectangle").font(.system(size: 18)).frame(width: 30)
                    Text("Pin: ").font(.system(size: 18))
                    TextField("0000", text: $pin).font(.system(size: 18))
                        .frame(width:70)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .keyboardType(.numberPad)
                        .focused($pinIsFocused)
                    //.background(.red)
                    Button(action: {
                        derby.isMaster = pin == derby.pin
                        pin = ""
                        pinIsFocused = false
                        if derby.isMaster == false {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            derby.objectWillChange.send()
                        }
                    }) {
                        Image(systemName: "checkmark").font(.system(size: 18)).frame(width: 30)
                    }
                    Spacer()
                }
            } else {
                
                HStack {
                    Text("Title:")
                        .font(.system(size: 18))
                        .frame(width:60, alignment: .trailing)
                    //.background(.yellow)
                    TextField("Title", text: $title)
                        .font(.system(size: 18))
                        .frame(width:220)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .focused($myIpAddressIsFocused)
                    //.background(.yellow)
                }
                    HStack {
                        Text("Event:")
                            .font(.system(size: 18))
                            .frame(width:60, alignment: .trailing)
                        //.background(.yellow)
                        TextField("Event", text: $event)
                            .font(.system(size: 18))
                            .frame(width:220)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                            .focused($myIpAddressIsFocused)
                        //.background(.yellow)
                    }
                HStack {
                    Text("Tracks:")
                        .font(.system(size: 18))
                        .frame(width:70, alignment: .trailing)
                    //.background(.yellow)
                    TextField("#", text: $noTracks)
                        .font(.system(size: 18))
                        .frame(width:40)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .focused($myIpAddressIsFocused)
                    //.background(.yellow)
                }
                Spacer().frame(height:20)
                Group {
                    Button(action: {
                        rest.saveFilesToServer()
                    })  {
                        Text("Send Configuration to Server").font(.system(size:18))
                    }
                    Spacer().frame(height:10)
                }
                Group {
                    Button(action: {
                        rest.saveFilesToServer()
                    })  {
                        Text("Start Racing").font(.system(size:20)).bold()
                    }
                    Spacer().frame(height:20)
                }
                
                Text("------Tests------").font(.system(size:18))
                Spacer().frame(height:10)
                Group {
                    Button(action: {
                        rest.saveFilesToServer()
                    })  {
                        Text("Start Simulation").font(.system(size:18))
                    }
                    Spacer().frame(height:10)
                }
                Group {
                    Button(action: {
                        derby.generateTestTimes()
                    }) {
                        Text("Generate Test Times").font(.system(size: 18))
                    }
                    Spacer().frame(height:10)
                    Group {
                        Button(action: {
                            derby.clearTimes()
                        }) {
                            Text("Clear Times").font(.system(size: 18))
                        }
                    Spacer().frame(height:10)
                    }
                }
            }
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

