//
//  Heats.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

enum Gender {
    case unknown
    case girls
    case boys
}

class HeatEntry {
    let id = UUID()             // id for SwiftUI
    var heat: UInt = 0
    var group: Gender = .unknown
    var tracks: [UInt] = []
    var hasRun = false
}

class Heats {
    var heats: [HeatEntry] = []
    
    let heatsName = "heats.csv"
    
    static let shared = Heats()
    private init() {}
    
    func generate() {
        
    }
    
    func readData() {
        
    }
    
    func saveData() {
        
    }
}
