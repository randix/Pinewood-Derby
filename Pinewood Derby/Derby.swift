//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class DerbyEntry: Identifiable {
    init(idx: UInt, number: UInt, carName: String, name: String, group: String) {
        self.idx = idx
        self.number = number
        self.carName = carName
        self.name = name
        self.group = group
    }
    
    let id = UUID()             // id for SwiftUI
    var idx: UInt
    var number: UInt
    var carName: String
    var name: String
    var group: String
    
    var trackTimes: [UInt] = [] // the times for each track
    var averages: [UInt] = []       // [0]: best time, [1]: avg of best 2 times, etc.
}

class Derby: ObservableObject {
    
    @Published var entries: [DerbyEntry] = []
    let derbyName = "derby.csv"
    
    static let shared = Derby()
    private init() {}
    
    func addEntry() {
        print(#function)
    }
    
    func updateEntry() {
        print(#function)
    }
    
    func readData() {
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
        var derbyEntry = DerbyEntry(idx:1, number:42, carName:"fast", name:"Rand", group:"boys")
        entries.append(derbyEntry)
        derbyEntry = DerbyEntry(idx:2, number:43, carName:"slow", name:"Lina", group:"girls")
        entries.append(derbyEntry)
    }
    
    func clearTimes() {
        print(#function)
    }
    
    func saveData() {
        print(#function)
    }
}
