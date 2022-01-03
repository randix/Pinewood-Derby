//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation
import SwiftUI
import Network

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
    
    var times = [Double](repeating: 0.0, count: Derby.maxTracks)  // the times for each track
    var ignores = [Bool](repeating: false, count: Derby.maxTracks)
    var places = [Int](repeating: 0, count: Derby.maxTracks)     // the places for each track, assume 1 heat in each track exactly
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

//struct StateMachine {
//    let name: String
//    let read: () -> Void
//}

struct Filenames {
    static let simFlagName = "sim.txt"  // local
    
    // configuration - on server also:
    static let pinName = "PIN.txt"
    static let derbyName = "derby.txt"
    
    static let timeslogName = "timeslog.csv"    // maintained separately on server and local
    // for each heat:
    static let heatName = "heat.csv"
    static let timesName = "times.csv"
}

// MARK: DerbyModel

class Derby: ObservableObject {
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // TODO: Apple requires https
    @Published var timer = "http://raspberrypi.local:8484/"
    @Published var connected = true
    
    var appName = ""
    var appVersion = ""
    let iPad = UIScreen.main.bounds.width > 600
    
    @Published var title = ""
    @Published var event = ""
    
    @Published var trackCount = 0
    static let possibleTracks = ["2", "3", "4", "5", "6"]
    static let maxTracks = 6
    
    @Published var racers: [RacerEntry] = []
    @Published var heats: [HeatsEntry] = []
    @Published var groups: [GroupEntry] = []
    
    @Published var isMaster = false
    @Published var masterPin = "1234"
    @Published var pin: String = ""
    
    @Published var readingConfig = false
    
    let overall = "overall"
    
    var minimumTime =  2.0
    var maximumTime = 20.0
    
    @Published var tabSelection = Tab.racers.rawValue
    
    @Published var simulationRunning = false
    var simTimesCount = 0
    
    var timesTimer: Timer?
    let timesTimerInterval = 1.0
    var heat = 0
    var trackCars = [Int]()
    var seenTimes = 0
    let timesVersion = "A"
    
    let backgroundQueue = DispatchQueue(label: "background")
    let mainQueue = DispatchQueue.main
    
    //let semaphore = DispatchSemaphore(value: 0)
    
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
        let times = [Double](repeating: 0.0, count: Derby.maxTracks)
        let places = [Int](repeating: 0, count: Derby.maxTracks)
        let ignores = [Bool](repeating: false, count: Derby.maxTracks)
        for entry in racers {
            entry.times = times
            entry.places = places
            entry.ignores = ignores
            entry.firstSim = 0
            entry.average = 0.0
            entry.rankGroup = 0
            entry.rankOverall = 0
        }
        calculateRankings()
        
        saveDerby()
        
