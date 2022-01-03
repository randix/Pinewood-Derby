//
//  ContentView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 9/29/21.
//

import SwiftUI

enum Tab: Int  {
    case racers
    case heats
    case times
    case rankings
    case results
}

struct ContentView: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var derby = Derby.shared
    
    @State var showSettings = false
    
    var body: some View {
        
        HStack {
            Spacer().frame(width:75)
            Spacer()
            VStack {
                HStack {
                    Spacer()
                    Text(derby.title).font(.system(size: 24)).bold()//.foregroundColor(.brown)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text(derby.event).font(.system(size: 16)).bold()//.foregroundColor(.brown)
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
                    Image(systemName: "gear")
                        .font(.system(size: 24))
                        .foregroundColor(derby.connected ? .blue : .red)
                    Spacer().frame(height:3)
                    Text("Settings")
                        .font(.system(size: 12))
                        .foregroundColor(derby.connected ? .blue : .red)
                }
            }
            .frame(width:55)
            //.background(.yellow)
            Spacer().frame(width:20)
        }
        
        TabView(selection: $derby.tabSelection) {
            RacersView()  .tabItem { Label("Racers",   systemImage: "car.2") }
            .tag(Tab.racers.rawValue)
            HeatsView()   .tabItem { Label("Heats",    systemImage: "flag.2.crossed") }
            .tag(Tab.heats.rawValue)
            TimesView()   .tabItem { Label("Times",    systemImage: "timer") }
            .tag(Tab.times.rawValue)
            RankingsView().tabItem { Label("Rankings", systemImage: "arrow.up.arrow.down") }
            .tag(Tab.rankings.rawValue)
            ResultsView() .tabItem {Label("Results",   systemImage: "tablecells") }
            .tag(Tab.results.rawValue)
        }
        .sheet(isPresented: $showSettings, content: { SettingsView() })
        
        .onAppear(perform:  {
            //derby.clearTimes()
            derby.readFilesFromServer()
            derby.startReadTimes()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
