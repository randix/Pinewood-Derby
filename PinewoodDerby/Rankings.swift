//
//  Rankings.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/11/21.
//


import SwiftUI

struct RankingsView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    let settings = Settings.shared
    
    var body: some View {
        VStack {
            
            // Title row - with Rankings and Add buttons
            HStack {
                Spacer()
                Text("Rankings").font(.system(size: 20)).bold()
                    .frame(width:100, alignment: .center)
                //.background(.red)
                Spacer()
            }
            Spacer().frame(height:10)
            
            // Header row buttons for sorting ----------------------------------------
            HStack(spacing: 2) {
                Spacer().frame(width:30)
                Button(action: {
                    derby.entries.sort { $0.group < $1.group }
                    derby.saveDerbyData()
                }) {
                    Text("Group").bold()
                        .frame(width: 44, alignment: .leading)
                        .font(.system(size: 15))
                        //.background(.yellow)
                }
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
                    Text(" # ").bold()
                        .frame(width: 40, alignment: .leading)
                        .font(.system(size: 16))
                        //.background(.yellow)
                }
                Button(action: {
                    derby.entries.sort { $0.lastName + $0.firstName <  $1.lastName + $1.firstName }
                    derby.saveDerbyData()
                }) {
                    Text("Name").bold()
                        .frame(width: 150, alignment: .leading)
                        .font(.system(size: 16))
                        //.background(.yellow)
                }
                Spacer()
            }
            
            // Derby entries --------------------------------------------
            List (derby.entries) { entry in
                VStack(alignment:.leading) {
                    HStack(spacing: 2) {
                        Text(entry.group)
                            .font(.system(size:16))
                            .frame(width: 44, alignment: .center)
                            //.background(.yellow)
                        Text(entry.rankGroup == 0 ? "-" : String(entry.rankGroup))
                            .font(.system(size:16))
                            .frame(width: 42, alignment: .center)
                            //.background(.yellow)
                        Text(entry.rankOverall == 0 ? "-" : String(entry.rankOverall))
                            .font(.system(size:16))
                            .frame(width: 46, alignment: .center)
                            //.background(.yellow)
                        Text(String(format: "#%-2d", entry.carNumber))
                            .font(.system(size:16))
                            .frame(width: 40, alignment: .center)
                            //.background(.yellow)
                        Text(entry.firstName + " " + entry.lastName)
                            .font(.system(size:16))
                            .frame(width: 150, alignment: .leading)
                            .lineLimit(1).minimumScaleFactor(0.4)
                            //.background(.yellow)
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
        }
    }
}