        deleteFileFromServer(Filenames.timesName)   // async
        removeFile(Filenames.timesName)
        seenTimes = 0
        objectWillChange.send()
    }
    
    // MARK: Racing
    
    func startRacing() {
        log(#function)
        archiveData()
        clearTimes()
        generateHeats()
    }
    
    // generate heat.csv
    func startHeat(_ heat: Int, _ cars: [Int]) {
        
        var heatData = "\(heat)"
        for i in 0..<trackCount {
            heatData += ",\(cars[i])"
        }
        log("Heat: \(heatData)")
        heatData += "\n"
        do {
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let nextheatURL = docURL.appendingPathComponent(Filenames.heatName)
            try heatData.write(toFile: nextheatURL.path, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
            return
        }
        
        if simulationRunning {
            simulateHeat()
        } else {
            saveFileToServer(Filenames.heatName)
        }
    }
    
    // MARK: Simulator
    
    func simulate() {
        log(#function)
        simulationRunning = true
        startRacing()
    }
    
    // read heat.csv
    // process and then
    // generate times.csv
    func simulateHeat() {
        log(#function)
        let heatURL = docDir.appendingPathComponent(Filenames.heatName)
        let timesURL = docDir.appendingPathComponent(Filenames.timesName)
        do {
            let line = try String(contentsOf: heatURL)
            log("heat: \(line)")
            let values = line.split(separator: ",", omittingEmptySubsequences: false)
            if values.count < trackCount + 1 {
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
            for i in 0..<self.trackCount {
                let time = generateTime(i, cars[i])
                data.append(One(track: i, car: cars[i], place: 0, time: time))
            }
            data.sort { $0.time < $1.time }
            var place = 1
            for i in 0..<self.trackCount {
                if data[i].time > 0.0 {
                    data[i].place = place
                    place += 1
                }
            }
            data.sort { $0.track < $1.track }
            
            simTimesCount += 1
            var timesData = "\(timesVersion),\(simTimesCount),\(heat)"
            for i in 0..<self.trackCount {
                timesData += String(format: ",%d,%d,%0.4f", data[i].car, data[i].place, data[i].time)
            }
            log("simulateHeat: \(timesData)")
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
            for i in 0..<trackCount {
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
            saveDerby()
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
            while cars.count < trackCount {
                cars.append(0)
            }
            cars.sort { $0 < $1 }
            cars.shuffle()
            let offset = cars.count / trackCount
            log("\(group.group) count=\(cars.count) offset=\(offset)")
            
            groupHeats.append([HeatsEntry]())
            // generate the heats
            for i in 0..<cars.count {
                var tracks: [Int] = []
                for j in 0..<trackCount {
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
        
        saveDerby()
        objectWillChange.send()
    }
}

// MARK: Files

extension Derby {
    
    func removeFile(_ name: String) {
        let nameUrl = docDir.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: nameUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: nameUrl.path)
                log("remove \(name)")
            } catch {
                log(error.localizedDescription)
            }
        }
    }
    
    func readPin() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = docDir.appendingPathComponent(Filenames.pinName)
        log("\(#function) \(Filenames.pinName)")
        var data: String
        do {
            data = try String(contentsOf: nameUrl)
            
            try FileManager.default.removeItem(atPath: nameUrl.path)
            log("remove \(Filenames.pinName)")
            masterPin = data.trimmingCharacters(in: .whitespacesAndNewlines)
            objectWillChange.send()
        } catch {
            log("error: \(error.localizedDescription)")
        }
        readFileFromServer(Filenames.derbyName)
    }
    
    func readDerby() {
        let name = docDir.appendingPathComponent(Filenames.derbyName)
        log("readDerby: \(name)")
        var config: String
        do {
            config = try String(contentsOf: name)
        } catch {
            log("error: \(error.localizedDescription)")
            readingConfig = false
            objectWillChange.send()
            return
        }
        let sections = config.components(separatedBy: "\n+++\n")
        // 0: settings
        let settingsSection = sections[0].components(separatedBy: "\n")
        // 1: groups
        let groupsSection = sections[1].components(separatedBy: "\n")
        // 2: heats
        let heatsSection = sections[2].components(separatedBy: "\n")
        // 3: racers
        let racersSection = sections[3].components(separatedBy: "\n")
        
        // settings
        for line in settingsSection {
            if line.count == 0 {
                continue
            }
            let keyValue = line.components(separatedBy: "=")
            if keyValue.count < 2 {
                log("\(Filenames.derbyName): format error")
                continue
            }
            switch keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines) {
            case "title":
                title = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if title == "" {
                    title = "Pinewood Derby"
                }
                log("title=\(title)")
            case "event":
                event = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if title == "" {
                    title = "Event"
                }
                log("event=\(event)")
            case "tracks":
                let tracks = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                trackCount = 2
                if let t = Int(tracks) {
                    trackCount = t
                }
                if trackCount < 2 {
                    trackCount = 2
                }
                if trackCount > Derby.maxTracks {
                    trackCount = Derby.maxTracks
                }
                log("tracks=\(String(trackCount))")
            default:
                log("incorrect format: \(config)")
            }
        }
        
        // groups
        groups = []
        for line in groupsSection {
            if line.count == 0 {
                continue
            }
            let group = line.trimmingCharacters(in: .whitespaces)
            log("group: \(group)")
            groups.append(GroupEntry(group: group))
        }
        
        // heats
        heats = []
        for line in heatsSection {
            if line.count == 0 {
                continue
            }
            log("heat: \(line)")
            let values = line.split(separator: ",", omittingEmptySubsequences: false)
            if values.count < (trackCount+3) {
                log("invalid")
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
        
        // racers
        racers = []
        for line in racersSection {
            let ln = line.trimmingCharacters(in: .whitespaces)
            if ln.count == 0 {
                continue
            }
            log("racer: \(line)")
            let values = ln.split(separator: ",", omittingEmptySubsequences: false)
            let racerDetails = 6    // number, carName, firstName, lastName, age, group
            if values.count < racerDetails {
                log("invalid")
                continue
            }
            let d = RacerEntry(number:Int(values[0])!,
                               carName: String(values[1]),
                               firstName: String(values[2]),
                               lastName: String(values[3]),
                               age: Int(values[4])!,
                               group: String(values[5]))
            // add in times and places
            if values.count >= (racerDetails + trackCount * 3) {
                for i in 0..<trackCount {
                    let iv = i*3 + racerDetails
                    d.times[i] = Double(values[iv])!
                    d.places[i] = Int(values[iv+1])!
                    d.ignores[i] = values[iv+2] != "1" ? false : true
                }
            }
            racers.append(d)
        }
        
        readingConfig = false
        calculateRankings()
        objectWillChange.send()
    }
    
    func saveDerby() {
        log("\(#function) \(Filenames.derbyName)")
        let name = docDir.appendingPathComponent(Filenames.derbyName)
        var data = ""
        
        // settings
        var list = [String]()
        list.append("title=\(title.trimmingCharacters(in: .whitespaces))")
        list.append("event=\(event.trimmingCharacters(in: .whitespaces))")
        list.append("tracks=\(String(trackCount))")
        data += list.joined(separator: "\n") + "\n+++\n"
        
        // groups
        list = [String]()
        for entry in groups {
            list.append(entry.group)
        }
        data += list.joined(separator: "\n") + "\n+++\n"
        
        // heats
        list = [String]()
        for entry in heats {
            var heat = "\(entry.heat),\(entry.group),"
            for i in 0..<entry.tracks.count {
                heat.append("\(entry.tracks[i]),")
            }
            heat.append("\(entry.hasRun)")
            list.append(heat)
        }
        data += list.joined(separator: "\n") + "\n+++\n"
        
        // racers
        list = [String]()
        for entry in racers {
            let csv = "\(entry.carNumber),\(entry.carName),\(entry.firstName),\(entry.lastName),\(entry.age),\(entry.group)"
            var times = ""
            for i in 0..<trackCount {
                times += String(format: ",%0.4f,%d,%d", entry.times[i], entry.places[i], entry.ignores[i] ? 1 : 0)
            }
            list.append(csv+times)
        }
        data += list.joined(separator: "\n") + "\n"
        
        do {
            try data.write(toFile: name.path, atomically: true, encoding: .utf8)
            saveFileToServer(Filenames.derbyName)
        } catch {
            log(error.localizedDescription)
        }
    }
    
    func startReadTimes() {
        log(#function)
        connected = true
        timesTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timesTimerInterval), repeats: true) { timer in
            if self.simulationRunning {
                self.readTimes()
            } else {
                self.readFileFromServer(Filenames.timesName)
            }
        }
    }
    
    func readTimes() {
        //log(#function)
        let timesUrl = docDir.appendingPathComponent(Filenames.timesName)
        let timeslogUrl = docDir.appendingPathComponent(Filenames.timeslogName)
        
        var rawData: String?
        do {
            rawData = try String(contentsOf: timesUrl).trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return
        }
        guard let values = rawData?.split(separator: ",", omittingEmptySubsequences: false) else {
            log("readTimes: invalid format: \(String(describing: rawData))")
            return
        }
        if values.count < (3 + 3 * self.trackCount) {
            log("readTimes: invalid count: \(String(describing: rawData))")
            return
        }
        if values[0] != self.timesVersion {
            log("readTimes: invalid version: \(String(describing: rawData))")
            return
        }
        
        guard let timeCnt = Int((values[1])), timeCnt > self.seenTimes else {
            // quietly
            return
        }
        self.seenTimes = timeCnt
        
        guard let heat = Int(values[2]), heat <= self.heats.count else  {
            log("readTimes: invalid heat: \(String(describing: rawData))")
            return
        }
        
        log("readTimes: \(rawData!)")
        do {
            let line = rawData! + "\n"
            if FileManager.default.fileExists(atPath: timeslogUrl.path) {
                let fileHandle = try FileHandle(forWritingTo: timeslogUrl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(Data(line.utf8))
                fileHandle.closeFile()
            } else {
                try line.write(to: timeslogUrl, atomically: true, encoding: .utf8)
            }
        } catch {
            log(error.localizedDescription)
        }
        
        for i in 0..<self.trackCount {
            let carNumber = Int(values[3*i+3])
            if carNumber == 0 {
                continue
            }
            let place = Int(values[3*i+4])!
            let time = Double(values[3*i+5])!
            print("PLACE TIME", carNumber as Any, place, time)
            let entry = self.racers.filter { $0.carNumber == carNumber }
            if entry.count < 1 {
                print("not found")
                continue
            }
            if entry[0].times[i] == 0.0 || time < entry[0].times[i] {
                entry[0].places[i] = place
                entry[0].times[i] = time
                entry[0].ignores[i] = false
            }
        }
        self.heats[heat-1].hasRun = true
        
        self.calculateRankings()
        self.saveDerby()
        
        self.objectWillChange.send()
        
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
        let files = [Filenames.derbyName, Filenames.timeslogName]
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

// MARK: Server files

extension Derby {
    
    func deleteFileFromServer(_ name: String) {
        log("\(#function) \(name)")
        if !connected {
            return
        }
        guard let timerUrl = URL(string: timer) else {
            log("invalid URL: \(timer)")
            return
        }
        let url = timerUrl.appendingPathComponent(name)
        log("DELETE \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let error = error {
                    log(error.localizedDescription)
                    return
                }
            }).resume()
    }
    
    func dispatch(_ name: String) {
        if name != Filenames.timesName {
            log("\(#function) \(name)")
        }
        mainQueue.async {
            switch name {
            case Filenames.pinName:
                self.readPin()
            case Filenames.derbyName:
                self.readDerby()
            case Filenames.timesName:
                self.readTimes()
            default:
                log("readFileFromServer: \(name) - unknown action")
            }
        }
    }
    
    // this runs synchronously
    func readFileFromServer(_ name: String) {
        if name != Filenames.timesName {
            log("\(#function) \(name)")
        }
        if !connected {
            dispatch(name)
            return
        }
        
        guard let timerUrl = URL(string: timer) else {
            log("invalid URL: \(timer)")
            dispatch(name)
            return
        }
        let url = timerUrl.appendingPathComponent(name)
        if name != Filenames.timesName {
            log("GET \(url)")
        }
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL else {
                if name != Filenames.timesName {
                    log(error?.localizedDescription ?? "\(name): not downloaded")
                }
                DispatchQueue.main.async {
                    self.connected = false
                }
                self.dispatch(name)
                return
            }
            DispatchQueue.main.async {
                self.connected = true
            }
            let response = response as! HTTPURLResponse
            if response.statusCode == 200 {
                do {
                    let file = self.docDir.appendingPathComponent(name)
                    if FileManager.default.fileExists(atPath: file.path) {
                        try FileManager.default.removeItem(at: file)
                    }
                    try FileManager.default.copyItem(at: tempURL, to: file)
                    if name != Filenames.timesName {
                        log("fetched: \(name)")
                    }
                }
                catch {
                    log(error.localizedDescription)
                }
            }
            self.dispatch(name)
        }
        task.resume()
    }
    
    func readFilesFromServer() {
        readingConfig = true
        readFileFromServer(Filenames.pinName)
        objectWillChange.send()
    }
    
    func saveFileToServer(_ name: String) {
        log("\(#function) \(name)")
        if !connected || simulationRunning {
            return
        }
        guard let timerUrl = URL(string: timer) else {
            log("invalid URL: \(timer)")
            return
        }
        let url = timerUrl.appendingPathComponent(name)
        log("POST \(url)")
        let fileUrl = docDir.appendingPathComponent(name)
        
        var request = URLRequest(url: url)
        do {
            request.httpBody = try Data(contentsOf: fileUrl)
        } catch {
            log("\(name): \(error.localizedDescription)")
            return
        }
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let error = error {
                    log(error.localizedDescription)
                }
                // nothing more to do...
            }).resume()
    }
}
