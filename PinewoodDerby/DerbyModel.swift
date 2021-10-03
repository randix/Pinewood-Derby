//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class DerbyEntry: Identifiable {
    init(number: Int, carName: String, firstName: String, lastName: String, age: Int, group: String) {
        self.carNumber = number
        self.carName = carName
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.group = group
    }
    
    let id = UUID()             // id for SwiftUI
    var carNumber: Int
    var carName: String
    var firstName: String
    var lastName: String
    var age: Int
    var group: String
    
    var times = [Double](repeating: 0.0, count: 6)  // the times for each track
    var average: Double = 0.0
    var rankOverall: Int = 0
    var rankGroup: Int = 0
}

class HeatsEntry: Identifiable {
    init(heat: Int, group: String, tracks: [Int]) {
        self.heat = heat
        self.group = group
        self.tracks = tracks
    }
    
    let id = UUID()             // id for SwiftUI
    var heat: Int
    var group: String
    var tracks: [Int] = []     // car number for each track
    var hasRun = false
}

class Derby: ObservableObject {
    
    @Published var entries: [DerbyEntry] = []
    @Published var heats: [HeatsEntry] = []
    @Published var isMaster: Bool = false
    
    let derbyName = "derby.csv"
    let heatsName = "heats.csv"
    
    var pin: String = "1234"
    
    // list of groups
    let girls = "girls"
    let boys = "boys"
    
    let trackCount = 4  // should be 4 or 6 (Settings)
    
    static let shared = Derby()
    private init() {}
    
    func generateHeats() {
        log("generateHeats")
        
        let boysEntries = entries.filter { $0.group == boys }
        var boysCars = boysEntries.map { $0.carNumber }
        print("boysCount=\(boysCars.count)")
        let boysToAdd = boysCars.count % trackCount != 0 ? trackCount - boysCars.count % trackCount : 0
        for _ in 0..<boysToAdd {
            boysCars.append(0)
        }
        boysCars.sort { $0 < $1 }
        boysCars.shuffle()
        let boysOffset = boysCars.count / trackCount
        print("boysCount=\(boysCars.count) boysOffset=\(boysOffset)")
        
        let girlsEntries = entries.filter { $0.group == girls }
        var girlsCars = girlsEntries.map { $0.carNumber }
        print("girlsCount=\(girlsCars.count)")
        
        let girlsToAdd = girlsCars.count % trackCount != 0 ? trackCount - girlsCars.count % trackCount : 0
        for _ in 0..<girlsToAdd {
            girlsCars.append(0)
        }
        girlsCars.sort { $0 < $1 }
        girlsCars.shuffle()
        let girlsOffset = girlsCars.count / trackCount
        print("girlsCount=\(girlsCars.count) girlsOffset=\(girlsOffset)")
        
        var boysHeats: [HeatsEntry] = []
        var girlsHeats: [HeatsEntry] = []
        
        // generate the boys heats
        for i in 0..<boysCars.count {
            var tracks: [Int] = []
            print("heat \(i+1) ", terminator: "")
            for j in 0..<trackCount {
                var idx = j*boysOffset + i
                if idx >= boysCars.count {
                    idx -= boysCars.count
                }
                tracks.append(boysCars[idx])
                print("\(boysCars[idx]) ", terminator: "")
            }
            print()
            boysHeats.append(HeatsEntry(heat:0, group: boys, tracks: tracks))
        }
        
        // generate the girls heats
        for i in 0..<girlsCars.count {
            var tracks: [Int] = []
            print("heat \(i+1) ", terminator: "")
            for j in 0..<trackCount {
                var idx = j*girlsOffset + i
                if idx >= girlsCars.count {
                    idx -= girlsCars.count
                }
                tracks.append(girlsCars[idx])
                print("\(girlsCars[idx]) ", terminator: "")
            }
            print()
            girlsHeats.append(HeatsEntry(heat:0, group: boys, tracks: tracks))
        }
        print("TODO: merge heats...")
    }
    
    func readDerbyData() {
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
            if values.count < 9 {
                continue
            }
            let d = DerbyEntry(number:Int(values[0])!,
                               carName: String(values[1]),
                               firstName: String(values[2]),
                               lastName: String(values[3]),
                               age: Int(values[4])!,
                               group: String(values[5]))
            d.times[0] = Double(values[6])!
            d.times[0] = Double(values[7])!
            d.times[0] = Double(values[8])!
            d.times[0] = Double(values[9])!
//            d.average = Double(values[10])!
//            d.rank = Int(values[11])!
            // TODO: calulate average
            entries.append(d)
        }
        
        // TODO: calculate ranks
    }
    
    func clearTimes() {
        log("clear times")
        // TODO: first: archive the old data
        saveDerbyData()
    }
    
    func saveDerbyData() {
        var list = [String]()
        for entry in entries {
            let car = "\(entry.carNumber),\(entry.carName),\(entry.firstName),\(entry.lastName),\(entry.age),\(entry.group),"
            let times = String(format: "%6.4f,%6.4f,%6.4f,%6.4f",
                               entry.times[0], entry.times[1], entry.times[2], entry.times[3])
            list.append(car + times)
        }
        let name = Settings.shared.docDir.appendingPathComponent(derbyName)
        let fileData = list.joined(separator: "\n")
        try! fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        log("saved derby data")
    }
    
    func readHeatsData() {
        print(#function)
    }
    
    func saveHeatsData() {
        print(#function)
    }
}
