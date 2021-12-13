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
    
    let id = UUID()
    var carNumber: Int
    var carName: String
    var firstName: String
    var lastName: String
    var age: Int
    var group: String
    
    var times = [Double](repeating: 0.0, count: Settings.maxTracks)  // the times for each track
    var ignores = [Bool](repeating: false, count: Settings.maxTracks)
    var places = [Int](repeating: 0, count: Settings.maxTracks)     // the places for each track, assume 1 heat in each track exactly
    var firstSim = 0                // track number of first simulated time
    var points: Int = 0
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
    let id = UUID()
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


// MARK: DerbyModel

class Derby: ObservableObject {
    
    @Published var racers: [RacerEntry] = []
    @Published var heats: [HeatsEntry] = []
    @Published var groups: [GroupEntry] = []
    
    let overall = "overall"
    
    @ObservedObject var settings = Settings.shared
    let rest = REST.shared
    
    var minimumTime =  2.0
    var maximumTime = 20.0
    
    @Published var tabSelection = Tab.racers.rawValue
    @Published var simulationRunning = false
    var timesTimer: Timer?
    let timesTimerInterval = 0.5
    var nextHeat = 0

    static let shared = Derby()
    private init() {}
    
    // MARK: Delete single racer entry
    
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
    
    // MARK: prepare to start racing (or simulation)
    func clearTimes() {
        log(#function)
        let times = [Double](repeating: 0.0, count: Settings.maxTracks)
        let places = [Int](repeating: 0, count: Settings.maxTracks)
        let ignores = [Bool](repeating: false, count: Settings.maxTracks)
        for entry in racers {
            entry.times = times
            entry.places = places
            entry.ignores = ignores
            entry.firstSim = 0
            entry.average = 0.0
            entry.rankGroup = 0
            entry.rankOverall = 0
        }
        removeFile(rest.timesName)
        calculateRankings()
        
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
        heatData += "\n"
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
        } else {
            rest.saveFileToServer(rest.nextHeatName)
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
                cars[i] = Int(values[i+1].trimmingCharacters(in: .whitespacesAndNewlines))!
            }
            
            // add places
            struct One {
                let track: Int
                let car: Int
                var place: Int
                let time: Double
            }
            var data = [One]()
            for i in 0..<self.settings.trackCount {
                let time = generateTime(i, cars[i])
                data.append(One(track: i, car: cars[i], place: 0, time: time))
            }
            data.sort { $0.time < $1.time }
            var place = 1
            for i in 0..<self.settings.trackCount {
                if data[i].time > 0.0 {
                    data[i].place = place
                    place += 1
                }
            }
            data.sort { $0.track < $1.track }
            var timesData = "\(heat)"
            for i in 0..<self.settings.trackCount {
                timesData += String(format: ",%d,%d,%0.4f", data[i].car, data[i].place, data[i].time)
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
            var points = 0
            var pointsCount = 0
            for i in 0..<settings.trackCount {
                if !entry.ignores[i] && entry.times[i] > minimumTime && entry.times[i] < maximumTime {
                    count += 1
                    average += entry.times[i]
                }
                if !entry.ignores[i] && entry.places[i] > 0 {
                    pointsCount += 1
                    points += entry.places[i]
                }
            }
            entry.points = points
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
        
        var groupHeats: [[HeatsEntry]] = []
        var hCount = 0
        
        for group in groups {
            let entries = racers.filter { $0.group == group.group }
            var cars = entries.map { $0.carNumber }
            if cars.count == 0 {
                continue
            }
            while cars.count < settings.trackCount {
                cars.append(0)
            }
            cars.sort { $0 < $1 }
            cars.shuffle()
            let offset = cars.count / settings.trackCount
            log("\(group.group) count=\(cars.count) offset=\(offset)")
        
            groupHeats.append([HeatsEntry]())
            // generate the heats
            for i in 0..<cars.count {
                var tracks: [Int] = []
                for j in 0..<settings.trackCount {
                    var idx = j*offset + i
                    if idx >= cars.count {
                        idx -= cars.count
                    }
                    tracks.append(cars[idx])
                }
                groupHeats[hCount].append(HeatsEntry(heat:0, group: group.group, tracks: tracks, hasRun: false))
            }
            hCount += 1
        }
        
        for i in 0..<hCount {
            log("heat group \(i) \(groupHeats[i][0].group) count: \(groupHeats[i].count)")
        }
        
        var idx = [Int](repeating: 0, count: hCount)
        var heat = 1
        while true {
            for i in 0..<hCount {
                if idx[i] < groupHeats[i].count {
                    groupHeats[i][idx[i]].heat = heat
                    heat += 1
                    heats.append(groupHeats[i][idx[i]])
                    idx[i] += 1
                }
            }
        
            var done = true
            for i in 0..<hCount {
                if idx[i] < groupHeats[i].count {
                    done = false
                }
            }
            if done {
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
                if values.count < (1 + 3 * self.settings.trackCount) {
                    return
                }
                let heat = Int(values[0])!
                for i in 0..<self.settings.trackCount {
                    let carNumber = Int(values[3*i+1])
                    if carNumber == 0 {
                        continue
                    }
                    let place = Int(values[3*i+2])!
                    let time = Double(values[3*i+3])!
                    let entry = self.racers.filter { $0.carNumber == carNumber }[0]
                    if entry.times[i] == 0.0 || time < entry.times[i] {
                        entry.places[i] = place
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
    
    // MARK: Configuration files
    
    func readPin() {
        let name = settings.docDir.appendingPathComponent(rest.pinName)
        log("\(#function) \(rest.pinName)")
        var data: String
        do {
            data = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            data = ""
        }
        settings.masterPin = data.trimmingCharacters(in: .whitespacesAndNewlines)
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
            let ln = line.trimmingCharacters(in: .whitespaces)
            if ln.count == 0 {
                continue
            }
            log(line)
            let values = ln.split(separator: ",", omittingEmptySubsequences: false)
            let racerDetails = 6    // number, carName, firstName, lastName, age, group
            if values.count < racerDetails {
                continue
            }
            let d = RacerEntry(number:Int(values[0])!,
                               carName: String(values[1]),
                               firstName: String(values[2]),
                               lastName: String(values[3]),
                               age: Int(values[4])!,
                               group: String(values[5]))
            // add in times and places
            if values.count >= (racerDetails + settings.trackCount * 3) {
                for i in 0..<settings.trackCount {
                    let iv = i*3 + racerDetails
                    d.times[i] = Double(values[iv])!
                    d.places[i] = Int(values[iv+1])!
                    d.ignores[i] = values[iv+2] != "1" ? false : true
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
                times += String(format: ",%0.4f,%d,%d", entry.times[i], entry.places[i], entry.ignores[i] ? 1 : 0)
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
        let fileData = list.joined(separator: "\n") + "\n"
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
