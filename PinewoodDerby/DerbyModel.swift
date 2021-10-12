//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation
import SwiftUI

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
    
    // list of groups
    let girls = "girls"
    let boys = "boys"
    let overall = "overall"
    
    @ObservedObject var settings = Settings.shared
    let rest = REST.shared
    
    var minimumTime =  1.0
    var maximumTime = 20.0
    
    static let shared = Derby()
    private init() {}
    
    func delete(_ entry: DerbyEntry) {
        var idx = 0
        for i in 0..<entries.count {
            if entry.id == entries[i].id {
                idx = i
                break
            }
        }
        print("delete \(entry.carNumber)")
        entries.remove(at: idx)
        // TODO: if heats were generated, this will affect them
        heats = []
        saveHeatsData()
        self.objectWillChange.send()
    }
    
    func generateHeats() {
        log(#function)
        archiveData()
        
        heats = []
        // TODO: clear all timing data
        // TODO: if less members of a group than tracks, need to artificially add members
        
        let boysEntries = entries.filter { $0.group == boys }
        var boysCars = boysEntries.map { $0.carNumber }
        
        boysCars.sort { $0 < $1 }
        boysCars.shuffle()
        let boysOffset = boysCars.count / settings.trackCount
        log("boys count=\(boysCars.count) boys offset=\(boysOffset)")
        
        let girlsEntries = entries.filter { $0.group == girls }
        var girlsCars = girlsEntries.map { $0.carNumber }
        
        girlsCars.sort { $0 < $1 }
        girlsCars.shuffle()
        let girlsOffset = girlsCars.count / settings.trackCount
        log("girls count=\(girlsCars.count)  girls offset=\(girlsOffset)")
        
        var boysHeats: [HeatsEntry] = []
        var girlsHeats: [HeatsEntry] = []
        
        // generate the boys heats
        for i in 0..<boysCars.count {
            var tracks: [Int] = []
            for j in 0..<settings.trackCount {
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
            for j in 0..<settings.trackCount {
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
        let name = Settings.shared.docDir.appendingPathComponent(rest.derbyName)
        log("\(#function) \(name)")
        var data: String?
        do {
            data = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            data = ""
        }
        let lines = data!.components(separatedBy: .newlines)
        for line in lines {
            log(line)
            let values = line.split(separator: ",", omittingEmptySubsequences: false)
            print(values.count)
            if values.count < 6 {
                continue
            }
            let d = DerbyEntry(number:Int(values[0])!,
                               carName: String(values[1]),
                               firstName: String(values[2]),
                               lastName: String(values[3]),
                               age: Int(values[4])!,
                               group: String(values[5]))
            d.times[0] = Double(values[6])!
            d.times[1] = Double(values[7])!
            if settings.trackCount > 2 && values.count > 8 {
                d.times[2] = Double(values[8])!
                if settings.trackCount > 3 && values.count > 9 {
                    d.times[3] = Double(values[9])!
                    if settings.trackCount > 4 && values.count > 10 {
                        d.times[4] = Double(values[10])!
                        if settings.trackCount > 5 && values.count > 11 {
                            d.times[5] = Double(values[11])!
                        }
                    }
                }
            }
            entries.append(d)
        }
        calculateRankingss()
    }
    
    func saveDerbyData() {
        let name = Settings.shared.docDir.appendingPathComponent(rest.derbyName)
        log("\(#function) \(name)")
        var list = [String]()
        for entry in entries {
            let car = "\(entry.carNumber),\(entry.carName),\(entry.firstName),\(entry.lastName),\(entry.age),\(entry.group),"
            let times = String(format: "%6.4f,%6.4f,%6.4f,%6.4f",
                               entry.times[0], entry.times[1], entry.times[2], entry.times[3])
            list.append(car + times)
        }
        let fileData = list.joined(separator: "\n") + "\n"
        do {
            try fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        } catch {
            log("error: \(error.localizedDescription)")
        }
    }
    
    func readHeatsData() {
        let name = Settings.shared.docDir.appendingPathComponent(rest.heatsName)
        log("\(#function) \(name)")
        do {
            let data = try String(contentsOf: name)
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
                log(line)
                let values = line.split(separator: ",", omittingEmptySubsequences: false)
                if values.count < settings.trackCount {
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
        } catch {
            log("error: \(error.localizedDescription)")
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
        let name = Settings.shared.docDir.appendingPathComponent(rest.heatsName)
        let fileData = list.joined(separator: "\n")
        try! fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
    }
  
    // TODO: minimum time, if less than, discard and mark
    // maximum time, if more than, discard and mark

    func calculateRankingss() {
        log(#function)
        
        for entry in entries {
            entry.average = 0.0
            var count = 0
            for i in 0..<settings.trackCount {
                if entry.times[i] > 3.0 && entry.times[i] < 10.0 {
                    count += 1
                    entry.average += entry.times[i]
                }
            }
            if count > 0 {
            entry.average = entry.average / Double(count)
            } else {
                entry.average = 0.0
            }
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
        self.objectWillChange.send()
    }
    
    func archiveData() {
        log(#function)
        
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let archiveURL = docURL.appendingPathComponent("archive")
        if !FileManager.default.fileExists(atPath: archiveURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: archiveURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log(error.localizedDescription)
            }
        }
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let archiveName = formatter.string(from: now)
        let archive = archiveURL.appendingPathComponent(archiveName)
        if !FileManager.default.fileExists(atPath: archive.path) {
            do {
                try FileManager.default.createDirectory(atPath: archive.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log(error.localizedDescription)
            }
        }
        let files = [rest.derbyName, rest.heatsName, rest.settingsName, rest.timesName]
        for f in files {
            let srcURL = docURL.appendingPathComponent(f)
            let dstURL = archive.appendingPathComponent(f)
            do {
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            } catch (let error) {
                print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            }
        }
        // remove heats
        clearTimes()
        saveDerbyData()
    }
    
    
    func clearTimes() {
        log(#function)
        let times = [Double](repeating: 0.0, count: 6)
        for entry in entries {
            entry.times = times
        }
        saveDerbyData()
        self.objectWillChange.send()
    }
    
    func generateTestTimes() {
        log(#function)
        for entry in entries {
            entry.times[0] = Double.random(in: 4..<6.3)
            let t = entry.times[0]
            for i in 1..<settings.trackCount {
                entry.times[i] = Double.random(in: (t-0.2)..<(t+0.2))
            }
        }
        for entry in entries {
            for i in 0..<settings.trackCount {
                print(entry.times[i], terminator: "")
            }
            print("")
        }
        calculateRankingss()
        saveDerbyData()
        self.objectWillChange.send()
    }
}
