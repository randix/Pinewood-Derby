//
//  REST.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/8/21.
//

import Foundation

class REST {
   
    var timer: Timer?
    
    var webProtocol = "http://"
    var ipAddress = ""
    var serverAddress: String?
    let port = "8080"
    var timerUrl = ""
    
    var timesUpdated = false
    var derbyUpdated = false
    var heatsUpdated = false
    var configUpdated = false
    
    let derbyName = "derby.csv"
    let heatsName = "heats.csv"
    let configName = "config.txt"
    let timesName = "times.csv"
    
    static let shared = REST()
    private init() {}
    
    func pollServer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: true) { timer in
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
        print(#function)
    }
    
    func readFilesFromServer() {
        
    }
    
    func saveFileToServer(_ name: String) {
        print(#function)
    }
    
    func saveFilesToServer() {
        
    }
    
    func findTimer() {
        let ipParts = ipAddress.components(separatedBy: ".")
        let network = "\(ipParts[0]).\(ipParts[1]).\(ipParts[2])."
        
        for addr in 1..<255 {
            if let url = URL(string: "\(webProtocol)\(network)\(addr):\(port)/") {
                var request = URLRequest(url: url)
                request.httpMethod = "HEAD"
                URLSession(configuration: .default)
                    .dataTask(with: request) { (_, response, error) -> Void in
                        guard error == nil else {
                            //print("Error:", error ?? "")
                            return
                        }
                        guard (response as? HTTPURLResponse)?
                                .statusCode == 200 else {
                                    //print("down")
                                    return
                                }
                        self.serverAddress = network + String(addr)
                        self.timerUrl = "http://" + self.serverAddress! + ":" + self.port + "/"
                        log("PDServer: \(self.timerUrl)")
                    }
                    .resume()
            }
        }
    }
}
