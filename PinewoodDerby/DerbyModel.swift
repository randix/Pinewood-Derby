//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation
import SwiftUI

class RacerEntry: Identifiable {
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
    
    var times = [Double](repeating: 0.0, count: Settings.maxTracks)  // the times for each track
    var ignores = [Bool](repeating: false, count: Settings.maxTracks)
    var firstSim = 0                // track number of first simulated time
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

class GroupEntry: Identifiable {
    init(group: String) {
        self.group = group
    }
    let id = UUID()
    var group: String
}

class Derby: ObservableObject {
    
    @Published var racers: [RacerEntry] = []
    @Published var heats: [HeatsEntry] = []
    @Published var groups: [GroupEntry] = []
    
    let girls = "girls"
    let boys = "boys"
    
    let overall = "overall"
    
    @ObservedObject var settings = Settings.shared
    let rest = REST.shared
    
    var minimumTime =  2.0
    var maximumTime = 20.0
    
    @Published var tabSelection = Tab.racers.rawValue
    @Published var simulationRunning = false
    var timesTimer: Timer?
    let timesTimerInterval = 1
    var nextHeat = 0

    static let shared = Derby()
    private init() {}
    
    // MARK: Delete single entry
    
    // called from RacersView to delete an entry
    func delete(_ entry: RacerEntry) {
        archiveData()
        var idx = 0
        for i in 0..<racers.count {
            if entry.id == racers[i].id {
                idx = i
                break
            }
        }
        log("\(#function) \(entry.carNumber)")
        racers.remove(at: idx)
        
        clearTimes()
        generateHeats()
        self.objectWillChange.send()
    }
    
