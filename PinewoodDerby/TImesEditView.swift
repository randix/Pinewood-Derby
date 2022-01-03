//
//  EditTImesView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/11/21.
//

import SwiftUI

struct TimesEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var entry: RacerEntry?
    
    @ObservedObject var derby = Derby.shared
    
    @State var id = UUID()
    @State var carNumber = 0
    @State var times = [Double](repeating: 0.0, count: 6)  // the times for each track
    @State var ignores = [Bool](repeating: false, count: 6)
    
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
                
                // Title
                HStack {
                    Spacer()
                    Text("Edit Tracks").font(.system(size: 20)).bold()
                    Spacer()
                }
                Spacer().frame(height:30)
            }
            Group {
                Text("Car Number: \(carNumber)")
                    .font(.system(size:18))
                Spacer().frame(height:20)
            }
            HStack {
                Text("Track 1:")
                    .font(.system(size: 18))
                Text(times[0] == 0.0 ? "-" : String(format: "%0.4f", times[0]))
                    .font(.system(size: 18))
                Spacer().frame(width:30)
                Text("Ignore:")
                    .font(.system(size: 18))
                Button(action: {
                    ignores[0] = !ignores[0]
                }) {
                    if ignores[0] {
                        Image(systemName: "checkmark.square")
                            .font(.system(size: 18))
                    } else {
                        Image(systemName: "square")
                            .font(.system(size: 18))
                    }
                }
            }
            Spacer().frame(height:10)
            HStack {
                Text("Track 2:")
                    .font(.system(size: 18))
                Text(times[1] == 0.0 ? "-" : String(format: "%0.4f", times[1]))
                    .font(.system(size: 18))
                Spacer().frame(width:30)
                Text("Ignore:")
                    .font(.system(size: 18))
                Button(action: {
                    ignores[1] = !ignores[1]
                }) {
                    if ignores[1] {
                        Image(systemName: "checkmark.square")
                            .font(.system(size: 18))
                    } else {
                        Image(systemName: "square")
                            .font(.system(size: 18))
                    }
                }
            }
            Spacer().frame(height:10)
            if derby.trackCount > 2 {
                HStack {
                    Text("Track 3:")
                        .font(.system(size: 18))
                    Text(times[2] == 0.0 ? "-" : String(format: "%0.4f", times[2]))
                        .font(.system(size: 18))
                    Spacer().frame(width:30)
                    Text("Ignore:")
                        .font(.system(size: 18))
                    Button(action: {
                        ignores[2] = !ignores[2]
                    }) {
                        if ignores[2] {
                            Image(systemName: "checkmark.square")
                                .font(.system(size: 18))
                        } else {
                            Image(systemName: "square")
                                .font(.system(size: 18))
                        }
                    }
                }
                Spacer().frame(height:10)
                if derby.trackCount > 3 {
                    HStack {
                        Text("Track 4:")
                            .font(.system(size: 18))
                        Text(times[3] == 0.0 ? "-" : String(format: "%0.4f", times[3]))
                            .font(.system(size: 18))
                        Spacer().frame(width:30)
                        Text("Ignore:")
                            .font(.system(size: 18))
                        Button(action: {
                            ignores[3] = !ignores[3]
                        }) {
                            if ignores[3] {
                                Image(systemName: "checkmark.square")
                                    .font(.system(size: 18))
                            } else {
                                Image(systemName: "square")
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    Spacer().frame(height:10)
                    if derby.trackCount > 4 {
                        HStack {
                            Text("Track 5:")
                                .font(.system(size: 18))
                            Text(times[4] == 0.0 ? "-" : String(format: "%0.4f", times[4]))
                                .font(.system(size: 18))
                            Spacer().frame(width:30)
                            Text("Ignore:")
                                .font(.system(size: 18))
                            Button(action: {
                                ignores[4] = !ignores[4]
                            }) {
                                if ignores[4] {
                                    Image(systemName: "checkmark.square")
                                        .font(.system(size: 18))
                                } else {
                                    Image(systemName: "square")
                                        .font(.system(size: 18))
                                }
                            }
                        }
                        Spacer().frame(height:10)
                        if derby.trackCount > 5 {
                            HStack {
                                Text("Track 6:")
                                    .font(.system(size: 18))
                                Text(times[5] == 0.0 ? "-" : String(format: "%0.4f", times[5]))
                                    .font(.system(size: 18))
                                Spacer().frame(width:30)
                                Text("Ignore:")
                                    .font(.system(size: 18))
                                Button(action: {
                                    ignores[5] = !ignores[5]
                                }) {
                                    if ignores[5] {
                                        Image(systemName: "checkmark.square")
                                            .font(.system(size: 18))
                                    } else {
                                        Image(systemName: "square")
                                            .font(.system(size: 18))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Spacer().frame(height: 30)
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18))
                }
                
                Spacer().frame(width: 40)
                
                Button(action: {
                    if true == updateTimes() {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                }) {
                    Text("Save")
                        .font(.system(size: 18))
                }
                Spacer()
            }
            Spacer()
        }
        .onAppear(perform: {
            if let entry = entry {
                self.id = entry.id
                carNumber = entry.carNumber
                times = entry.times
                ignores = entry.ignores
            }
        })
    }
    
    func updateTimes() -> Bool {
        // find the entry in the array....
        if let index = derby.racers.firstIndex(where: { $0.id == id}) {
            derby.racers[index].ignores = ignores
        }
        derby.saveDerby()
        derby.objectWillChange.send()
        return true
    }
}
