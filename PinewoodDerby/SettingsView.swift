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
    
    @ObservedObject var derby = Derby.shared
    
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
                    
                    Text("\(derby.appName) \(derby.appVersion)")
                        .font(.system(size: 14))
                    Spacer().frame(height:20)
                }
            }
            // MARK: --------------- Server Connection ---------------
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Timer:")
                        .font(.system(size: 18))
                    //.frame(width:50, alignment: .trailing)
                    //.background(.yellow)
                    TextField("http://raspberypi.local:8484/", text: $derby.timer)
                        .font(.system(size: 18))
                        .frame(width:300)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                    Spacer()
                }
                Spacer().frame(height:10)
                HStack {
                    Spacer()
                    Text("Connected:")
                        .font(.system(size: 18))
                    Spacer().frame(width:5)
                    if derby.connected {
                        Image(systemName: "checkmark.square").font(.system(size: 18))
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "x.square").font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                    Spacer().frame(width: 20)
                    Button(action: {
                        derby.readFilesFromServer()
                    }) {
                        Text("Update")
                            .font(.system(size: 18))
                            .frame(width:70)
                        //.background(.yellow)
                    }
                    Spacer()
                }
                if !derby.connected {
                    Spacer().frame(height:10)
                    Text("Check for not connected:\n - is WiFi enabled and connected on this device?\n - is the Timer Computer properly configured?\n   - powered on?\n   - connected to WiFi?\n   - PDServer running?")
                        .font(.system(size: 10))
                }
                Spacer().frame(height:30)
            }
            
            // MARK: --------------- PIN ---------------
            if !derby.isMaster {
                HStack {
                    Spacer()
                    Image(systemName: "123.rectangle").font(.system(size: 18)).frame(width: 30)
                    Text("Pin: ").font(.system(size: 18))
                    
                    SecureField("pin", text: $derby.pin)
                        .font(.system(size: 18))
                        .frame(width:70)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .onChange(of: derby.pin, perform: { _ in
                            //print("pins: derby.pin=\(derby.pin) masterPin=\(derby.masterPin)")
                            if !derby.isMaster {
                                derby.isMaster = derby.pin == derby.masterPin
                            }
                        })
                    Spacer()
                }
            }
            
            if derby.isMaster {
                
                // MARK: --------------- Configuration ---------------
                Group {
                    HStack {
                        Text("Title:")
                            .font(.system(size: 18))
                            .frame(width:60, alignment: .trailing)
                        //.background(.yellow)
                        TextField("Title", text: $derby.title)
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
                        TextField("Event", text: $derby.event)
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
                            ForEach(0 ..< Derby.possibleTracks.count) {
                                Text(Derby.possibleTracks[$0])
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                            .frame(width: 160)
                            .onChange(of: tracksSelector) { _ in
                                derby.heats = []
                                derby.trackCount = tracksSelector + 2
                            }
                    }
                    Spacer().frame(height:50)
                }
                if derby.connected {
                    Group {
                        HStack {
                            Text("Race:").font(.system(size:22)).bold()
                            Button(action: {
                                derby.simulationRunning = false
                                alertAction = .startRace
                                alertTitle = "Reset All Timing Data"
                                alertMessage = "Are you sure?"
                                alertButton = "Go"
                                showAlert = true
                            })  {
                                Text("Start").font(.system(size:22)).bold()
                            }
                            Spacer().frame(width:15)
                            Button(action: {
                                derby.simulationRunning = false
                                derby.tabSelection = Tab.heats.rawValue
                                self.presentationMode.wrappedValue.dismiss()
                            })  {
                                Text("Resume").font(.system(size:22)).bold()
                            }
                        }
                        Spacer().frame(height:40)
                    }
                }
                
                HStack {
                    Spacer()
                    Text("Simulation Testing:").font(.system(size:16)).bold()
                    Button(action: {
                        derby.simulationRunning = true
                        alertAction = .startSimulation
                        alertTitle = "Reset All Timing Data"
                        alertMessage = "Are you sure?"
                        alertButton = "Go"
                        showAlert = true
                    })  {
                        Text("Start").font(.system(size:16)).bold()
                    }
                    Spacer().frame(width:15)
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
            Text("\(derby.appName) \(derby.appVersion)")
                .font(.system(size: 9))
            Text("For info, see: Files App: On My " + (derby.iPad ? "iPad" : "iPhone") + " / Pinewood-Derby / Pinewood-Derby")
                .font(.system(size: 9))
            Text("Copyright © 2021 Randix LLC. All rights reserved.")
                .font(.system(size: 9))
            Spacer().frame(height: 10)
        }
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(alertTitle),
                  message: Text(alertMessage),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text(alertButton)) {
                if alertAction == .serverNotConnected {
                    return
                }
                //derby.saveSettings()
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
            tracksSelector = derby.trackCount - 2
        })
        .onDisappear(perform: {
            derby.saveSettings()
        })
    }
}

