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
    
    func adverisement(_ uuid: UUID, _ name: String, _ scanResponse: String, _ manufacturerData: Data, _  rssi: Int) -> Void {
    print(#function)
    }
}
