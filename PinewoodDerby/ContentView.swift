//
//  ContentView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 9/29/21.
//

import SwiftUI

struct ContentView: View {
    
    // TODO: background colors need to be complementary to the light/dark background styles
    // TODO: think about background photos...
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(settings.title).font(.system(size: 24)).bold()//.foregroundColor(.brown)
                Spacer()
            }
            HStack {
                Spacer()
                Text(settings.event).font(.system(size: 16)).bold()//.foregroundColor(.brown)
                Spacer()
            }
        }
        
        // TODO: the tabview doesn't work any better than the previous navigation view....
        TabView {
            RacersView()
                .tabItem {
                    Image(systemName: "car.2")
                    Text("Racers")
                }
            //.background(Color(hue: 1.9500, saturation: 0.2, brightness: 1))
            HeatsView()
                .tabItem {
                    Image(systemName: "flag.2.crossed")
                    Text("Heats")
                }
            //.background(Color(hue: 0.1500, saturation: 0.2, brightness: 1))
            RankingsView()
                .tabItem {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Rankings")
                }
            //.background(Color(hue: 0.1500, saturation: 0.2, brightness: 1))
            ResultsView()
                .tabItem {
                    Image(systemName: "tablecells")
                    Text("Results")
                }
            TimesView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Times")
                }
            //.background(Color(hue: 0.1500, saturation: 0.2, brightness: 1))
            SettingsView()
                .tabItem {
                    Image(systemName: "gear").font(.system(size: 11))
                    Text("Settings").font(.system(size: 11))
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
