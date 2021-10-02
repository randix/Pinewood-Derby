//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class DerbyEntry: Identifiable {
    init(number: UInt, carName: String, firstName: String, lastName: String, age: UInt, group: String) {
        self.carNumber = number
        self.carName = carName
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.group = group
    }
    
    let id = UUID()             // id for SwiftUI
    var carNumber: UInt
    var carName: String
    var firstName: String
    var lastName: String
    var age: UInt
    var group: String
    
    var times = [Double](repeating: 0.0, count: 6)  // the times for each track
    var average: Double = 0.0
    var rankOverall: UInt = 0
    var rankGroup: UInt = 0
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
        print(#function)
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
            let d = DerbyEntry(number:UInt(values[0])!,
                               carName: String(values[1]),
                               firstName: String(values[2]),
                               lastName: String(values[3]),
                               age: UInt(values[4])!,
                               group: String(values[5]))
            d.times[0] = Double(values[6])!
            d.times[0] = Double(values[7])!
            d.times[0] = Double(values[8])!
            d.times[0] = Double(values[9])!
//            d.average = Double(values[10])!
//            d.rank = UInt(values[11])!
            entries.append(d)
        }
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