    // prepare to start racing (or simulation)
    func clearTimes() {
        log(#function)
        let times = [Double](repeating: 0.0, count: Settings.maxTracks)
        let ignores = [Bool](repeating: false, count: Settings.maxTracks)
        for entry in racers {
            entry.times = times
            entry.ignores = ignores
            entry.firstSim = 0
            entry.average = 0.0
            entry.rankGroup = 0
            entry.rankOverall = 0
        }
        removeFile(rest.timesName)
        
        saveRacers()
        objectWillChange.send()
    }
    // MARK: Racing
    
    func startRacing() {
        log(#function)
        archiveData()
        clearTimes()
        removeFile(rest.timesLogName)
        generateHeats()
        rest.saveFilesToServer()
    }
    
    func startHeat(_ heat: Int, _ cars: [Int]) {
        // start the read times timer
        timesTimer?.invalidate()
        readTimes()
        
        var heatData = "\(heat)"
        for i in 0..<settings.trackCount {
            heatData += ",\(cars[i])"
        }
        log("Heat: \(heatData)")
        do {
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let nextheatURL = docURL.appendingPathComponent(rest.nextHeatName)
            try heatData.write(toFile: nextheatURL.path, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
            return
        }
        if simulationRunning {
            simulateHeat()
        }
    }
    
    // MARK: Simulator
    
    func simulate() {
        log(#function)
        simulationRunning = true
        startRacing()
    }
    
    func simulateHeat() {
        log(#function)
        let nextheatURL = settings.docDir.appendingPathComponent(rest.nextHeatName)
        let timesURL = settings.docDir.appendingPathComponent(rest.timesName)
        do {
            let line = try String(contentsOf: nextheatURL)
            log("heat: \(line)")
            let values = line.split(separator: ",", omittingEmptySubsequences: false)
            if values.count < settings.trackCount + 1 {
                log("invalid heats data")
                return
            }
            let heat = Int(values[0])!
            let cCnt = values.count - 1
            var cars: [Int] = [Int](repeating: 0, count: cCnt)
            for i in 0..<cCnt {
                cars[i] = Int(values[i+1])!
            }
            var timesData = "\(heat)"
            for i in 0..<self.settings.trackCount {
                timesData += String(format: ",%d,%0.4f", cars[i], generateTime(i, cars[i]))
            }
            log("simulated times \(timesData)")
            timesData += "\n"
            try timesData.write(to: timesURL, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
        }
    }
    
    /// This is for the simulator
    func generateTime(_ track: Int, _ carNumber: Int) -> Double {
        let e = racers.filter { carNumber == $0.carNumber }
        if e.count == 1 {
            let entry = e[0]
            if entry.firstSim == 0 {        // this is the first time for this car, it will be stored in firstSim track
                entry.firstSim = track
                let time = Double.random(in: 4..<6.3)
                return(time)
            }
            let base = entry.times[entry.firstSim]
            let time = Double.random(in: (base-0.2)..<(base+0.2))
            return(time)
        }
        return 0.0
    }
    
    // MARK: Calculations per time
    
    func calculateRankings() {
        log(#function)
        var changed = false
        // calculate averages
        for entry in racers {
            var average = 0.0
            var count = 0
            for i in 0..<settings.trackCount {
                if !entry.ignores[i] && entry.times[i] > minimumTime && entry.times[i] < maximumTime {
                    count += 1
                    average += entry.times[i]
                }
            }
            if count > 0 {
                average = average / Double(count)
            }
            if average > 0.0 {
                entry.average = average
                changed = true
            }
        }
        for group in groups {
            // calculate group rankings
            let g = self.racers.filter { $0.group == group.group }
            let gRank = g.sorted { $0.average < $1.average }
            var rank = 1
            for gEntry in gRank {
                let entry = racers.filter { $0.carNumber == gEntry.carNumber }[0]
                if entry.average > 0.0 {
                    entry.rankGroup = rank
                    changed = true
                    rank += 1
                }
            }
        }
        // calcuates overall rankings
        let a = racers
        let aRank = a.sorted { $0.average < $1.average }
        var rank = 1
        for aEntry in aRank {
            let entry = racers.filter { $0.carNumber == aEntry.carNumber }[0]
            if entry.average > 0.0 {
                entry.rankOverall = rank
                changed = true
                rank += 1
            }
        }
        
        if changed {
            saveRacers()
            objectWillChange.send()
        }
    }
    
    func generateHeats() {
        log(#function)
        heats = []
        // TODO: generate heats per group
        
        let boysEntries = racers.filter { $0.group == boys }
        var boysCars = boysEntries.map { $0.carNumber }
        
        if boysEntries.count < settings.trackCount {
            // TODO: if less members of a group than tracks, need to artificially add members
            
        }
        boysCars.sort { $0 < $1 }
        boysCars.shuffle()
        let boysOffset = boysCars.count / settings.trackCount
        log("boys count=\(boysCars.count) boys offset=\(boysOffset)")
        
        let girlsEntries = racers.filter { $0.group == girls }
        var girlsCars = girlsEntries.map { $0.carNumber }
        if girlsEntries.count < settings.trackCount {
            // TODO: if less members of a group than tracks, need to artificially add members
            
        }
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
        
        saveHeats()
        self.objectWillChange.send()
    }
    
    // MARK: Files
    
    func removeFile(_ name: String) {
        let nameUrl = settings.docDir.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: nameUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: nameUrl.path)
                log("remove \(name)")
            } catch {
                log(error.localizedDescription)
            }
        }
    }
    
    func readTimes() {
        let timesUrl = settings.docDir.appendingPathComponent(rest.timesName)
        let timesLogUrl = settings.docDir.appendingPathComponent(rest.timesLogName)
        timesTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timesTimerInterval), repeats: true) { timer in
            // attempt to read the times file
            var data: String?
            do {
                data = try String(contentsOf: timesUrl)
            } catch {
                return
            }
            if let times = data?.trimmingCharacters(in: .whitespacesAndNewlines) {
                log("heat: read times: \(times)")
                // append to times log
                do {
                    let line = times + "\n"
                    if FileManager.default.fileExists(atPath: timesLogUrl.path) {
                        let fileHandle = try FileHandle(forWritingTo: timesLogUrl)
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(Data(line.utf8))
                        fileHandle.closeFile()
                    } else {
                        try line.write(to: timesLogUrl, atomically: true, encoding: .utf8)
                    }
                    log("heat times appended \(self.rest.timesLogName)")
                } catch {
                    log(error.localizedDescription)
                }
                let values = times.split(separator: ",", omittingEmptySubsequences: false)
                if values.count < (1 + 2 * self.settings.trackCount) {
                    return
                }
                var heat: Int = 0
                for i in 0..<self.settings.trackCount {
                    heat = Int(values[0])!
                    let carNumber = Int(values[2*i+1])
                    let time = Double(values[2*i+2])!
                    let entry = self.racers.filter { $0.carNumber == carNumber }[0]
                    if entry.times[i] == 0.0 || time < entry.times[i] {
                        entry.times[i] = time
                        entry.ignores[i] = false
                    }
                }
                self.heats[heat-1].hasRun = true
            }
            self.removeFile(self.rest.timesName)
            self.calculateRankings()
            self.saveHeats()
            self.objectWillChange.send()
            self.timesTimer?.invalidate()
        }
    }
    
    func readGroups() {
        let name = settings.docDir.appendingPathComponent(rest.groupsName)
        log("\(#function) \(rest.groupsName)")
        var data: String?
        do {
            data = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            data = ""
        }
        groups = []
        let lines = data!.components(separatedBy: .newlines)
        for line in lines {
            if line.count == 0 {
                continue
            }
            let group = line.trimmingCharacters(in: .whitespaces)
            log(group)
            groups.append(GroupEntry(group: group))
        }
        objectWillChange.send()
    }
    
    func saveGroups() {
        let name = settings.docDir.appendingPathComponent(rest.groupsName)
        log("\(#function) \(rest.groupsName)")
        var list = [String]()
        for entry in groups {
            let csv = "\(entry.group)"
            list.append(csv)
        }
        let fileData = list.joined(separator: "\n") + "\n"
        do {
            try fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        } catch {
            log("error: \(error.localizedDescription)")
        }
    }

    func readRacers() {
        let name = settings.docDir.appendingPathComponent(rest.racersName)
        log("\(#function) \(rest.racersName)")
        var data: String?
        do {
            data = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            data = ""
        }
        let lines = data!.components(separatedBy: .newlines)
        for line in lines {
            if line.count == 0 {
                continue
            }
            log(line)
            let values = line.split(separator: ",", omittingEmptySubsequences: false)
            if values.count < Settings.maxTracks {
                continue
            }
            let d = RacerEntry(number:Int(values[0])!,
                               carName: String(values[1]),
                               firstName: String(values[2]),
                               lastName: String(values[3]),
                               age: Int(values[4])!,
                               group: String(values[5]))
            for i in 0..<settings.trackCount {
                let iv = i*2 + Settings.maxTracks
                if values.count > iv {
                    d.times[i] = Double(values[iv])!
                    d.ignores[i] = values[iv+1] != "1" ? false : true
                }
            }
            racers.append(d)
        }
        
        calculateRankings()
        objectWillChange.send()
    }
    
    func saveRacers() {
        let name = settings.docDir.appendingPathComponent(rest.racersName)
        log("\(#function) \(rest.racersName)")
        var list = [String]()
        for entry in racers {
            let csv = "\(entry.carNumber),\(entry.carName),\(entry.firstName),\(entry.lastName),\(entry.age),\(entry.group)"
            var times = ""
            for i in 0..<settings.trackCount {
                times += String(format: ",%0.4f,%d", entry.times[i], entry.ignores[i] ? 1 : 0)
            }
            list.append(csv+times)
        }
        let fileData = list.joined(separator: "\n") + "\n"
        do {
            try fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        } catch {
            log("error: \(error.localizedDescription)")
        }
    }
    
    func readHeats() {
        let name = settings.docDir.appendingPathComponent(rest.heatsName)
        log("\(#function) \(rest.heatsName)")
        do {
            let data = try String(contentsOf: name)
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
                if line.count == 0 {
                    continue
                }
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
        
        objectWillChange.send()
    }
    
    func saveHeats() {
        log("\(#function) \(rest.heatsName)")
        var list = [String]()
        for entry in heats {
            var heat = "\(entry.heat),\(entry.group),"
            for i in 0..<entry.tracks.count {
                heat.append("\(entry.tracks[i]),")
            }
            heat.append("\(entry.hasRun)")
            list.append(heat)
        }
        let name = settings.docDir.appendingPathComponent(rest.heatsName)
        let fileData = list.joined(separator: "\n")
        do {
            try fileData.write(toFile: name.path, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
        }
    }
    
    func archiveData() {
        log(#function)
        var archiveName = "archive"
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let archiveURL = docURL.appendingPathComponent(archiveName)
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
        let archiveDate = formatter.string(from: now)
        let archive = archiveURL.appendingPathComponent(archiveDate)
        archiveName += "/" + archiveDate
        if !FileManager.default.fileExists(atPath: archive.path) {
            do {
                try FileManager.default.createDirectory(atPath: archive.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log(error.localizedDescription)
            }
        }
        let files = [rest.settingsName, rest.racersName, rest.heatsName, rest.groupsName, rest.timesLogName]
        for f in files {
            log("copy \(f) to \(archiveName + "/" + f)")
            let srcURL = docURL.appendingPathComponent(f)
            let dstURL = archive.appendingPathComponent(f)
            do {
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            } catch (let error) {
                log(error.localizedDescription)
            }
        }
    }
}
