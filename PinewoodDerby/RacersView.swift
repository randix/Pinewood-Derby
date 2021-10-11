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
    let settings = Settings.shared
    
    @State var thisEntry: DerbyEntry?
    @State var showEditModal = false
    @State var showRankingsModal = false
    
    @State var alertShow = false
    
    var body: some View {
        VStack {
            
            // Title row - with Rankings and Add buttons
            HStack {
                Spacer().frame(width:35)
                if derby.isMaster {
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
                    Spacer().frame(width:5)
                } else {
                    Spacer().frame(width: 35)
                }
                
                Spacer()
                Text("Racers").font(.system(size: 20)).bold()
                    .frame(width:100, alignment: .center)
                //.background(.red)
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("girls: \(derby.entries.filter { $0.group == derby.girls }.count)").font(.system(size: 14))
                    Text("boys: \(derby.entries.filter { $0.group == derby.boys }.count)").font(.system(size: 14))
                }
                .frame(width: 60)
                //.background(.yellow)
                Spacer().frame(width:10)
            }
            Spacer().frame(height:10)
            
            // Header row buttons for sorting ----------------------------------------
            HStack {
                Spacer().frame(width:32)
                
                Button(action: {
                    derby.entries.sort { $0.group + String(format: "%03d", $0.rankGroup) < $1.group + String(format: "%03d", $1.rankGroup) }
                    derby.saveDerbyData()
                }) {
                    VStack {
                        Text("Rank").bold().frame(width: 42, alignment: .center).font(.system(size: 13))
                        Text("Group").bold().frame(width: 42, alignment: .center).font(.system(size: 13))
                    }
                    //.background(.yellow)
                }
                Button(action: {
                    derby.entries.sort { $0.rankOverall < $1.rankOverall }
                    derby.saveDerbyData()
                }) {
                    VStack {
                        Text("Rank").bold().frame(width: 46, alignment: .center).font(.system(size: 13))
                        Text("Overall").bold().frame(width: 46, alignment: .center).font(.system(size: 13))
                    }
                    //.background(.yellow)
                }
                Button(action: {
                    derby.entries.sort { $0.carNumber < $1.carNumber }
                    derby.saveDerbyData()
                }) {
                    HStack {
                        Image(systemName: "number").frame(width: 20, alignment: .leading).font(.system(size: 18))
                        Text("Car").bold().frame(width: 150, alignment: .leading).font(.system(size: 18))
                    }
                    //.background(.yellow)
                }
                Button(action: {
                    derby.entries.sort { $0.group < $1.group }
                    derby.saveDerbyData()
                }) {
                    Text("Group")
                        .bold()
                        .frame(width: 54, alignment: .leading)
                        .font(.system(size: 18))
                    //background(.yellow)
                }
                Spacer()
            }
            Spacer().frame(height:5)
            HStack {
                Spacer().frame(width:137)
                Button(action: {
                    derby.entries.sort { $0.lastName + $0.firstName <  $1.lastName + $1.firstName }
                    derby.saveDerbyData()
                }) {
                    Text("Name").bold().frame(width: 180, alignment: .leading).font(.system(size: 18))
                    //.background(.yellow)
                }
                Spacer().frame(width:10)
                Button(action: {
                    derby.entries.sort { $0.age < $1.age }
                    derby.saveDerbyData()
                }) {
                    Text("Age").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    //.background(.yellow)
                }
                
                Spacer()
            }
            
            // Derby entries --------------------------------------------
            List (derby.entries) { entry in
                VStack(alignment:.leading) {
                    HStack {
                        Text(entry.rankGroup == 0 ? "-" : String(entry.rankGroup))
                            .font(.system(size:18))
                            .frame(width: 42, alignment: .center)
                        //.background(.yellow)
                        Text(entry.rankOverall == 0 ? "-" : String(entry.rankOverall))
                            .font(.system(size:18))
                            .frame(width: 46, alignment: .center)
                        //.background(.yellow)
                        Text(String(entry.carNumber))
                            .font(.system(size:18))
                            .lineLimit(1).minimumScaleFactor(0.4)
                            .frame(width: 26, alignment: .center)
                        //.background(.yellow)
                        Text(entry.carName)
                            .font(.system(size:18))
                            .frame(width: 142, alignment: .leading)
                            .lineLimit(1).minimumScaleFactor(0.4)
                        //.background(.yellow)
                        Text(entry.group)
                            .frame(width: 54, alignment: .leading)
                            .font(.system(size:18))
                        //.background(.yellow)
                        Spacer()
                    }
                    HStack {
                        Spacer().frame(width:105)
                        Text(entry.firstName + " " + entry.lastName)
                            .font(.system(size:18))
                            .frame(width: 185, alignment: .leading)
                            .lineLimit(1).minimumScaleFactor(0.4)
                        //.background(.yellow)
                        Text(String(entry.age))
                            .font(.system(size:18))
                            .frame(width: 50, alignment: .leading)
                        //.background(.yellow)
                        
                        Spacer()
                    }
                }
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
                        thisEntry = entry
                        alertShow = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .alert(isPresented: self.$alertShow) {
                    Alert(title: Text("Delete Car Number \(thisEntry!.carNumber)"),
                          message: Text("Are you sure?"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Delete")) { derby.delete(thisEntry!) }
                    )
                }
            }
            .frame(minHeight:100)
            .sheet(isPresented: $showEditModal, content: { AddRacerView(entry: $thisEntry) })
        
            Spacer()
        }
    }
}
