//
//  BTManager.swift
//
//  Created by Rand on 12/13/19.
//
// Dependency: a global "func log(_ msg: String) -> Void"


import Foundation
import CoreBluetooth

enum BTError: Error {
    case none
    case noValidIndex
    case timeout
}

struct BTPeripheral {
    let cbPeripheral: CBPeripheral
    var name: String
    var mfgData: Data
    var scanResponse: ScanResponse
    var rssiList: [Int]
    var rssiCnt: Int
    var rssiAvg: Int
    var lastAdvertisement: Date
}

struct ScanResponse {   // from 01-506-INT60311
    let serialNumber: UInt32
    let sysCode: UInt32
    
    var version: Int        // 4 bits
    var prodCode: UInt16
    var capabilities: UInt8
    var flags: UInt8
    var reserved: UInt16    // 12 bits
    
    init(_ scanResponse: String) {
        version = 0
        prodCode = 0
        capabilities = 0
        flags = 0
        reserved = 0
        
        let parts = scanResponse.split(separator: ".")
        let sn = UInt32(parts[0])
        serialNumber = sn == nil ? 0 : sn!
        
        if parts.count > 1 {
            let sc = UInt32(parts[1], radix: 16)
            sysCode = sc == nil ? 0 : sc!
        } else {
            sysCode = 0
        }
        
        if parts.count > 2 {
            if let cap =  Data(base64Encoded: String(parts[2])) {
                //log("48 bits: \(cap.hexEncodedString())")
                version = Int((cap[0] >> 4) & 0xf)
                
                prodCode = (UInt16(cap[0]) & 0xf) << 12
                prodCode |= UInt16(cap[1]) << 4
                prodCode |= (UInt16((cap[2]) >> 4) & 0xf)
                
                capabilities = (cap[2] & 0xf) << 4
                capabilities |= (cap[3] >> 4) & 0xf
                
                flags = (cap[3] & 0xf) << 4
                flags |= (cap[4] >> 4) & 0xf
            }
        }
    }
}

class BTManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var btPeripherals: [BTPeripheral] = []
    
    private var btAdvertise: ((_ uuid: UUID, _ name: String, _ manufacturerData: Data, _ scanResponse: ScanResponse, _ rssi: Int, _ lastAdvertisement: Date) -> Void)?
    
    private var centralManager: CBCentralManager?
    private var advManufacturer: CBUUID?
    private var btPoweredOn = false
    
    
    static let shared = BTManager()
    private override init() {
        super.init()
    }
    
  
    private func startScan() {
        if btPoweredOn && !centralManager!.isScanning {
            var id: [CBUUID] = []
            id.append(CBUUID(string: "FEAA"))
            
            btPeripherals = []
            log("scan \(id)")
            centralManager!.scanForPeripherals(withServices: id, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        }
    }
    
    
    // API
    func startAdvertisementScan(_ advertise: @escaping (_ uuid: UUID, _ name: String, _ manufacturerData: Data, _ scanResponse: ScanResponse, _ rssi: Int, _ lastAdvertisement: Date) -> Void) {
        log("startAdvertisementScan")
        //return
        btAdvertise = advertise
        
        btPeripherals = []
        // timer, run every 'frequency' seconds
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(frequency), repeats: true) { timer in
            //log("timer")
            var seen = true
            let old = Date() - TimeInterval(self.keepTime)
            while seen {
                seen = false
                for i in 0 ..< self.btPeripherals.count {
                    if self.btPeripherals[i].lastAdvertisement < old {
                        //log("bt.remove \(i)")
                        self.btPeripherals.remove(at: i)
                        seen = true
                        break
                    }
                }
            }
            //log("btPeripherals \(self.btPeripherals.count)")
            for i in 0 ..< self.btPeripherals.count {
                if self.btPeripherals[i].cbPeripheral.state == .connected {
                    self.btPeripherals[i].lastAdvertisement = Date()
                }
                //push upstream
                self.btAdvertise!(self.btPeripherals[i].cbPeripheral.identifier, self.btPeripherals[i].name, self.btPeripherals[i].mfgData, self.btPeripherals[i].scanResponse, self.btPeripherals[i].rssiAvg, self.btPeripherals[i].lastAdvertisement)
            }
        }
        
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        startScan()
    }
    
    // API
    func stopAdvertisementScan() {
        log("stopAdvertisementScan")
        timer?.invalidate()
        // stop scan
        if centralManager != nil && centralManager!.isScanning {
            centralManager?.stopScan()
        }
    }
    
    private func indexOf(_ uuid: UUID) throws -> Int {
        let index = btPeripherals.firstIndex(where: { $0.cbPeripheral.identifier == uuid })
        if let index = index {
            //log("bt.indexOf(\(index))")
            return index
        } else {
            //log("bt.indexOf(\(uuid)) not found")
            throw BTError.noValidIndex
        }
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log("BT is powered on")
            btPoweredOn = true
            startScan()
        case .poweredOff:
            log("BT is powered off")
        default:
            log("BT centralManager state: \(central.state)")
            break
        }
    }
    
    // API
    func connectPeripheral(_ uuid: UUID, connected: @escaping (_ uuid: UUID, _ hasMesh: Bool, _ error: BTError) -> Void) {
        log("connectPeripheral")
        btConnected = connected
        var idx: Int
        do {
            idx = try indexOf(uuid)
            centralManager?.connect(btPeripherals[idx].cbPeripheral, options: nil)
        } catch {
            log("no valid index")
            scanner.btAlert.message = "Not advertising"
            scanner.btAlert.button = "OK"
            btConnected!(uuid, false, BTError.noValidIndex)
        }
    }
    
    // API
    func disconnectPeripheral(_ uuid: UUID) {
        var idx: Int
        do {
            idx = try indexOf(uuid)
            centralManager?.cancelPeripheralConnection(btPeripherals[idx].cbPeripheral)
        } catch {
            scanner.btAlert.message = "Not advertising"
            scanner.btAlert.button = "OK"
            return
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("didConnect: \(String(describing: peripheral.name))")
        do {
            let idx = try indexOf(peripheral.identifier)
            let p = btPeripherals[idx].cbPeripheral
            //log("didConnectPeripheral: \(peripherals[idx].cbPeripheral.description)")
            p.delegate = self
            p.discoverServices(nil)
        } catch {
            log("didConnect: error: no longer in cache")  // timer has removed, it must have stopped advertising
            disconnectPeripheral(peripheral.identifier)
            scanner.btAlert.message = "Timeout"
            scanner.btAlert.button = "OK"
            btConnected!(peripheral.identifier, false, BTError.timeout)
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral) {
        log("didFailToConnect")
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("didDisconnectPeripheral")
    }
    
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // First filter: RSSI
        if -Settings.shared.rssiSlider > RSSI.doubleValue {
            return
        }
        if settings.logAdvertisements {
            log("---------------\(peripheral.name != nil ? peripheral.name! : "unknown")")
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
        }
        
        // get peripheral.name, localname and mfgData if any
        let pName = peripheral.name != nil ? peripheral.name! : "unknown"
        let lName = advertisementData["kCBAdvDataLocalName"] != nil ? (advertisementData["kCBAdvDataLocalName"] as? String)! : "unknown"
        
        let scanResponse = ScanResponse(lName)
        if settings.logAdvertisements {
//            log("serialNumber: \(scanResponse.serialNumber)")
//            log("sysCode: \(String(format: "%08x", scanResponse.sysCode))")
            log("--version: \(scanResponse.version)")
            log("--prodCode: \(String(format: "%08x", scanResponse.prodCode))")
            log("--capabilities: \(scanResponse.capabilities)")
            log("--flags: \(String(format: "%02x", scanResponse.flags))")
        }
        
        let mfgData = advertisementData["kCBAdvDataManufacturerData"] != nil ? (advertisementData["kCBAdvDataManufacturerData"] as? Data)! : Data()
        
        // primary services (this is actually done by the centralManager for us
        let pServices = advertisementData["kCBAdvDataServiceUUIDs"] != nil ? (advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID])! : [CBUUID]()
        // overflow services
        let sServices = advertisementData["kCBAdvDataOverflowServiceUUIDs"] != nil ? (advertisementData["kCBAdvDataOverflowServiceUUIDs"] as? [CBUUID])! : [CBUUID]()
     
        var type1: Type1? = nil
        var type4: Type4? = nil
        
        if mfgData.count > 4 && mfgData.hexEncodedString().starts(with: "f401") {
            
            var serialNo = UInt32(0xffffffff)
            var sysCode = UInt32(0xffffffff)
            if pName.contains(".") {
                let parts = pName.components(separatedBy: ".")
                serialNo = UInt32(parts[0])!
                sysCode = UInt32(parts[1], radix: 16)!
                //log("\(serialNo) \(sysCode)")
            }
            
            if settings.serialNoBegin != 0 && (serialNo < settings.serialNoBegin || serialNo > settings.serialNoEnd) {
                return
            }
            
            // TODO: add filter for SYSCODE
            
            
            // TODO: add filter for PRODCODE
            
            
            
            // parse DK mfg data
            var index = 2
            while index < mfgData.count {
                let type = mfgData[index]
                index += 1
                switch type {
                    
                case 1:
                    type1 = Type1(Data(mfgData[index..<index+6]))
                    index += 6
                    
                case 0x02:      // 1-way RMS event counter, not parsed
                    index += 2
                    
                case 0x03:      // 1-way RMS lock status data, not parsed
                    index += 12
                    
                case 0x04:
                    type4 = Type4(Data(mfgData[index..<index+6]))
                    index += 6
                    
                default:
                    log("\(mfgData.count) \(index)")
                    log("unexpected advertisement")
                    index += mfgData.count
                }
            }
        }
    
        // Apply Advertisement settings filter
        if !pServices.contains(CBUUID(string: UUIDs.DirectKeyPrimaryService)) && settings.isDKService {
            return
        }
        
        if type1 == nil || !type1!.opl {
            if settings.isOpl {
                return
            }
        } else {
            if settings.isNonOpl {
                return
            }
        }
        
        if settings.logAdvertisements {
            _ = pServices.map { log("\($0.uuidString)") }
            _ = sServices.map { log("\($0.uuidString)") }
            log("\(pName) \(lName) \(mfgData.hexEncodedString()) OPL: \(String(describing: type1?.opl)) MESH: \(type4 != nil)")
        }
        
        // add it in
        let rssiVal = RSSI.intValue
        do {
            let idx = try indexOf(peripheral.identifier)
            //btPeripherals[idx].name = pName != "unknown" ? pName : lName
            btPeripherals[idx].name = lName
            btPeripherals[idx].mfgData = mfgData
            btPeripherals[idx].scanResponse = scanResponse
            btPeripherals[idx].lastAdvertisement = Date()
            btPeripherals[idx].rssiList.append(RSSI.intValue)
            btPeripherals[idx].rssiCnt += 1
            if btPeripherals[idx].rssiCnt > Int(Settings.shared.rssiAverage) {
                btPeripherals[idx].rssiList.remove(at: 0)
                btPeripherals[idx].rssiCnt -= 1
            }
            btPeripherals[idx].rssiAvg = rssiAverage(btPeripherals[idx])
        } catch {
            //btPeripherals.append(BTPeripheral(cbPeripheral: peripheral, name: pName != "unknown" ? pName : lName,
            btPeripherals.append(BTPeripheral(cbPeripheral: peripheral, name: lName,
                                              mfgData: mfgData, scanResponse: scanResponse,
                                              rssiList: [rssiVal], rssiCnt: 1, rssiAvg: rssiVal, lastAdvertisement: Date()))
        }
    }
    
    internal func rssiAverage(_ btPeripheral: BTPeripheral) -> Int {
        var total = 0
        
        for i in 0..<btPeripheral.rssiCnt {
            total += btPeripheral.rssiList[i]
        }
        total /= btPeripheral.rssiCnt
        //log("\(btPeripheral.rssiList) \(total)")
        return total
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        log("didDiscoverServices \(String(describing: peripheral.services!.count))")
        if let e = error {
            log("error: \(e.localizedDescription)")
        }
        
        serviceMESH = nil
        serviceWWOR = nil
        serviceMSG = nil
        serviceEVT = nil
        
        serviceMESHChar = false
        serviceWWORChar = false
        serviceEVTChar = false
        serviceMSGChar = false
        
        //log("\(peripheral.identifier)")
        for service in peripheral.services! {
            //log("uuid \(ser.uuid.uuidString)")
            switch service.uuid.uuidString {
            case UUIDs.OnityMeshServiceReversed:
                //log("MESH \(ser.uuid.uuidString)")
                serviceMESH = service
            case UUIDs.OnityWWORServiceReversed:
                //log("WWOR \(ser.uuid.uuidString)")
                serviceWWOR = service
            case UUIDs.MessageServiceReversed:
                serviceMSG = service
            case UUIDs.RMSEventServiceReversed:
                serviceEVT = service
            default:
                log("service unknown: \(service.uuid.uuidString)")
                break
            }
        }
        //log("state: discover characteristics for WWOR")
        peripheral.discoverCharacteristics(nil, for: self.serviceWWOR!)
        serviceWWORChar = true
    }
    
    // called once for all characteristic per service
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        log("didDiscoverCharacteristics \(service.uuid.uuidString)")
        if let e = error {
            log("error: \(e.localizedDescription)")
        }
        
        let characteristics = service.characteristics
        for char in characteristics! {
            switch char.uuid.uuidString {
                
            case friendlyNameToUUID["TxBuffer"]:
                //log("save TxBuffer \(char.uuid.uuidString) characteristic")
                friendlyNameToCharacteristic["TxBuffer"] = char
                //log("subscribe to notifications for TxBuffer")
                peripheral.setNotifyValue(true, for: char)
                
            case friendlyNameToUUID["RxBuffer"]:
                //log("save RxBuffer \(char.uuid.uuidString) characteristic")
                friendlyNameToCharacteristic["RxBuffer"] = char
                
            case friendlyNameToUUID["MsgRteCtrl"]:
                //log("save MsgRteCtrl \(char.uuid.uuidString) characteristic")
                friendlyNameToCharacteristic["MsgRteCtrl"] = char
                
            case friendlyNameToUUID["NegMTUSize"]:
                //log("save NegMTUSize \(char.uuid.uuidString) characteristic")
                friendlyNameToCharacteristic["NegMTUSize"] = char
                
            default:
                //log("unneeded: \(char.uuid.uuidString) \(String(describing: uuidToFriendlyName[char.uuid.uuidString]))")
                break
            }
        }
        
        if serviceMSG != nil && serviceMSGChar == false {
            peripheral.discoverCharacteristics(nil, for: self.serviceMSG!)
            serviceMSGChar = true
            return
        }
        
        if serviceEVT != nil && serviceEVTChar == false {
            peripheral.discoverCharacteristics(nil, for: self.serviceEVT!)
            serviceEVTChar = true
            return
        }
        
        var hasMesh = true
        if serviceMESHChar == false {
            if service == serviceWWOR! {
                if self.serviceMESH == nil {
                    log("Non-MESH device")
                    hasMesh = false
                } else {
                    peripheral.discoverCharacteristics(nil, for: self.serviceMESH!)
                    serviceMESHChar = true
                    return
                }
            }
        }
        
        // finished the "connect" sequence, callback to upper level
        btConnected!(peripheral.identifier, hasMesh, BTError.none)
    }
    
    // MARK: - writing, reading, notifications
    
    // API
    // Write - write data
    func peripheralWrite(_ uuid: UUID, _ friendlyCharacteristic: String, _ data: [Data],
                         received:  @escaping (_ uuid: UUID, _ data: Data, _ error: Error?) -> Void) {
        //log("peripheralWrite \(friendlyCharacteristic) ")
        btReceived = received
        var idx: Int
        do {
            idx = try indexOf(uuid)
        } catch {
            scanner.btAlert.message = "Not advertising"
            scanner.btAlert.button = "OK"
            btConnected!(uuid, false, BTError.noValidIndex)
            return
        }
        
        var responseType: CBCharacteristicWriteType
        switch friendlyCharacteristic {
        case "RxBuffer":
            responseType = .withoutResponse
        case "MsgRteCtrl":
            responseType = .withResponse
        case "NegMTUSize":
            responseType = .withResponse
        default:
            responseType = .withResponse
        }
        let p = btPeripherals[idx].cbPeripheral
        if let c = self.friendlyNameToCharacteristic[friendlyCharacteristic] {
            //log("\(c!.uuid.uuidString)")
            for d in data {
                p.writeValue(Data(friendlyCharacteristic == "RxBuffer" ? oplToWwor(d) : d), for: c!, type: responseType)
            }
        } else {
            log("cannot write: \(friendlyCharacteristic) characteristic not found")
            scanner.btAlert.message = "\(friendlyCharacteristic) characteristic not found"
            scanner.btAlert.button = "OK"
        }
    }
    
    // Read - asynchronous data received, callback to upper level
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let recvData = characteristic.value else { return }
        //log("didUpdateValue \(recvData.hexEncodedString()) on \(characteristic.uuid.uuidString)")
        let data = wworToOPL(recvData)
        //log("de-WWOR \(data.hexEncodedString())")
        if scanner.wworRouting {
            let listData = OPLQueue.enqueue(OPLRaw([UInt8](data)))
            if listData.count == 0 { return }
            if let opl = OPL(listData) {
                //OPL.logOpl(opl)
                let pb = Data(opl.msgMessage)
                log("recv: appId: \(opl.routingCtl_AppId) msgType: \(String(format: "%02x", opl.msgType)) msgid: \(String(format: "%02x", opl.msgId)) pb = \(pb.hexEncodedString())")
                
                if opl.msgType == 0x30 {
                    let err =  try! NodeResponse(serializedData: pb)
                    log("response error: \(err.errorCode)")
                }
                
                
                
                btReceived!(peripheral.identifier, pb, error)
            }
        } else {
            btReceived!(peripheral.identifier, data, error)
        }
    }
    
    // WriteWithoutResponse Notification
    internal func peripheral(_ peripheral: CBPeripheral, didWriteValueFor: CBCharacteristic, error: Error?) {
        log("didWriteValue \(String(describing: error))")
        btReceived!(peripheral.identifier, Data(), error)
    }
}
