//
//  BTManager.swift
//
//  Created by Rand on 12/13/19.
//
// Dependency: a global "func log(_ msg: String) -> Void"


import Foundation
import CoreBluetooth


typealias BTAdvertise = (_ uuid: UUID, _ name: String, _ scanResponse: String, _ manufacturerData: Data, _  rssi: Int) -> Void

class BTManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
 
    private var btAdvertise: BTAdvertise?
    
    private var centralManager: CBCentralManager?
    private var btPoweredOn = false
    private var services: [CBUUID] = []
    
    private var prevRace: Int = -1
    
    static let shared = BTManager()
    private override init() {
        super.init()
        log("BTManager.init")
    }
    

    func startAdvertisementScan(_ advertise: @escaping BTAdvertise) {
        log("startAdvertisementScan")
        
        btAdvertise = advertise
        services = []
        //services.append(CBUUID(string: "FEAA"))
        services.append(CBUUID(string: "1101"))
        //services.append(CBUUID(string: "0111"))
        
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        if btPoweredOn && !centralManager!.isScanning {
            startScan()
        }
    }
    
    func startScan() {
        log("startScan \(services)")
        centralManager!.scanForPeripherals(withServices: services, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log(#function)
        switch central.state {
        case .poweredOn:
            log("BT: powered on")
            btPoweredOn = true
            startScan()
        case .poweredOff:
            log("BT: powered off")
        case .unauthorized:
            log("BT: unauthorized")
        case .resetting:
            log("BT: resetting")
        case .unknown:
            log("BT: unknown")
        case .unsupported:
            log("BT: unsupported")
        default:
            log("BT centralManager state: \(central.state)")
            break
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
//        for i in advertisementData.keys {
//            switch i {
//            default:
//                log(" --\(i): \(String(describing: advertisementData[i]))")
//            }
//        }
        
        let x = advertisementData["kCBAdvDataServiceData"]! as! Dictionary<CBUUID, Data>
        //print("\(x[CBUUID(string: "1101")])")
        let data = [UInt8](x[CBUUID(string: "1101")]!)
//        for d in data {
//            print(d)
//        }
        let race = (Int(data[0]) << 8) + Int(data[1])
        var idx = 2
        let t1 = (UInt(data[idx]) << 16) + (UInt(data[idx+1]) << 8) + UInt(data[idx+2])
        idx = 5
        let t2 = (UInt(data[idx]) << 16) + (UInt(data[idx+1]) << 8) + UInt(data[idx+2])
        idx = 8
        let t3 = (UInt(data[idx]) << 16) + (UInt(data[idx+1]) << 8) + UInt(data[idx+2])
        idx = 11
        let t4 = (UInt(data[idx]) << 16) + (UInt(data[idx+1]) << 8) + UInt(data[idx+2])
        if race == prevRace {
            return
        } else {
            prevRace = race
        }
        print(race, Double(t1)/10000.0, Double(t2)/10000.0, Double(t3)/10000.0, Double(t4)/10000.0)
        
    }
}
