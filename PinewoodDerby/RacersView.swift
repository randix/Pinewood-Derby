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
    
    @State var thisEntry: RacerEntry?
    @State var showEditModal = false
    @State var showRankingsModal = false
    
    @State var alertShow = false
    
    var body: some View {
        VStack {
            
            // MARK: Title row - with Rankings and Add buttons
            HStack {
                Spacer().frame(width:35)
                if derby.isMaster {
                    Button(action: {
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
                    Spacer().frame(width:25)
                } else {
                    Spacer().frame(width: 55)
                }
                
                Spacer()
                Text("Racers").font(.system(size: 20)).bold()
                    .frame(width:100, alignment: .center)
                //.background(.red)
                Spacer()
                
                VStack(alignment: .trailing) {
                    if derby.groups.count == 2 {
                        Text("\(derby.groups[0].group): \(derby.racers.filter { $0.group == derby.groups[0].group }.count)")
                            .font(.system(size: 14))
                        Text("\(derby.groups[1].group): \(derby.racers.filter { $0.group == derby.groups[1].group }.count)")
                            .font(.system(size: 14))
                    }
                }
                .frame(width: 80)
                //.background(.yellow)
                Spacer().frame(width:10)
            }
            Spacer().frame(height:10)
            
            // MARK: Header row buttons for sorting ----------------------------------------
            HStack(spacing: 2) {
                if !derby.iPad {
                    Spacer().frame(width: 30)
                }
                Spacer()
                Button(action: {
                    derby.racers.sort { $0.carNumber < $1.carNumber }
                    derby.saveDerby()
                }) {
                    Text(" # Car").bold()
                        .frame(width: 105, alignment: .leading)
                        .font(.system(size: 16))
                        //.background(.yellow)
                }
                Button(action: {
                    derby.racers.sort { $0.lastName + $0.firstName <  $1.lastName + $1.firstName }
                    derby.saveDerby()
                }) {
                    Text("Name").bold()
                        .frame(width: 145, alignment: .leading)
                        .font(.system(size: 16))
                        //.background(.yellow)
                }
                Button(action: {
                    derby.racers.sort { $0.group < $1.group }
                    derby.saveDerby()
                }) {
                    Text("Group")
                        .bold()
                        .frame(width: 50, alignment: .leading)
                        .font(.system(size: 16))
                        //.background(.yellow)
                }
                Button(action: {
                    derby.racers.sort { $0.age < $1.age }
                    derby.saveDerby()
                }) {
                    Text("Age").bold()
                        .frame(width: 34, alignment: .leading)
                        .font(.system(size: 16))
                        //.background(.yellow)
                }
                Spacer()
            }
            
            // MARK: Derby racers --------------------------------------------
            List (derby.racers) { entry in
                VStack(alignment:.leading) {
                    HStack(spacing: 2) {
                        Spacer()
                        Text("\(car2digit(entry.carNumber)) \(entry.carName)")
                            .font(.system(size:16))
                            .frame(width: 105, alignment: .leading)
                            //.background(.yellow)
                        Text(entry.firstName + " " + entry.lastName)
                            .font(.system(size:16))
                            .frame(width: 145, alignment: .leading)
                            .lineLimit(1).minimumScaleFactor(0.4)
                            //.background(.yellow)
                        Text(entry.group)
                            .frame(width: 50, alignment: .leading)
                            .font(.system(size:16))
                            //.background(.yellow)
                        Text(String(entry.age))
                            .font(.system(size:16))
                            .frame(width: 34, alignment: .center)
                            //.background(.yellow)
                        Spacer()
                    }
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
                        Button {
                            thisEntry = entry
                            alertShow = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
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
            .sheet(isPresented: $showEditModal, content: { RacerAddView(entry: $thisEntry) })
            
            Spacer()
            if derby.isMaster {
                Text("Swipe left on racer to edit.")
                Spacer().frame(height: 10)
            }
        }
    }
    
    func car2digit(_ carNumber: Int) -> String {
        return String(format: "%02d", carNumber)
    }
}
