//
//  SettingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var settings = Settings.shared
    let derby = Derby.shared
    let rest = REST.shared
    
    @State var showAlert = false
    
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
                    TextField("192.168.12.125", text: $settings.myIpAddress)
                        .font(.system(size: 18))
                        .frame(width:150)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                }
                HStack {
                    Text("Server IP Address:")
                        .font(.system(size: 18))
                        .frame(width:150, alignment: .trailing)
                    //.background(.yellow)
                    TextField("192.168.12.128", text: $settings.serverIpAddress)
                        .font(.system(size: 18))
                        .frame(width:150)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                }
                HStack {
                    Text("Server Port:")
                        .font(.system(size: 18))
                        .frame(width:150, alignment: .trailing)
                    //.background(.yellow)
                    TextField("8080", text: $settings.serverPort)
                        .font(.system(size: 18))
                        .frame(width:70)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                    Spacer().frame(width: 80)
                }
                HStack {
                    Spacer().frame(width:15)
                    Text("Connected:")
                        .font(.system(size: 18))
                    Spacer().frame(width:20)
                    if settings.serverIpAddress == rest.serverIpAddress {
                        Image(systemName: "checkmark.square").font(.system(size: 18))
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "x.square").font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                    Spacer().frame(width: 20)
                    Button(action: {
                        rest.findTimer()
                    }) {
                        Text("Rescan")
                            .font(.system(size: 18))
                            .frame(width:70)
                        //.background(.yellow)
                    }
                    
                }
                Spacer().frame(height:30)
            }
            
            // --------------- Server Data pull ---------------
            if !settings.isMaster {
                Group {
                    Button(action: {
                        rest.readFilesFromServer()
                    })  {
                        Text("Update Configuration From Server").font(.system(size:18))
                    }
                    Spacer().frame(height:30)
                }
                
                // --------------- Server Data pull and master stuff ---------------
                HStack {
                    Spacer()
                    Image(systemName: "123.rectangle").font(.system(size: 18)).frame(width: 30)
                    Text("Pin: ").font(.system(size: 18))
                    TextField("0000", text: $settings.pin).font(.system(size: 18))
                        .frame(width:70)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .keyboardType(.numberPad)
                    //.background(.red)
                    Button(action: {
                        settings.isMaster = settings.pin == settings.masterPin
                        settings.pin = ""
                        if settings.isMaster == false {
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
                    TextField("Title", text: $settings.title)
                        .font(.system(size: 18))
                        .frame(width:220)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                }
                HStack {
                    Text("Event:")
                        .font(.system(size: 18))
                        .frame(width:60, alignment: .trailing)
                    //.background(.yellow)
                    TextField("Event", text: $settings.event)
                        .font(.system(size: 18))
                        .frame(width:220)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                }
                HStack {
                    Text("Tracks:")
                        .font(.system(size: 18))
                        .frame(width:70, alignment: .trailing)
                    //.background(.yellow)
                    TextField("#", text: $settings.tracks)
                        .font(.system(size: 18))
                        .frame(width:40)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                        .onChange(of: settings.tracks, perform: { value in
                            // TODO: validate int between 2-6
                            if let t = Int(value) {
                                if t < 2 || t > 6 {
                                    // TODO: alert
                                }
                            } else {
                                // TODO: alert
                            }
                        })
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
                        showAlert = true
                    })  {
                        Text("Start Racing").font(.system(size:20)).bold()
                    }
                    Spacer().frame(height:20)
                }
                
                Text("------Tests------").font(.system(size:18))
                Spacer().frame(height:10)
                Group {
                    Button(action: {
                        // TODO: start simulation timer
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
                }
                .alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Reset All Timing Data"),
                          message: Text("Are you sure?"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Go")) { derby.startRacing() }
                    )
                }
            }
            
            Spacer()
        }
        .onDisappear(perform: {
            settings.saveSettings()
        })
    }
}

// TODO: Start Races times (archive and "Are you sure?")
// TODO: archive before generate heats (archive)

class Settings: ObservableObject {
    
    @Published var isMaster = false
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var appName = ""
    var appVersion = ""
    
    let settingsName = "settings.txt"
    
    @Published var myIpAddress: String = "192.168.12.125"
    @Published var serverIpAddress: String = "192.168.12.128"
    @Published var serverPort: String = "8080"
    
    var masterPin = "1234"
    @Published var pin: String = ""
    
    @Published var title = ""
    @Published var event = ""
    @Published var tracks = ""
    @Published var trackCount = 0
    
    static let shared = Settings()
    private init() {}
    
    func readSettings() {
        log(#function)
        let name = docDir.appendingPathComponent(settingsName)
        var config: String
        do {
            config = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            title = "Pinewood Derby"
            event = "Event"
            tracks = "4"
            trackCount = 4
            myIpAddress =  "192.168.12.125"
            serverIpAddress = "192.168.12.128"
            serverPort = "8080"
            saveSettings()
            objectWillChange.send()
            return
        }
        
        let lines = config.components(separatedBy: "\n")
        for i in 0..<lines.count {
            let keyValue = lines[i].components(separatedBy: "=")
            if keyValue.count < 2 {
                log("\(settingsName): format error")
                continue
            }
            //print("'\(keyValue[0])' '\(keyValue[1])'")
            switch keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines) {
            case "title":
                title = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("title=\(title)")
            case "event":
                event = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("event=\(event)")
            case "tracks":
                tracks = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                trackCount = 2
                if let t = Int(tracks) {
                    trackCount = t
                }
                if trackCount > 6 {
                    trackCount = 6
                    tracks = String(trackCount)
                }
                log("tracks=\(tracks)")
            case "myIpAddress":
                myIpAddress = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("myIpAddress=\(myIpAddress)")
            case "serverIpAddress":
                serverIpAddress = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("serverIpAddress=\(serverIpAddress)")
            case "serverPort":
                serverPort = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("serverPort=\(serverPort)")
            default:
                log("incorrect format: \(config)")
            }
        }
        self.objectWillChange.send()
    }
    
    func saveSettings() {
        log(#function)
        var list = [String]()
        list.append("title=\(title.trimmingCharacters(in: .whitespaces))")
        list.append("event=\(event.trimmingCharacters(in: .whitespaces))")
        list.append("tracks=\(tracks.trimmingCharacters(in: .whitespaces))")
        trackCount = 2
        if let t = Int(tracks) {
            trackCount = t
        }
        list.append("myIpAddress=\(myIpAddress.trimmingCharacters(in: .whitespaces))")
        list.append("serverIpAddress=\(serverIpAddress.trimmingCharacters(in: .whitespaces))")
        list.append("serverPort=\(serverPort.trimmingCharacters(in: .whitespaces))")
        let name = Settings.shared.docDir.appendingPathComponent(settingsName)
        let fileData = list.joined(separator: "\n") + "\n"
        
        do {
            try fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
        }
    }
}
