//
//  RankingsView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct RankingsView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            
            // chevron down
            HStack {
                Spacer().frame(minWidth: 0)
                Image(systemName: "chevron.compact.down").resizable().frame(width: 35, height: 12).opacity(0.3)
                Spacer().frame(minWidth: 0)
            }
            Spacer().frame(height: 20)
            
            // Title
            HStack {
                Spacer()
                Text("Rankings").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:10)
            
            
            
   
            
            Text("\(Settings.shared.appName) \(Settings.shared.appVersion)")
            .padding()
            Spacer()
        }
    }
}
