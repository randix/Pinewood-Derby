//
//  Advertisement.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 8/13/21.
//

import Foundation

class Advertisement {
    
    private init() {
        log("Advertisement.init")
    }
    static let shared = Advertisement()
    
    func adverisement(_ race: Int, _ t1: Double, _ t2: Double, _ t3: Double, _  t4: Double) -> Void {
    print(#function)
        print(race, t1, t2, t3, t4)
    }
}
