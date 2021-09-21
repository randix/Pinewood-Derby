//
//  Derby.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/20/21.
//

import Foundation

class DerbyEntry {
    var number = 0
    var name = ""
    var carName = ""
    var trackTimes: [UInt] = []
    var sums: [UInt] = []
}

class Derby {
    var entries: [DerbyEntry] = []
}
