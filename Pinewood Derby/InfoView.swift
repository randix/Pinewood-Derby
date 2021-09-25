//
//  InfoView.swift
//
//  Created by Rand Dow on 9/20/21.
//


import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack {
            Text("\(Settings.shared.appName) \(Settings.shared.appVersion)")
            .padding()
        }
        .navigationBarTitle("Info", displayMode: .inline)
    }
}

// show version, help info....
