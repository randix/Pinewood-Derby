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
    @State var showSettings = false
    
    var body: some View {
        
        
        HStack {
            Spacer().frame(width:75)
            Spacer()
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
            //.background(.yellow)
            Spacer()
            Button(action: {
                showSettings = true
            }) {
                VStack {
                    Spacer().frame(height:5)
                    Image(systemName: "gear").font(.system(size: 24))
                    Spacer().frame(height:3)
                    Text("Settings").font(.system(size: 12))
                }
            }
            .frame(width:55)
            //.background(.yellow)
            Spacer().frame(width:20)
        }
        
        // TODO: the tabview doesn't work any better than the previous navigation view....
        TabView {
            RacersView()  .tabItem { Label("Racers",   systemImage: "car.2") }
            HeatsView()   .tabItem { Label("Heats",    systemImage: "flag.2.crossed") }
            TimesView()   .tabItem { Label("Times",    systemImage: "timer") }
            RankingsView().tabItem { Label("Rankings", systemImage: "arrow.up.arrow.down") }
            ResultsView() .tabItem {Label("Results",   systemImage: "tablecells") }
        }
        .sheet(isPresented: $showSettings, content: { SettingsView() })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
