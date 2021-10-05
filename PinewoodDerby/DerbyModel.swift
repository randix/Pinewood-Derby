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
    init(heat: Int, group: String, tracks: [Int], hasRun: Bool) {
        self.heat = heat
        self.group = group
        self.tracks = tracks
        self.hasRun = hasRun
    }
    
    let id = UUID()             // id for SwiftUI
    var heat: Int
    var group: String
    var tracks: [Int]           // car number for each track
    var hasRun: Bool
}

class Derby: ObservableObject {
    
    @Published var entries: [DerbyEntry] = []
    @Published var heats: [HeatsEntry] = []
    
    
    let derbyName = "derby.csv"
    let heatsName = "heats.csv"
    
    @Published var isMaster = false
    var pin: String = "1234"
    var trackCount = 4
    
    // list of groups
    let girls = "girls"
    let boys = "boys"
    
    // sorting:
    var sortRankGroup = false
    var sortRankOverall = false
    var sortCarNumber = false
    var sortName = false
    var sortGroup = false
    var sortAge = false
    
    static let shared = Derby()
    private init() {}
    
    func generateHeats() {
        log(#function)
        
        heats = []
        // TODO: archive
        // TODO: clear all timing data
        
        let boysEntries = entries.filter { $0.group == boys }
        var boysCars = boysEntries.map { $0.carNumber }
        let boysToAdd = boysCars.count % trackCount != 0 ? trackCount - boysCars.count % trackCount : 0
        for _ in 0..<boysToAdd {
            boysCars.append(0)
        }
        boysCars.sort { $0 < $1 }
        boysCars.shuffle()
        let boysOffset = boysCars.count / trackCount
        log("boys count=\(boysCars.count) boys added=\(boysToAdd) boys offset=\(boysOffset)")
        
        let girlsEntries = entries.filter { $0.group == girls }
        var girlsCars = girlsEntries.map { $0.carNumber }
        
        let girlsToAdd = girlsCars.count % trackCount != 0 ? trackCount - girlsCars.count % trackCount : 0
        for _ in 0..<girlsToAdd {
            girlsCars.append(0)
        }
        girlsCars.sort { $0 < $1 }
        girlsCars.shuffle()
        let girlsOffset = girlsCars.count / trackCount
        log("girls count=\(girlsCars.count) girls added=\(girlsToAdd) girls offset=\(girlsOffset)")
        
        var boysHeats: [HeatsEntry] = []
        var girlsHeats: [HeatsEntry] = []
        
        // generate the boys heats
        for i in 0..<boysCars.count {
            var tracks: [Int] = []
            for j in 0..<trackCount {
                var idx = j*boysOffset + i
                if idx >= boysCars.count {
                    idx -= boysCars.count
                }
                tracks.append(boysCars[idx])
            }
            boysHeats.append(HeatsEntry(heat:0, group: boys, tracks: tracks, hasRun: false))
        }
        
        // generate the girls heats
        for i in 0..<girlsCars.count {
            var tracks: [Int] = []
            for j in 0..<trackCount {
                var idx = j*girlsOffset + i
                if idx >= girlsCars.count {
                    idx -= girlsCars.count
                }
                tracks.append(girlsCars[idx])
            }
            girlsHeats.append(HeatsEntry(heat:0, group: girls, tracks: tracks, hasRun: false))
        }
        
        var b = 0
        var g = 0
        var heat = 1
        while true {
            if g < girlsHeats.count {
                girlsHeats[g].heat = heat
                heat += 1
                heats.append(girlsHeats[g])
                g += 1
            }
            if b < boysHeats.count {
                boysHeats[b].heat = heat
                heat += 1
                heats.append(boysHeats[b])
                b += 1
            }
            if b >= boysHeats.count && g >= girlsHeats.count {
                break
            }
        }
        
        for i in 0..<heats.count {
            var heat = "\(heats[i].heat) \(heats[i].group) "
            for j in 0..<heats[i].tracks.count {
                heat += "\(heats[i].tracks[j]) "
            }
            log(heat)
        }
        
        self.objectWillChange.send()
        saveHeatsData()
    }
    
    func readDerbyData() {
        let name = Settings.shared.docDir.appendingPathComponent(derbyName)
        log("\(#function) \(name)")
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
            entries.append(d)
        }
        calculateRankingss()
    }
    
    func saveDerbyData() {
        log(#function)
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
    }
    
    func readHeatsData() {
        let name = Settings.shared.docDir.appendingPathComponent(heatsName)
        log("\(#function) \(name)")
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
            if values.count < 4 {
                continue
            }
            let heat = Int(values[0])!
            let group = values[1]
            let tCnt = values.count - 3
            var tracks: [Int] = [Int](repeating: 0, count: tCnt)
            for i in 0..<tCnt {
                tracks[i] = Int(values[i+2])!
            }
            let hasRun = values.last == "true"
            
            let h = HeatsEntry(heat: heat, group: String(group), tracks: tracks, hasRun: hasRun)
            heats.append(h)
        }
        calculateRankingss()
    }
    
    func saveHeatsData() {
        log(#function)
        var list = [String]()
        for entry in heats {
            var heat = "\(entry.heat),\(entry.group),"
            for i in 0..<entry.tracks.count {
                heat.append("\(entry.tracks[i]),")
            }
            heat.append("\(entry.hasRun)")
            list.append(heat)
        }
        let name = Settings.shared.docDir.appendingPathComponent(heatsName)
        let fileData = list.joined(separator: "\n")
        try! fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
    }
    
    func clearTimes() {
        log(#function)
        let times = [Double](repeating: 0.0, count: 6)
        for entry in entries {
            entry.times = times
        }
    }
    
    func generateTestTimes() {
        log(#function)
        for entry in entries {
            entry.times[0] = Double.random(in: 4..<6.3)
            for i in 1..<trackCount {
                let t = entry.times[0]
                entry.times[i] = Double.random(in: (t-0.3)..<(t+0.3))
            }
        }
        calculateRankingss()
        saveDerbyData()
    }
    
    func calculateRankingss() {
        log(#function)
   
        for entry in entries {
            entry.average = 0.0
            var count = 0
            for i in 0..<trackCount {
                if entry.times[i] > 3.0 && entry.times[i] < 10.0 {
                    count += 1
                    entry.average += entry.times[i]
                }
            }
            entry.average = entry.average / Double(count)
        }
        // calculate girls rankings
        let g = entries.filter { $0.group == girls }
        let gRank = g.sorted { $0.average < $1.average }
        var rank = 1
        for gEntry in gRank {
            let entry = entries.filter { $0.carNumber == gEntry.carNumber }[0]
            entry.rankGroup = rank
            rank += 1
        }
        // calculate boys rankings
        let b = entries.filter { $0.group == boys }
        let bRank = b.sorted { $0.average < $1.average }
        rank = 1
        for bEntry in bRank {
            let entry = entries.filter { $0.carNumber == bEntry.carNumber }[0]
            entry.rankGroup = rank
            rank += 1
        }
        // calcuates overall rankings
        let a = entries
        let aRank = a.sorted { $0.average < $1.average }
        rank = 1
        for aEntry in aRank {
            let entry = entries.filter { $0.carNumber == aEntry.carNumber }[0]
            entry.rankOverall = rank
            rank += 1
        }
    }
    
    func archiveData() {
        log(#function)
        // TODO:
        // create archive dir if not exist on todays date/time
        // copy heats/derby/config/log-* into archive dir
        // remove heats
        clearTimes()
        saveDerbyData()
    }
}
