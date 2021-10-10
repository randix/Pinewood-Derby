//
//  ContentView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 9/29/21.
//

import SwiftUI

struct ContentView: View {
    
    let settings = Settings.shared
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(settings.title).font(.system(size: 24)).bold()//.foregroundColor(.brown)
                Spacer()
            }
            HStack {
                Spacer()
                Text(settings.subtitle).font(.system(size: 16)).bold()//.foregroundColor(.brown)
                Spacer()
            }
        }
        
        TabView {
            
            //---------------------------------------------------
            RacersView()
            // TODO: background colors need to be complementary to the light/dark background styles
            // TODO: think about background photos...
            //.background(Color(hue: 1.9500, saturation: 0.2, brightness: 1))
                .tabItem {
                    Image(systemName: "car.2")
                    Text("Racers")
                }
            
            //---------------------------------------------------
            HeatsView()
                .tabItem {
                    Image(systemName: "flag.2.crossed")
                    Text("Heats")
                }
            //.background(Color(hue: 0.1500, saturation: 0.2, brightness: 1))
            
            //---------------------------------------------------
            TimesView()
                .tabItem {
                    Image(systemName: "flag.2.crossed")
                    Text("Times")
                }
            //.background(Color(hue: 0.1500, saturation: 0.2, brightness: 1))
            
            //---------------------------------------------------
            ResultsView()
                .tabItem {
                    Image(systemName: "tablecells")
                    Text("Results")
                }
            
            //---------------------------------------------------
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
