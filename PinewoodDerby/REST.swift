//
//  REST.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/8/21.
//

import Foundation
import Network

class REST: ObservableObject {
    
    // TODO: Apple requires https
    @Published var timer = "http://raspberrypi.local:8484/"

    @Published var connected = false
    @Published var masterPin = "1234"
    
    var timesUpdated = false
    var derbyUpdated = false
    var heatsUpdated = false
    var configUpdated = false
    
    let settingsName = "settings.txt"
    let pinName = "PIN.txt"
    let racersName = "racers.csv"
    let groupsName = "groups.csv"
    let heatsName = "heats.csv"
    let timesLogName = "timeslog.csv"
    
    let timesName = "times.csv"
    let nextHeatName = "nextheat.csv"
    
    let semaphore = DispatchSemaphore(value: 0)
    
    static let shared = REST()
    private init() {}
    
    func deleteFileFromServer(_ name: String) {
        log("delete: \(name)")
        connected = false
        guard let timerUrl = URL(string: timer) else {
            // TODO: error
            return
        }
        let url = timerUrl.appendingPathComponent(name)
        let urlSession = URLSession.shared
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        request.httpMethod = "DELETE"
        
        let task = urlSession.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let error = error {
                    log(error.localizedDescription)
                    return
                }
                self.connected = true
            })
        task.resume()
    }
    
    func readFileFromServer(_ name: String) {
        log("read from server: \(name)")
        connected = false
        guard let timerUrl = URL(string: timer) else {
            // TODO: error
            return
        }
        let url = timerUrl.appendingPathComponent(name)
        if name != timesName {
            log("fetch: \(name)")
        }
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL else {
                log(error?.localizedDescription ?? "\(name): not downloaded")
                self.semaphore.signal()
                return
            }
            self.connected = true
            let response = response as! HTTPURLResponse
            if response.statusCode != 200 {
                self.semaphore.signal()
                return
            }
            do {
                let file =  Settings.shared.docDir.appendingPathComponent(name)
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }
                try FileManager.default.copyItem(at: tempURL, to: file)
                log("success fetched: \(name)")
                
            }
            catch {
                log(error.localizedDescription)
            }
            self.semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    func readFilesFromServer() {
        readFileFromServer(settingsName)
        readFileFromServer(racersName)
        readFileFromServer(heatsName)
        readFileFromServer(groupsName)
        readFileFromServer(timesLogName)
    }
    
    func saveFileToServer(_ name: String) {
        connected = false
        guard let timerUrl = URL(string: timer) else {
            // TODO: error
            return
        }
        let url = timerUrl.appendingPathComponent(name)
        let urlSession = URLSession.shared
        
        // To ensure that our request is always sent, we tell
        // the system to ignore all local cache data
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        let fileUrl = Settings.shared.docDir.appendingPathComponent(name)
  
        do {
            request.httpBody = try Data(contentsOf: fileUrl)
        } catch {
            log("\(name): \(error.localizedDescription)")
            return
        }
        request.httpMethod = "POST"
        
        let task = urlSession.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let error = error {
                    log(error.localizedDescription)
                    return
                }
                self.connected = true
            })
        task.resume()
    }
    
    func saveFilesToServer() {
        saveFileToServer(settingsName)
        saveFileToServer(racersName)
        saveFileToServer(heatsName)
        saveFileToServer(groupsName)
    }
    
    func readPin() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = docDir.appendingPathComponent(pinName)
        log("\(#function) \(pinName)")
        var data: String
        do {
            data = try String(contentsOf: nameUrl)
            
            try FileManager.default.removeItem(atPath: nameUrl.path)
            log("remove \(pinName)")
        } catch {
            log("error: \(error.localizedDescription)")
            data = ""
        }
        masterPin = data.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
