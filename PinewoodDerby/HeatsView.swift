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
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Heats").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:10)
            
            HStack {
                Text("Heat")
                Text("Group")
                Text("Track1")
                Text("Track2")
                Text("Track3")
                Text("Track4")
                if derby.trackCount > 4 {
                    Text("Track5")
                    Text("Track6")
                }
                Text("Ran")
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
    }
}
