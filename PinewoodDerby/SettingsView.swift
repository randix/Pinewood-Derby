//
//  SettingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

enum AlertAction {
    case serverNotConnected
    case startRace
    case startSimulation
}

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var settings = Settings.shared
    let derby = Derby.shared    // do not make this an ObservedObject
    @ObservedObject var rest = REST.shared
    
    var possibleTracks = ["2", "3", "4", "5", "6"]
    @State var tracksSelector = 2
    
    @State var showAlert = false
    @State var alertAction = AlertAction.startRace
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertButton = ""
    
    var body: some View {
        VStack {
            Group {
                Spacer().frame(height: 20)
                
                // chevron down
                HStack {
                    Spacer().frame(minWidth: 0)
                    Image(systemName: "chevron.compact.down").resizable().frame(width: 35, height: 12).opacity(0.3)
                    Spacer().frame(minWidth: 0)
                }
                Spacer().frame(height: 20)
                
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
                HStack {
                    Spacer()
                    Image(systemName: "123.rectangle").font(.system(size: 18)).frame(width: 30)
                    Text("Pin: ").font(.system(size: 18))
                    
                    SecureField("pin", text: $settings.pin)
                        .font(.system(size: 18))
                        .frame(width:70)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    Spacer()
                }
            } else {
                // --------------- Server Data push and master stuff ---------------
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
                    Picker("Names", selection: $tracksSelector) {
                             ForEach(0 ..< possibleTracks.count) {
                                 Text(self.possibleTracks[$0])
                             }
                    }.pickerStyle(SegmentedPickerStyle())
                        .frame(width: 160)
                        .onChange(of: tracksSelector) { _ in
                            derby.heats = []
                            settings.trackCount = tracksSelector + 2
                        }
                }
                Spacer().frame(height:30)
                Group {
                    Button(action: {
                        settings.saveSettings()
                        rest.saveFilesToServer()
                    })  {
                        Text("Send Configuration To Server").font(.system(size:18))
                    }
                }
                Spacer().frame(height:50)
                Group {
                    Button(action: {
                        if settings.serverIpAddress != rest.serverIpAddress {
                            alertAction = .serverNotConnected
                            alertTitle = "Timer Is Not Reachable"
                            alertMessage = "Cannot get the times from the timer until it is connected."
                            alertButton = "Acknowlege"
                            showAlert = true
                            return
                        }
                        alertAction = .startRace
                        alertTitle = "Reset All Timing Data"
                        alertMessage = "Are you sure?"
                        alertButton = "Go"
                        showAlert = true
                    })  {
                        Text("Start Racing").font(.system(size:22)).bold()
                    }
                    Spacer().frame(height:40)
                }
                HStack {
                    Spacer()
                    Text("Simulation Testing:").font(.system(size:16)).bold()
                    Button(action: {
                        alertAction = .startSimulation
                        alertTitle = "Reset All Timing Data"
                        alertMessage = "Are you sure?"
                        alertButton = "Go"
                        showAlert = true
                    })  {
                        Text("Start").font(.system(size:16)).bold()
                    }
                    Spacer().frame(width:20)
                    Button(action: {
                        derby.simulationRunning = true
                        derby.tabSelection = Tab.heats.rawValue
                        self.presentationMode.wrappedValue.dismiss()
                    })  {
                        Text("Resume").font(.system(size:16)).bold()
                    }
                    Spacer()
                }
            }
            Spacer().frame(height:40)
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            })  {
                Text("Dismiss").font(.system(size:18)).bold()
            }
            
            Spacer()
            Group {
                Spacer().frame(height: 10)
                Text("\(settings.appName) \(settings.appVersion)")
                    .font(.system(size: 9))
                Text("For info, see: Files App: On My " + (settings.iPad ? "iPad" : "iPhone") + " / Pinewood-Derby / Pinewood-Derby")
                    .font(.system(size: 9))
                Text("Copyright © 2021 Randix LLC. All rights reserved.")
                    .font(.system(size: 9))
                Spacer().frame(height: 10)
            }
        }
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(alertTitle),
                  message: Text(alertMessage),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text(alertButton)) {
                if alertAction == .serverNotConnected {
                    return
                }
                settings.saveSettings()
                if alertAction == .startRace {
                    derby.startRacing()
                } else {
                    derby.simulate()
                }
                derby.tabSelection = Tab.heats.rawValue
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear(perform: {
            tracksSelector = settings.trackCount - 2
        })
        .onDisappear(perform: {
            settings.saveSettings()
        })
    }
}

class Settings: ObservableObject {
    
    @Published var isMaster = false
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let rest = REST.shared
    
    var appName = ""
    var appVersion = ""
    let iPad = UIScreen.main.bounds.width > 600
    
    @Published var myIpAddress: String = "192.168.12.125"
    @Published var serverIpAddress: String = "192.168.12.128"
    @Published var serverPort: String = "8080"
    
    var masterPin = "1234"
    @Published var pin: String = ""
    
    @Published var title = ""
    @Published var event = ""
    @Published var trackCount = 0
    
    static let maxTracks = 6
    
    static let shared = Settings()
    private init() {}
    
    func readSettings() {
        log("\(#function) \(rest.settingsName)")
        let name = docDir.appendingPathComponent(rest.settingsName)
        var config: String
        do {
            config = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            title = "Pinewood Derby"
            event = "Event"
            trackCount = 4
            myIpAddress =  "192.168.12.125"
            serverIpAddress = "192.168.12.128"
            serverPort = "8080"
            saveSettings()
            return
        }
        
        let lines = config.components(separatedBy: "\n")
        for line in lines {
            if line.count == 0 {
                continue
            }
            let keyValue = line.components(separatedBy: "=")
            if keyValue.count < 2 {
                log("\(rest.settingsName): format error")
                continue
            }
            switch keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines) {
            case "title":
                title = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("title=\(title)")
            case "event":
                event = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                log("event=\(event)")
            case "tracks":
                let tracks = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                trackCount = 2
                if let t = Int(tracks) {
                    trackCount = t
                }
                if trackCount < 2 {
                    trackCount = 2
                }
                if trackCount > Settings.maxTracks {
                    trackCount = Settings.maxTracks
                }
                log("tracks=\(String(trackCount))")
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
        //self.objectWillChange.send()  Nothing to send it to yet
    }
    
    func saveSettings() {
        log("\(#function) \(rest.settingsName)")
        var list = [String]()
        list.append("title=\(title.trimmingCharacters(in: .whitespaces))")
        list.append("event=\(event.trimmingCharacters(in: .whitespaces))")
        list.append("tracks=\(String(trackCount))")
        list.append("myIpAddress=\(myIpAddress.trimmingCharacters(in: .whitespaces))")
        list.append("serverIpAddress=\(serverIpAddress.trimmingCharacters(in: .whitespaces))")
        list.append("serverPort=\(serverPort.trimmingCharacters(in: .whitespaces))")
        let name = docDir.appendingPathComponent(rest.settingsName)
        let fileData = list.joined(separator: "\n") + "\n"
        
        do {
            try fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
        }
    }
}
