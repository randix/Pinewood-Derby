//
//  HeatsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct HeatsView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    @ObservedObject var settings = Settings.shared
    
    @State var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width:30)
                
                Spacer()
                Text("Heats").font(.system(size: 20)).bold()
                Spacer()
               
                Spacer().frame(width:30)
            }
            Spacer().frame(height:10)
            
            HStack {
                Spacer().frame(width:115)
                
                Text("T1").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                //.background(.yellow)
                Text("T2").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                //.background(.yellow)
                if settings.trackCount > 2 {
                    Text("T3").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                    //.background(.yellow)
                    if settings.trackCount > 3 {
                        Text("T4").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                        //.background(.yellow)
                        if settings.trackCount > 4 {
                            Text("T5").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                            //.background(.yellow)
                            if settings.trackCount > 5 {
                                Text("T6").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                                //.background(.yellow)
                            }
                        }
                    }
                }
                Spacer()
            }
            List(derby.heats) { heat in
                VStack(alignment: .leading) {
                    HStack(spacing: 3) {
                        Text(String(heat.heat))
                            .frame(width:25, alignment:.center).font(.system(size: 18))
                            //.background(.yellow)
                        Text(heat.group)
                            .frame(width:42, alignment:.center).font(.system(size: 18))
                            //.background(.yellow)
                        Text(heat.tracks[0] == 0 ? "-" : String(heat.tracks[0]))
                            .frame(width:38, alignment:.center).font(.system(size: 18))
                            //.background(.yellow)
                        Text(heat.tracks[1] == 0 ? "-" : String(heat.tracks[1]))
                            .frame(width:38, alignment:.center).font(.system(size: 18))
                            //.background(.yellow)
                        if settings.trackCount > 2 {
                            Text(heat.tracks[2] == 0 ? "-" : String(heat.tracks[2]))
                                .frame(width:38, alignment:.center).font(.system(size: 18))
                                //.background(.yellow)
                            if settings.trackCount > 3 {
                                Text(heat.tracks[3] == 0 ? "-" : String(heat.tracks[3]))
                                    .frame(width:38, alignment:.center).font(.system(size: 18))
                                    //.background(.yellow)
                                if settings.trackCount > 4 {
                                    Text(heat.tracks[4] == 0 ? "-" : String(heat.tracks[4]))
                                        .frame(width:38, alignment:.center).font(.system(size: 18))
                                        //.background(.yellow)
                                    if settings.trackCount > 5 {
                                        Text(heat.tracks[5] == 0 ? "-" : String(heat.tracks[5]))
                                            .frame(width:38, alignment:.center).font(.system(size: 18))
                                            //.background(.yellow)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    HStack(spacing: 3) {
                        Spacer().frame(width: 70)
                        Text(timeForCar(heat.tracks[0], 0))
                            .frame(width:38, alignment:.center).font(.system(size: 12))
                            .lineLimit(1).minimumScaleFactor(0.4)
                            //.background(.yellow)
                        Text(timeForCar(heat.tracks[1], 1))
                            .frame(width:38, alignment:.center).font(.system(size: 12))
                            .lineLimit(1).minimumScaleFactor(0.4)
                            //.background(.yellow)
                        if settings.trackCount > 2 {
                            Text(timeForCar(heat.tracks[2], 2))
                                .frame(width:38, alignment:.center).font(.system(size: 12))
                                .lineLimit(1).minimumScaleFactor(0.4)
                                //.background(.yellow)
                            if settings.trackCount > 3 {
                                Text(timeForCar(heat.tracks[3], 3))
                                    .frame(width:38, alignment:.center).font(.system(size: 12))
                                    .lineLimit(1).minimumScaleFactor(0.4)
                                    //.background(.yellow)
                                if settings.trackCount > 4 {
                                    Text(timeForCar(heat.tracks[4], 4))
                                        .frame(width:38, alignment:.center).font(.system(size: 12))
                                        .lineLimit(1).minimumScaleFactor(0.4)
                                        //.background(.yellow)
                                    if settings.trackCount > 5 {
                                        Text(timeForCar(heat.tracks[5], 5))
                                            .frame(width:38, alignment:.center).font(.system(size: 12))
                                            .lineLimit(1).minimumScaleFactor(0.4)
                                            //.background(.yellow)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }
    
    func timeForCar(_ carNumber: Int, _ track: Int) -> String {
        //print(#function, carNumber, track)
        if carNumber == 0 { return "" }
        let entry = derby.entries.filter { $0.carNumber == carNumber }
        //for i in 0..<4 {
        //    print(entry[0].times[i], terminator: "")
        //}
        //print()
        let time = entry[0].times[track]
        //print(time)
        if time == 0.0 { return "-" }
        return String(format: "%0.4f", time)
    }
}
