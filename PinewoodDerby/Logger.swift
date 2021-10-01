//
//  Logger.swift
//
//  Created by Rand Dow on 11/8/19.
//

import Foundation

var logger: Logger = Logger()

public func log(_ msg: String) -> Void {
    logger.log(msg)
}

class Logger {
    
    let fm = FileManager.default
    let docs: String
    let formatter = DateFormatter()
    
    init() {
        docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //print("path: \(docs)")
    }
    
    func log(_ msg: String) {
        
        let now = Date()
        
        formatter.dateFormat = "yyyy-MM-dd"
        let fileNameComponent = "log-" + formatter.string(from: now) + ".txt"
        let logFileURL = NSURL(fileURLWithPath: docs).appendingPathComponent(fileNameComponent)!
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let msgNoLF = "\(formatter.string(from: Date())) \(msg)"
        let msglf = msgNoLF + "\n"
        let encoding = String.Encoding.utf8
        let data = msglf.data(using: encoding)!
        
        if let fileHandle = FileHandle(forWritingAtPath: logFileURL.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            try! msglf.write(to: logFileURL, atomically: false, encoding: encoding)
        }
        
        print(msgNoLF)
    }
}
