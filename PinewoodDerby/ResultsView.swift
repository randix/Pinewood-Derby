//
//  InfoView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct SingleView: View {
    
    @ObservedObject var derby = Derby.shared
    
    let group: String
    let place: Int
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing:3) {
                Spacer().frame(width:10)
                Text(place(group, place)).font(.system(size: 16)).frame(width:25, height: 18)
                //.background(.yellow)
                Text(carForPlace(group, place)).font(.system(size: 16)).frame(width:25, height: 18)
                //.background(.yellow)
                Text(carNameForPlace(group, place)).font(.system(size: 16)).frame(width:100, height: 18, alignment: .leading)
                    .lineLimit(1).minimumScaleFactor(0.4)
                //.background(.yellow)
                Spacer()
            }
            HStack(spacing:3) {
                Spacer().frame(width:43)
                Text(nameForPlace(group, place)).font(.system(size: 16)).frame(width:115, height: 18, alignment: .leading)
                    .lineLimit(1).minimumScaleFactor(0.4)
                //.background(.yellow)
                Text(ageForPlace(group, place)).font(.system(size: 16)).frame(width:25, height: 18)
                //.background(.yellow)
                Spacer()
            }
        }
    }
    
    func getEntry(_ group: String, _ place: Int) -> RacerEntry? {
        var p = place
        if group == derby.overall {
            if place < 0 {
                p = derby.racers.count + place + 1
            }
            let racers = derby.racers.filter { $0.rankOverall == p }
            if racers.count == 0 {
                return(nil)
            }
            return(racers[0])
        } else {
            let groupEntries = derby.racers.filter { $0.group == group }
            if place < 0 {
                p = groupEntries.count + place + 1
            }
            let racers = groupEntries.filter { $0.rankGroup == p }
            if racers.count == 0 {
                return(nil)
            }
            return(racers[0])
        }
    }
    
    func place(_ group: String, _ place: Int) -> String {
        var p = place
        if group == derby.overall {
            if place < 0 {
                p = derby.racers.count + place + 1
            }
        } else {
            let racers = derby.racers.filter { $0.group == group }
            if place < 0 {
                p = racers.count + place + 1
            }
        }
        return(String(p))
    }
    
    func carForPlace(_ group: String, _ place: Int) -> String {
        if let entry = getEntry(group, place) {
            return(String(entry.carNumber))
        } else {
            return("")
        }
    }
    
    func carNameForPlace(_ group: String, _ place: Int) -> String {
        if let entry = getEntry(group, place) {
            return(String(entry.carName))
        } else {
            return("")
        }
    }
    
    func nameForPlace(_ group: String, _ place: Int) -> String {
        if let entry = getEntry(group, place) {
            return(String(entry.firstName + " " + entry.lastName))
        } else {
            return("")
        }
    }
    
    func ageForPlace(_ group: String, _ place: Int) -> String {
        if let entry = getEntry(group, place) {
            return(String(entry.age))
        } else {
            return("")
        }
    }
}

struct ResultsView: View {
    
    @ObservedObject var derby = Derby.shared
    @State var groupSelector = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Results").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:10)
            
            if derby.groups.count == 2 {
                // for exactly 2 groups
                Group {
                    HStack {
                        Spacer().frame(width:10)
                        Text("\(derby.groups[0].group) fastest".capitalized).bold().font(.system(size: 17)).frame(width:170)
                        //.background(.yellow)
                        Spacer()
                        Text("\(derby.groups[0].group) slowest".capitalized).bold().font(.system(size: 17)).frame(width:170)
                        //.background(.yellow)
                        Spacer().frame(width:10)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[0].group, place: 1)
                        SingleView(group: derby.groups[0].group, place: -1)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[0].group, place: 2)
                        SingleView(group: derby.groups[0].group, place: -2)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[0].group, place: 3)
                        SingleView(group: derby.groups[0].group, place: -3)
                    }
                }
                Spacer().frame(height:15)
                
                Group {
                    HStack {
                        Spacer().frame(width:10)
                        Text("\(derby.groups[1].group) fastest".capitalized).bold().font(.system(size: 17)).frame(width:170)
                        //.background(.yellow)
                        Spacer()
                        Text("\(derby.groups[1].group) slowest".capitalized).bold().font(.system(size: 17)).frame(width:170)
                        //.background(.yellow)
                        
                        Spacer().frame(width:10)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[1].group, place: 1)
                        SingleView(group: derby.groups[1].group, place: -1)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[1].group, place: 2)
                        SingleView(group: derby.groups[1].group, place: -2)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[1].group, place: 3)
                        SingleView(group: derby.groups[1].group, place: -3)
                    }
                }
                Spacer().frame(height:15)
                
            } else if derby.groups.count > 1 {
                // show only 1 group and a group selector
                Spacer().frame(height:15)
                HStack {
                    Text("Group:")
                    Picker("Groups", selection: $groupSelector, content: {
                        ForEach(0..<derby.groups.count, id: \.self) {
                            Text(derby.groups[$0].group)
                        }
                    })
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                }
                Spacer().frame(height:10)
                Group {
                    HStack {
                        Spacer().frame(width:10)
                        Text("\(derby.groups[groupSelector].group) fastest".capitalized).bold().font(.system(size: 17)).frame(width:170)
                        //.background(.yellow)
                        Spacer()
                        Text("\(derby.groups[groupSelector].group) slowest".capitalized).bold().font(.system(size: 17)).frame(width:170)
                        //.background(.yellow)
                        
                        Spacer().frame(width:10)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[groupSelector].group, place: 1)
                        SingleView(group: derby.groups[groupSelector].group, place: -1)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[groupSelector].group, place: 2)
                        SingleView(group: derby.groups[groupSelector].group, place: -2)
                    }
                    //Spacer().frame(height:5)
                    HStack {
                        SingleView(group: derby.groups[groupSelector].group, place: 3)
                        SingleView(group: derby.groups[groupSelector].group, place: -3)
                    }
                }
                Spacer().frame(height:45)
            }
            
            Group {
                HStack {
                    Spacer().frame(width:10)
                    Text("overall fastest".capitalized)
                        .bold().font(.system(size: 17)).frame(width:170)
                    //.background(.yellow)
                    Spacer()
                    Text("overall slowest".capitalized)
                        .bold().font(.system(size: 17)).frame(width:170)
                    //.background(.yellow)
                    
                    Spacer().frame(width:10)
                }
                //Spacer().frame(height:5)
                HStack {
                    SingleView(group: derby.overall, place: 1)
                    SingleView(group: derby.overall, place: -1)
                }
                //Spacer().frame(height:5)
                HStack {
                    SingleView(group: derby.overall, place: 2)
                    SingleView(group: derby.overall, place: -2)
                }
                //Spacer().frame(height:5)
                HStack {
                    SingleView(group: derby.overall, place: 3)
                    SingleView(group: derby.overall, place: -3)
                }
            }
            //Spacer().frame(height:15)
            
            Spacer()
        }
    }
}
