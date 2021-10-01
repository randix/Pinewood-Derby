//
//  RacersView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct RacersView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    
    @State var thisEntry: DerbyEntry?
    @State var showEditModal = false
    @State var showRankingsModal = false
    
    let cWidth  = CGFloat(32)
    let cnWidth = CGFloat(88)
    let nWidth  = CGFloat(130)
    let gWidth  = CGFloat(55)
    let cFont  = CGFloat(18)
    
    let tWidth  = CGFloat(50)
    let tFont  = CGFloat(14)
    
    var body: some View {
        VStack {
            
            // Title row - with Rankings and Add buttons
            HStack {
                Spacer().frame(width:30)
                Button(action: {
                    log("rankings")
                    showRankingsModal = true
                }) {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down.circle").font(.system(size: 14))
                        Text("Rankings").font(.system(size: 14))
                    }
                }
                .frame(width: 60)
                //.background(.red)
                
                Spacer()
                
                Text("Racers").font(.system(size: 20)).bold()
                    .frame(width:100, alignment: .center)
                //.background(.red)
                Spacer()
                Spacer().frame(width:30)
                Button(action: {
                    log("add")
                    thisEntry = nil
                    showEditModal = true
                }) {
                    VStack {
                        Image(systemName: "plus").font(.system(size: 14))
                        Text("Add").font(.system(size: 14))
                    }
                }
                .frame(width:30)
                //.background(.red)
                Spacer().frame(width:30)
            }
            Spacer().frame(height:10)
            
            // Header row buttons for sorting
            HStack {
                Spacer().frame(width:32)
                Button(action: {
                    log("sort on car")
                }) {
                    Text("Car").bold().frame(width: cWidth, alignment: .leading).font(.system(size: cFont))
                        //.background(.green)
                }
                Button(action: {
                    log("sort on car name")
                }) {
                    Text("Car Name").bold().frame(width: cnWidth, alignment: .leading).font(.system(size: cFont))
                        //.background(.gray)
                }
                Button(action: {
                    log("sort on name")
                }) {
                    Text("Name").bold().frame(width: nWidth, alignment: .leading).font(.system(size: cFont))
                        //.background(.green)
                }
                Button(action: {
                    log("sort on group")
                }) {
                    Text("Group").bold().frame(width: gWidth, alignment: .leading).font(.system(size: cFont))
                        //.background(.gray)
                }
                Spacer()
            }
            
            // Derby entries --------------------------------------------
            List (derby.entries) { entry in
                VStack {
                    HStack {
                        Text(String(entry.carNumber))
                            .frame(width: cWidth, alignment: .center).font(.system(size:cFont))
                            //.background(.gray)
                        Text(entry.carName)
                            .frame(width: cnWidth, alignment: .leading).font(.system(size:cFont))
                            //.background(.blue)
                        Text(entry.firstName + " " + entry.lastName)
                            .frame(width: nWidth, alignment: .leading).font(.system(size:cFont))
                            .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                            //.background(.gray)
                        Text(entry.group)
                            .frame(width: gWidth, alignment: .leading).font(.system(size:cFont))
                            //.background(.blue)
                        Spacer()
                    }
                    HStack {
                        Text(String(String(format: "%6.4f", entry.times[0])))
                            .frame(width: tWidth, alignment: .leading).font(.system(size:tFont))
                            //.background(.gray)
                        Text(String(String(format: "%6.4f", entry.times[1])))
                            .frame(width: tWidth, alignment: .leading).font(.system(size:tFont))
                            //.background(.blue)
                        Text(String(String(format: "%6.4f", entry.times[2])))
                            .frame(width: tWidth, alignment: .leading).font(.system(size:tFont))
                            //.background(.gray)
                        Text(String(String(format: "%6.4f", entry.times[3])))
                            .frame(width: tWidth, alignment: .leading).font(.system(size:tFont))
                            //.background(.blue)
                        Spacer().frame(width:50)
                        Text(String(String(format: "%6.4f", entry.average)))
                            .frame(width: tWidth, alignment: .leading).font(.system(size:tFont))
                            //.background(.gray)
                        Spacer()
                    }
                }
                .frame(minWidth:UIScreen.main.bounds.size.width, minHeight: 30)
                .swipeActions {
                    Button {
                        thisEntry = entry
                        showEditModal = true
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    .tint(.yellow)
                    
                    Button {
                        print("Delete")
                        // add confirmation
                        //TODO: Alert
                        
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .frame(width: UIScreen.main.bounds.size.width, height: 40)
            }
            .frame(width: UIScreen.main.bounds.size.width)
            .background(.yellow)
            .sheet(isPresented: $showEditModal, content: { AddRacerView(entry: $thisEntry) })
            .sheet(isPresented: $showRankingsModal, content: { RankingsView() })
            
            Spacer()
        }
    }
}
