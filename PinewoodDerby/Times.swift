//
//  Times.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/10/21.
//

import SwiftUI

struct TimesView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    let settings = Settings.shared
    
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
            
            HStack(spacing: 3) {
                Spacer().frame(width:30)
                
                Text("Car").bold().frame(width: 30, alignment: .leading).font(.system(size: 18))
                //.background(.yellow)
                Text("T1").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                //.background(.yellow)
                Text("T2").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                //.background(.yellow)
                if derby.trackCount > 2 {
                    Text("T3").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                    //.background(.yellow)
                    if derby.trackCount > 3 {
                        Text("T4").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                        //.background(.yellow)
                        if derby.trackCount > 4 {
                            Text("T5").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                            //.background(.yellow)
                            if derby.trackCount > 5 {
                                Text("T6").bold().frame(width: 48, alignment: .center).font(.system(size: 18))
                                //.background(.yellow)
                            }
                        }
                    }
                }
                Spacer()
            }
            List(derby.entries) { entry in
                HStack(spacing: 3) {
                    Text(String(entry.carNumber))
                        .frame(width:30, alignment:.center).font(.system(size: 18))
                    //.background(.yellow)
                    Text(entry.times[0] == 0.0 ? "-" : String(format: "%0.4f", entry.times[0]))
                        .frame(width:48, alignment:.center).font(.system(size: 14))
                    //.background(.yellow)
                    Text(entry.times[1] == 0 ? "-" : String(format: "%0.4f", entry.times[1]))
                        .frame(width:48, alignment:.center).font(.system(size: 14))
                    //.background(.yellow)
                    if derby.trackCount > 2 {
                        Text(entry.times[2] == 0 ? "-" : String(format: "%0.4f", entry.times[2]))
                            .frame(width:48, alignment:.center).font(.system(size: 14))
                        //.background(.yellow)
                        if derby.trackCount > 3 {
                            Text(entry.times[3] == 0 ? "-" : String(format: "%0.4f", entry.times[3]))
                                .frame(width:48, alignment:.center).font(.system(size: 14))
                            //.background(.yellow)
                            if derby.trackCount > 4 {
                                Text(entry.times[4] == 0 ? "-" : String(format: "%0.4f", entry.times[4]))
                                    .frame(width:48, alignment:.center).font(.system(size: 14))
                                //.background(.yellow)
                                if derby.trackCount > 5 {
                                    Text(entry.times[5] == 0 ? "-" : String(format: "%0.4f", entry.times[5]))
                                        .frame(width:48, alignment:.center).font(.system(size: 14))
                                    //.background(.yellow)
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
}
