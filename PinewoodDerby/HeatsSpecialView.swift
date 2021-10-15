//
//  HeatsSpecialView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/14/21.
//

import SwiftUI

struct HeatsSpecialView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var settings = Settings.shared
    
    @State var cars = [String](repeating: "", count: Settings.maxTracks)
    @State var group = ""
    
    @State var alertShow = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertButton = ""
    
    let derby = Derby.shared
    
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
                Spacer().frame(height: 40)
                
                // Title
                HStack {
                    Spacer()
                    Text("Special Heat").font(.system(size: 20)).bold()
                    Spacer()
                }
                Spacer().frame(height:30)
            }
            
            Group {
                HStack {
                    Text("Track 1:").font(.system(size: 18))
                    TextField("88", text: $cars[0])
                        .font(.system(size: 18))
                        .frame(width:50)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Track 2:").font(.system(size: 18))
                    TextField("88", text: $cars[1])
                        .font(.system(size: 18))
                        .frame(width:50)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .keyboardType(.numberPad)
                }
                if settings.trackCount > 2 {
                    HStack {
                        Text("Track 3:").font(.system(size: 18))
                        TextField("88", text: $cars[2])
                            .font(.system(size: 18))
                            .frame(width:50)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                            .keyboardType(.numberPad)
                    }
                    if settings.trackCount > 3 {
                        HStack {
                            Text("Track 4:").font(.system(size: 18))
                            TextField("88", text: $cars[3])
                                .font(.system(size: 18))
                                .frame(width:50)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                                .keyboardType(.numberPad)
                        }
                        if settings.trackCount > 4 {
                            HStack {
                                Text("Track 5:").font(.system(size: 18))
                                TextField("88", text: $cars[4])
                                    .font(.system(size: 18))
                                    .frame(width:50)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                                    .keyboardType(.numberPad)
                            }
                            if settings.trackCount > 5 {
                                HStack {
                                    Text("Track 6:").font(.system(size: 18))
                                    TextField("88", text: $cars[5])
                                        .font(.system(size: 18))
                                        .frame(width:50)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                                        .keyboardType(.numberPad)
                                }
                            }
                        }
                    }
                }
                Spacer().frame(height:10)
            }
            
            HStack {
                Spacer().frame(width: 20)
                Text("Group: ").font(.system(size: 18))
                Group {
                    if group == derby.girls {
                        Image(systemName: "circle.fill").font(.system(size: 14))
                    } else {
                        Image(systemName: "circle").font(.system(size: 14))
                    }
                    Text(derby.girls).font(.system(size: 18))
                }
                .onTapGesture {
                    group = derby.girls
                }
                Spacer().frame(width:20)
                Group {
                    if group == derby.boys {
                        Image(systemName: "circle.fill").font(.system(size: 14))
                    } else {
                        Image(systemName: "circle").font(.system(size: 14))
                    }
                    Text(derby.boys).font(.system(size: 18))
                }
                .onTapGesture {
                    group = derby.boys
                }
            }
            
            Spacer().frame(height:30)
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18))
                }
                Spacer().frame(width: 40)
                Button(action: {
                    var carNumbers = [Int](repeating: 0, count: Settings.maxTracks)
                    for i in 0..<settings.trackCount {
                        if let c = Int(cars[i]) {
                            let car = derby.entries.filter { c == $0.carNumber }
                            if car.count != 1 {
                                alertTitle = "Invalid Car Number"
                                alertMessage = "Car number \(c) is not found in the racer entries."
                                alertButton = "Ok"
                                alertShow = true
                                return
                            }
                            carNumbers[i] = Int(cars[i])!
                        }
                    }
                    derby.heats.append(HeatsEntry(heat: derby.heats.count+1, group: group, tracks: carNumbers, hasRun: false) )
                    derby.startHeat(derby.heats.count, carNumbers)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Start")
                        .font(.system(size: 18))
                }
            }
            
            Spacer()
        }
        .alert(isPresented: self.$alertShow) {
            Alert(title: Text(self.alertTitle),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text(self.alertButton),
                                          action: { })
            )
        }
    }
}
