//
//  REST.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/8/21.
//

import Foundation

class REST: ObservableObject {
    
    var timer: Timer?
    
    // TODO: Apple requires https
    var webProtocol = "http://"
    var ipAddress = "192.168.12.125"
    @Published var serverIpAddress: String?
    let port = "8080"
    var timerUrl: URL?
    
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
    
    static let shared = REST()
    private init() {}
    
    func deleteFileFromServer(_ name: String) {
        guard timerUrl != nil else { return }
        let url = timerUrl!.appendingPathComponent(name)
        log("delete: \(name)")
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
                }
            })
        task.resume()
    }
    
    func readFileFromServer(_ name: String) {
        guard timerUrl != nil else { return }
        let url = timerUrl!.appendingPathComponent(name)
        log("fetch: \(name)")
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL else {
                log(error?.localizedDescription ?? "\(name): not downloaded")
                return
            }
            let response = response as! HTTPURLResponse
            if response.statusCode != 200 {
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
        }
        task.resume()
    }
    
    func readFilesFromServer() {
        readFileFromServer(settingsName)
        readFileFromServer(racersName)
        readFileFromServer(heatsName)
        readFileFromServer(groupsName)
        readFileFromServer(timesLogName)
    }
    
    func saveFileToServer(_ name: String) {
        guard timerUrl != nil else { return }
        let url = timerUrl!.appendingPathComponent(name)
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
                }
            })
        task.resume()
    }
    
    func saveFilesToServer() {
        saveFileToServer(settingsName)
        saveFileToServer(racersName)
        saveFileToServer(heatsName)
        saveFileToServer(groupsName)
    }
    
    func findTimer() {
        log(#function)
        let ipParts = ipAddress.components(separatedBy: ".")
        let network = "\(ipParts[0]).\(ipParts[1]).\(ipParts[2])."
        
        for addr in 1..<255 {
            if let url = URL(string: "\(webProtocol)\(network)\(addr):\(port)/") {
                var request = URLRequest(url: url)
                request.httpMethod = "HEAD"
                URLSession(configuration: .default)
                    .dataTask(with: request) { (_, response, error) -> Void in
                        guard error == nil else {
                            return
                        }
                        guard (response as? HTTPURLResponse)?
                                .statusCode == 200 else {
                                    return
                                }
                        self.serverIpAddress = network + String(addr)
                        self.timerUrl = URL(string: "http://" + self.serverIpAddress! + ":" + self.port + "/")
                        log("PDServer: \(self.timerUrl!)")
                        self.objectWillChange.send()
                    }
                    .resume()
            }
        }
    }
}
