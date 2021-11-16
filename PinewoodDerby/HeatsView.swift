//
//  HeatsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct Times: View {
    
    @ObservedObject var derby = Derby.shared
    
    let heat: Int
    let track: Int
    
    var body: some View {
        VStack {
            if heat < derby.heats.count {
                Text(derby.heats[heat].tracks[track] == 0 ? "-" : String(derby.heats[heat].tracks[track]))
                Text(timeForCar(derby.heats[heat].tracks[track], track))
                    .font(.system(size: 12))
                Text(placeForCar(derby.heats[heat].tracks[track], track))
                    .font(.system(size: 12))
            }
        }
        .frame(width: 43)
        //.background(.yellow)
    }
    
    func timeForCar(_ carNumber: Int, _ track: Int) -> String {
        if carNumber == 0 { return "" }
        let entry = derby.racers.filter { $0.carNumber == carNumber }
        let time = entry[0].times[track]
        if time == 0.0 { return "-" }
        return String(format: "%0.4f", time)
    }
    
    func placeForCar(_ carNumber: Int, _ track: Int) -> String {
        if carNumber == 0 { return "" }
        let entry = derby.racers.filter { $0.carNumber == carNumber }
        let place = entry[0].places[track]
        if place == 0 { return "-" }
        return String(format: "%d", place)
    }
}

struct HeatsView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var derby = Derby.shared
    @ObservedObject var settings = Settings.shared
    
    @State var alertShow = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var nextHeat = 0
    @State var cars = [Int]()
    
    @State var showHeatModal = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width:30)
                
                if settings.isMaster {
                    Button(action: {
                        showHeatModal = true
                    }) {
                        VStack {
                            Image(systemName: "flag.2.crossed").font(.system(size: 14))
                            Text("Special").font(.system(size: 14))
                        }
                    }
                    .frame(width:50)
                    //.background(.red)
                    Spacer().frame(width:5)
                } else {
                    Spacer().frame(width: 55)
                }
                
                Spacer()
                Text("Heats").font(.system(size: 20)).bold()
                Spacer()
                
                Spacer().frame(width:55)
                Spacer().frame(width:30)
            }
            Spacer().frame(height:10)
            
            // MARK: Header
            HStack(spacing: 1) {
                Spacer().frame(width:90)
                
                Text("T1").bold().frame(width: 43).font(.system(size: 18))
                    //.background(.yellow)
                Text("T2").bold().frame(width: 43).font(.system(size: 18))
                    //.background(.yellow)
                if settings.trackCount > 2 {
                    Text("T3").bold().frame(width: 43).font(.system(size: 18))
                        //.background(.yellow)
                    if settings.trackCount > 3 {
                        Text("T4").bold().frame(width: 43).font(.system(size: 18))
                            //.background(.yellow)
                        if settings.trackCount > 4 {
                            Text("T5").bold().frame(width: 43).font(.system(size: 18))
                            //.background(.yellow)
                            if settings.trackCount > 5 {
                                Text("T6").bold().frame(width: 43).font(.system(size: 18))
                                //.background(.yellow)
                            }
                        }
                    }
                }
                Spacer()
            }
            
            // MARK: List
            List {
                ForEach(derby.heats) { heat in
                    HStack(alignment: .top, spacing: 1) {
                        Text(String(heat.heat))
                            .frame(width:25, alignment:.center)
                            //.background(.yellow)
                        Text(heat.group)
                            .frame(width:42, alignment:.center)
                            //.background(.yellow)
                        Times(heat: heat.heat-1, track: 0)
                        Times(heat: heat.heat-1, track: 1)
                        if settings.trackCount > 2 {
                            Times(heat: heat.heat-1, track: 2)
                            if settings.trackCount > 3 {
                                Times(heat: heat.heat-1, track: 3)
                                if settings.trackCount > 4 {
                                    Times(heat: heat.heat-1, track: 4)
                                    if settings.trackCount > 5 {
                                        Times(heat: heat.heat-1, track: 5)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .background(heat.hasRun ? .gray : Color(UIColor.systemBackground))
                    
                    .onTapGesture(perform: {
                        if settings.isMaster {
                            nextHeat = heat.heat
                            cars = heat.tracks
                            alertTitle = "Run Heat \(heat.heat)"
                            alertMessage = "\nCheck cars ready:\n"
                            for i in 0..<settings.trackCount {
                                alertMessage += "Track \(i+1): \(heat.tracks[i] == 0 ? "-" : String(format: "%2d", heat.tracks[i]))"
                                if i < settings.trackCount {
                                    alertMessage += "\n "
                                }
                            }
                            alertShow = true
                        }
                    })
                    
                    .alert(isPresented: self.$alertShow) {
                        Alert(title: Text(self.alertTitle),
                              message: Text(self.alertMessage),
                              primaryButton: .cancel(),
                              secondaryButton: .destructive(Text("Start")) {
                            derby.startHeat(nextHeat, cars)
                        })
                    }
                }
                //.border(.green)
                .listRowInsets(.init())
            }
            //.border(.red)
            .sheet(isPresented: $showHeatModal, content: { HeatsSpecialView() })
            
            Spacer()
            if settings.isMaster {
                Text("Tap on heat to start.")
                Spacer().frame(height: 10)
            }
        }
    }
}
