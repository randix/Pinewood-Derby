//
//  HeatsStartView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 12/31/21.
//

import SwiftUI

struct TrackView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let track: Int
    let car: Int
    
    let derby = Derby.shared
    
    var body: some View {
        VStack {
        HStack(spacing: 1) {
            Text("Track \(track):  ")
                .font(.system(size: 24))
                .frame(width:90)
                //.background(.yellow)
            if car == 0 {
                Text("-")
                    .font(.system(size: 24))
                    .frame(width:35)
                    .background(.yellow)
                Text("").frame(width:150)
                Text("").frame(width:145)
                Text("").frame(width:34)
            } else {
                Text("\(car)")
                    .font(.system(size: 24))
                    .frame(width:35)
                    //.background(.yellow)
                Text(getCarName(car))
                    .font(.system(size: 20))
                    .frame(width:115, alignment: .leading)
                    .lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                Text(getName(car))
                    .font(.system(size: 20))
                    .frame(width:145, alignment: .leading)
                    .lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
                Text(getAge(car))
                    .font(.system(size: 20))
                    .frame(width:34)
                    .lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.yellow)
            }
        }
            Spacer().frame(height: 10)
        }
    }
    
    func getCarName(_ carNumber: Int) -> String {
        let entry = derby.racers.filter { $0.carNumber == carNumber }[0]
        return entry.carName
    }
    
    func getName(_ carNumber: Int) -> String {
        let entry = derby.racers.filter { $0.carNumber == carNumber }[0]
        return entry.firstName + " " + entry.lastName
    }
    
    func getAge(_ carNumber: Int) -> String {
        let entry = derby.racers.filter { $0.carNumber == carNumber }[0]
        return entry.age
    }
}

struct HeatsStartView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var derby = Derby.shared
  
    var body: some View {
        VStack {
            Group {
                Spacer().frame(height: 20)
                
                // chevron down
                HStack {
                    Spacer().frame(minWidth: 0)
                    Image(systemName: "chevron.compact.down").resizable().frame(width: 35, height: 12).opacity(0.3)
                    Spacer().frame(minWidth: 0)
                }
                Spacer().frame(height: 40)
                
                // Title
                HStack {
                    Spacer()
                    Text("Run Heat \(derby.heat)").font(.system(size: 22)).bold()
                    Spacer()
                }
                Spacer().frame(height:30)
            }
            
            TrackView(track: 1, car: derby.trackCars[0])
            TrackView(track: 2, car: derby.trackCars[1])
            if derby.trackCars.count > 2 {
                TrackView(track: 3, car: derby.trackCars[2])
                if derby.trackCars.count > 3 {
                    TrackView(track: 4, car: derby.trackCars[3])
                    if derby.trackCars.count > 4 {
                        TrackView(track: 5, car: derby.trackCars[4])
                        if derby.trackCars.count > 5 {
                            TrackView(track: 6, car: derby.trackCars[5])
                        }
                    }
                }
            }
            
            Spacer().frame(height:30)
            
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 20))
                        .bold()
                }
                Spacer().frame(width: 40)
                Button(action: {
                    derby.startHeat(derby.heat, derby.trackCars)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Start")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                        .bold()
                }
            }
            
            Spacer()
        }
    }
}

