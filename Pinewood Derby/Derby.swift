//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class DerbyEntry: Identifiable {
    init(number: UInt, carName: String, name: String, group: String) {
        self.number = number
        self.carName = carName
        self.name = name
        self.group = group
    }
    
    let id = UUID()             // id for SwiftUI
    var number: UInt
    var carName: String
    var name: String
    var group: String
    
    var times = [Double](repeating: 0.0, count: 6)  // the times for each track
    var average = 0.0
}

class HeatsEntry: Identifiable {
    init(heat: UInt, group: String, tracks: [UInt]) {
        self.heat = heat
        self.group = group
        self.tracks = tracks
    }
    
    let id = UUID()             // id for SwiftUI
    var heat: UInt
    var group: String
    var tracks: [UInt] = []     // car number for each track
    var hasRun = false
}

class Derby: ObservableObject {
    
    @Published var entries: [DerbyEntry] = []
    @Published var heats: [HeatsEntry] = []
    
    let derbyName = "derby.csv"
    let heatsName = "heats.csv"
    
    let girls = "girls"
    let boys = "boys"
    
    let trackCount = 4  // should be 4 or 6 (Settings)
    
    static let shared = Derby()
    private init() {}
    
    func addEntry() {
        print(#function)
    }
    
    func updateEntry() {
        print(#function)
    }
    
    func generateHeats() {
        print(#function)
    }
    
    func readDerbyData() {
        print(#function)
        let name = Settings.shared.docDir.appendingPathComponent(derbyName)
        log("derby file: \(name)")
        var data: String?
        do {
            data = try String(contentsOf: name)
        } catch {
            log("error: \(error)")
            data = ""
        }
        let lines = data!.components(separatedBy: .newlines)
        for line in lines {
            log(line)
            let values = line.split(separator: ",")
            for x in values {
                print(x)
            }
        }
        var derbyEntry = DerbyEntry(number:42, carName:"HWR", name:"Rand", group:boys)
        derbyEntry.times.append(4.5689)
        derbyEntry.times.append(4.5689)
        derbyEntry.times.append(4.5689)
        derbyEntry.times.append(4.5689)
        derbyEntry.average = 4.5689
        
        entries.append(derbyEntry)
        derbyEntry = DerbyEntry(number:43, carName:"Schnellst", name:"Lina", group:girls)
        derbyEntry.times.append(4.5689)
        derbyEntry.times.append(4.5689)
        derbyEntry.times.append(4.5689)
        derbyEntry.times.append(4.5689)
        derbyEntry.average = 4.5689
        entries.append(derbyEntry)
    }
    
    
    func clearTimes() {
        print(#function)
        // first: archive the old data
        saveDerbyData()
    }
    
    func saveDerbyData() {
        print(#function)
    }
    func readHeatsData() {
        print(#function)
    }
    
    func saveHeatsData() {
        print(#function)
    }
}
