//
//  Persist.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class Persist {
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileLists: URL
    
    private init() {
        print(docDir)
        fileLists = docDir.appendingPathComponent(".pinewood.json")
        print(fileLists)
    }
    static let shared = Persist()
    
    func readData() {
    // read list of files
    // read derby.csv file
    // read heats.csv file
    }
    
    func saveData() {
        
    }
    
    // read race plan file
    // save old race files
}
