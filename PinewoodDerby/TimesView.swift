//
//  Times.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/10/21.
//

import SwiftUI

struct PlaceView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let time: Double
    let place: Int
    let ignore: Bool
    
    var body: some View {
        VStack {
            Text(time == 0.0 ? "-" : String(format: "%0.4f", time))
                .font(.system(size: 14))
                .foregroundColor(ignore ? .red : colorScheme == .dark ? .white : .black)
            Text(place == 0 ? "-" : String(format: "%d", place))
                .font(.system(size: 14))
                .foregroundColor(ignore ? .red : colorScheme == .dark ? .white : .black)
        }
        .frame(width: 50, alignment: .center)
        //.background(.yellow)
    }
}

struct TimesView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    
    @State var thisEntry: RacerEntry?
    @State var showEditModal = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width:30)
                
                Spacer()
                Text("Times").font(.system(size: 20)).bold()
                Spacer()
                
                Spacer().frame(width:30)
            }
            Spacer().frame(height:10)
            
            // MARK: Headings -------------------------------------
            HStack(spacing: 1) {
                Spacer()
                if !derby.iPad {
                    Spacer().frame(width: 20)
                }
                Text("Car").bold().frame(width: 32, alignment: .center).font(.system(size: 18))
                //.background(.yellow)
                Text("T1").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                //.background(.yellow)
                Text("T2").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                //.background(.yellow)
                if derby.trackCount > 2 {
                    Text("T3").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                        //.background(.yellow)
                } else {
                    Text("").frame(width: 48)
                        //.background(.yellow)
                }
                if derby.trackCount > 3 {
                    Text("T4").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                        //.background(.yellow)
                } else {
                    Text("").frame(width: 48)
                        //.background(.yellow)
                }
                if derby.trackCount > 4 {
                    Text("T5").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                        //.background(.yellow)
                } else {
                    Text("").frame(width: 48)
                        //.background(.yellow)
                }
                if derby.trackCount > 5 {
                    Text("T6").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                        //.background(.yellow)
                } else {
                    Text("").frame(width: 48)
                        //.background(.yellow)
                }
                Spacer()
            }
            HStack(spacing: 3) {
                Spacer()
                Spacer().frame(width:230)
                Text("Points").bold().frame(width: 70).font(.system(size: 16))
                    //.background(.yellow)
                Text("Average").bold().frame(width: 70).font(.system(size: 16))
                    //.background(.yellow)
                Spacer()
            }
            
            // MARK: Times ---------------------------------------------------
            List(derby.racers.sorted { $0.carNumber < $1.carNumber } ) { entry in
                HStack(alignment: .top, spacing: 1) {
                    Spacer()
                    Text(String(entry.carNumber))
                        .frame(width:32, alignment: .center)
                        //.background(.yellow)
                    PlaceView(time: entry.times[0], place: entry.places[0], ignore: entry.ignores[0])
                    PlaceView(time: entry.times[1], place: entry.places[1], ignore: entry.ignores[1])
                    if derby.trackCount > 2 {
                        PlaceView(time: entry.times[2], place: entry.places[2], ignore: entry.ignores[2])
                    } else {
                        Text("").frame(width: 50)
                            //.background(.yellow)
                    }
                    if derby.trackCount > 3 {
                        PlaceView(time: entry.times[3], place: entry.places[3], ignore: entry.ignores[3])
                    } else {
                        Text("").frame(width: 50)
                            //.background(.yellow)
                    }
                    if derby.trackCount > 4 {
                        PlaceView(time: entry.times[4], place: entry.places[4], ignore: entry.ignores[4])
                    } else {
                        Text("").frame(width: 50)
                            //.background(.yellow)
                    }
                    if derby.trackCount > 5 {
                        PlaceView(time: entry.times[5], place: entry.places[5], ignore: entry.ignores[5])
                    } else {
                        Text("").frame(width: 50)
                            //.background(.yellow)
                    }
                    Spacer()
                }
                .swipeActions {
                    if derby.isMaster {
                        Button {
                            thisEntry = entry
                            showEditModal = true
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.teal)
                    }
                }
                
                HStack(spacing: 3) {
                    Spacer()
                    Spacer().frame(width:200)
                    Text(entry.points == 0 ? "-" : String(format: "%d", entry.points))
                        .frame(width:70, alignment:.center).font(.system(size: 14))
                    Text(entry.average == 0.0 ? "-" : String(format: "%0.4f", entry.average))
                        .frame(width:70, alignment:.center).font(.system(size: 14))
                    //.background(.yellow)
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $showEditModal, content: { TimesEditView(entry: $thisEntry) })
            
            Spacer()
            if derby.isMaster {
                Text("Swipe left on car times to edit.")
                Spacer().frame(height: 10)
            }
        }
    }
}
