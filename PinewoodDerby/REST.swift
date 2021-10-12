//
//  REST.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/8/21.
//

import Foundation

class REST {
    
    var timer: Timer?
    
    // TODO: Apple requires https
    var webProtocol = "http://"
    var ipAddress = "192.168.12.125"
    var serverIpAddress: String?
    let port = "8080"
    var timerUrl: URL?
    
    var timesUpdated = false
    var derbyUpdated = false
    var heatsUpdated = false
    var configUpdated = false
    
    let derbyName = "derby.csv"
    let heatsName = "heats.csv"
    let settingsName = "settings.txt"
    let timesName = "times.csv"
    let nextheatName = "nextheat.csv"
    
    static let shared = REST()
    private init() {}
    
    func pollServer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(2), repeats: true) { timer in

            self.checkServerForUpdates()
        }
    }
    
    func checkServerForUpdates() {
        // read from server
        if timesUpdated {
            readFileFromServer(timesName)
        }
        
    }
    
    func readFileFromServer(_ name: String) {
        guard timerUrl != nil else { return }
        let url = timerUrl!.appendingPathComponent(name)
        log("fetch: \(url)")
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            guard let tempURL = tempURL else {
                log(error?.localizedDescription ?? "\(name): not downloaded")
                return
            }
            do {
                // Remove any existing document at name
                let file =  Settings.shared.docDir.appendingPathComponent(name)
                // TODO: only try to remove it file exists
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }
                
                // Copy the tempURL to name
                try FileManager.default.copyItem(at: tempURL, to: file)
                log("success")
            }
            catch {
                log(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func readFilesFromServer() {
        readFileFromServer(timesName)
        // config.txt
        // derby.csv
        // heats.csv
        // times.csv
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
                print("data", data ?? "nil")
                print("response: ", response ?? "nil")
//                for k in response.keys {
//                    print(k)
//                }
                //print(response?.value(forKey: "Status Code"))
                print("error", error ?? "nil")
            })
        task.resume()
    }
    
    func saveFilesToServer() {
        saveFileToServer(derbyName)
        
        
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
                    }
                    .resume()
            }
        }
    }
}
