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
    
    @State var alertShow = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width:30)
                Spacer().frame(width:62)
                Spacer()
                Text("Heats").font(.system(size: 20)).bold()
                Spacer()
                if derby.isMaster {
                    Button(action: {
                        log("generate")
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
                Text("Heat").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
                Text("Group").bold().frame(width: 60, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
                Text("Trk1").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
                Text("Trk2").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
                Text("Trk3").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
                Text("Trk4").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
                if derby.trackCount > 4 {
                    Text("Trk5").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    Text("Trk6").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                }
                Text("Ran").bold().frame(width: 40, alignment: .leading).font(.system(size: 18))
                    .background(.yellow)
            }
            List(derby.heats) { heat in
                HStack {
                    Text(String(heat.heat))
                    Text(heat.group)
                    Text(String(heat.tracks[0]))
                    Text(String(heat.tracks[1]))
                    Text(String(heat.tracks[2]))
                    Text(String(heat.tracks[3]))
                    if derby.trackCount > 4 {
                        Text(String(heat.tracks[4]))
                        Text(String(heat.tracks[5]))
                    }
                }
            }
            Spacer()
        }
        .alert(isPresented: self.$alertShow) {
            Alert(title: Text("Generate Heats"),
                  message: Text("Are you sure?"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Generate")) {
                self.alertButtonAction()
            }
            )
        }
    }
    
    func alertButtonAction() {
        derby.generateHeats()
    }
}
