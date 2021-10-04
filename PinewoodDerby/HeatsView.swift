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
    let settings = Settings.shared
    
    @State var alertShow = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width:30)
                Spacer().frame(width:62)
                Spacer()
                Text("Heats").font(.system(size: 20)).bold()
                Spacer()
                if settings.isMaster {
                    Button(action: {
                        if derby.heats.count > 0 {
                            alertShow = true
                        } else {
                            alertButtonAction()
                        }
                    }) {
                        VStack {
                            Image(systemName: "wand.and.stars").font(.system(size: 14))
                            Text("Generate").font(.system(size: 14))
                        }
                    }
                    .frame(width:62)
                    //.background(.red)
                } else {
                    Spacer().frame(width:30)
                }
                Spacer().frame(width:30)
            }
            Spacer().frame(height:10)
            
            HStack {
                Spacer().frame(width:115)
                
                Text("T1").bold().frame(width: 25, alignment: .leading).font(.system(size: 18))
                //.background(.yellow)
                Text("T2").bold().frame(width: 25, alignment: .leading).font(.system(size: 18))
                //.background(.yellow)
                if settings.trackCount > 2 {
                    Text("T3").bold().frame(width: 25, alignment: .leading).font(.system(size: 18))
                    //.background(.yellow)
                    if settings.trackCount > 3 {
                        Text("T4").bold().frame(width: 25, alignment: .leading).font(.system(size: 18))
                        //.background(.yellow)
                        if settings.trackCount > 4 {
                            Text("T5").bold().frame(width: 25, alignment: .leading).font(.system(size: 18))
                            //.background(.yellow)
                            if settings.trackCount > 5 {
                                Text("T6").bold().frame(width: 25, alignment: .leading).font(.system(size: 18))
                                //.background(.yellow)
                            }
                            Text("Ran").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                            //.background(.yellow)
                        }
                    }
                }
                Spacer()
            }
            List(derby.heats) { heat in
                HStack {
                    Text(String(heat.heat))
                        .frame(width:25, alignment:.center).font(.system(size: 18))
                        //.background(.yellow)
                    Text(heat.group)
                        .frame(width:42, alignment:.center).font(.system(size: 18))
                        //.background(.yellow)
                    Text(String(heat.tracks[0]))
                        .frame(width:25, alignment:.center).font(.system(size: 18))
                        //.background(.yellow)
                    Text(String(heat.tracks[1]))
                        .frame(width:25, alignment:.center).font(.system(size: 18))
                    //.background(.yellow)
                    if settings.trackCount > 2 {
                        Text(String(heat.tracks[2]))
                            .frame(width:25, alignment:.center).font(.system(size: 18))
                        //.background(.yellow)
                        if settings.trackCount > 3 {
                            Text(String(heat.tracks[3]))
                                .frame(width:25, alignment:.center).font(.system(size: 18))
                            //.background(.yellow)
                            if settings.trackCount > 4 {
                                Text(String(heat.tracks[4]))
                                    .frame(width:25, alignment:.center).font(.system(size: 18))
                                //.background(.yellow)
                                if settings.trackCount > 5 {
                                    Text(String(heat.tracks[5]))
                                        .frame(width:25, alignment:.center).font(.system(size: 18))
                                    //.background(.yellow)
                                }
                            }
                        }
                    }
                    Image(systemName: "square")
                        .frame(width:25, alignment:.center).font(.system(size: 20))
                        //.background(.yellow)
//                    Image(systemName: "checkmark.square")
//                        .frame(width:25, alignment:.center).font(.system(size: 20))
//                        //.background(.yellow)
                    Spacer()
                }
            }
            Spacer()
        }
        .alert(isPresented: self.$alertShow) {
            Alert(title: Text("Generate Heats"),
                  message: Text("This will re-generate the heats! If racing has started, this will invalidate all timing data!\nAre you sure?"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Generate")) { self.alertButtonAction() }
            )
        }
    }
    
    func alertButtonAction() {
        derby.generateHeats()
    }
}
