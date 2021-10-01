//
//  InfoView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/1/21.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Information").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:10)
            
            Text("\(Settings.shared.appName) \(Settings.shared.appVersion)")
            .padding()
            Spacer()
        }
    }
}
