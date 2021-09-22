//
//  Persist.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class Settings {
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let settingsName = "settings.txt"
    
    static let shared = Settings()
    private init() {}
    
    func readData() {
        print(docDir)
    }
    
    func saveData() {
        
    }
}
