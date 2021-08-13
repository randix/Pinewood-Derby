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
    
    static let shared = BTManager()
    private override init() {
        super.init()
        log("BTManager.init")
    }
    

    func startAdvertisementScan(_ advertise: @escaping BTAdvertise) {
        log("startAdvertisementScan")
        
        btAdvertise = advertise
        services = []
        services.append(CBUUID(string: "FEAA"))
        
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
        
        let pName = peripheral.name != nil ? peripheral.name! : "unknown"
        log("---------------\(pName)")
        let lName = advertisementData["kCBAdvDataLocalName"] != nil ? (advertisementData["kCBAdvDataLocalName"] as? String)! : "unknown"
        log("--scan response: \(lName)")
        for i in advertisementData.keys {
            switch i {
            //            case "kCBAdvDataServiceUUIDs":
            //            case "kCBAdvDataManufacturerData":
            //            case "kCBAdvDataIsConnectable":
            //            case "kCBAdvDataLocalName":
            //            case "kCBAdvDataRxSecondaryPHY":
            //            case "kCBAdvDataRxPrimaryPHY":
            //            case "kCBAdvDataTimestamp":
            default:
                log(" --\(i): \(String(describing: advertisementData[i]))")
            }
        }

//        let mfgData = advertisementData["kCBAdvDataManufacturerData"] != nil ? (advertisementData["kCBAdvDataManufacturerData"] as? Data)! : Data()
        
        //if mfgData.count > 4 && mfgData.hexEncodedString().starts(with: "f401") {
    }
}
