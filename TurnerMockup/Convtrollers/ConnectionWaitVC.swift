//
//  ConnectionWaitVC.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectionWaitVC: UIViewController {
    
    var centralManager: CBCentralManager!
    var blePeripheral: CBPeripheral?
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    
    var bleConnection: BLEConnection?

    //var updateReading: ((_ readingMV: Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centralManager = CBCentralManager()
        centralManager.delegate = self
        // Do any additional setup after loading the view.
        
        let hud = UIActivityIndicatorView(style: .whiteLarge)
        hud.startAnimating()
        
        view.addSubview(hud)
        hud.center = view.center
        
        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            //self.performSegue(withIdentifier: "ConnectedSegue", sender: self)
            //self.performSegue(withIdentifier: "ConnectedSegue", sender: self)
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        centralManager.stopScan()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? ConnectedVC {
            bleConnection = BLEConnection()
            bleConnection!.peripheral = blePeripheral!
            bleConnection!.txCharacteristic = txCharacteristic!
            bleConnection!.rxCharacteristic = rxCharacteristic!
            vc.connection = bleConnection!
        }
    }
}



extension ConnectionWaitVC: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("bluetooth enabled")
            centralManager.scanForPeripherals(withServices: [BLEService_UUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Did Discover Peripheral: \(peripheral.name ?? "no name")")
        blePeripheral = peripheral
        centralManager.connect(blePeripheral!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to: \(peripheral.name ?? "no name")")
        centralManager.stopScan()
        
        blePeripheral!.delegate = self
        
        blePeripheral!.discoverServices([BLEService_UUID])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.75) {
            self.performSegue(withIdentifier: "ConnectedSegue", sender: self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from: \(peripheral.name ?? "no name")")
        bleConnection?.disconnected()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connection failed.")
    }
}

extension ConnectionWaitVC: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("discovering peripheral services")
        
        if error != nil {
            print(error?.localizedDescription as Any)
            return
        }
        
        guard let services = peripheral.services else {
            print("couldn't get peripheral services")
            return
            
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("discovering peripheral characteristics")
        
        if error != nil {
            print(error?.localizedDescription as Any)
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("couldn't get service characteristics")
            return}
        
        for characteristic in characteristics {
            
            print("service characteristic rx tx: \(characteristic.uuid.uuidString)")
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx) {
                rxCharacteristic = characteristic
                
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
            } else {
                print("rxCharacteristic init failed")
            }
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx) {
                txCharacteristic = characteristic
            } else {
                print("txCharacteristic init failed")
            }
            
            peripheral.discoverDescriptors(for: characteristic)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
            
            if let value = characteristic.value {
                if let inString = NSString(data: value, encoding: String.Encoding.utf8.rawValue) as String? {
                    print(inString)
                }
            } else {
                print("rxCharacteristic value nil")
            }
            
            if let inString = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) as String? {
                
                let strArr = inString.components(separatedBy: "*")
                if strArr.count > 2 {
                    let readingStr = strArr[1]
                    
                    if let rawReading = Int(readingStr) {
                        let adjReading = ((rawReading * 5000) / 563)
                        print("reading in mV: \(adjReading)")
                        //self.updateReading?(adjReading)
                        self.bleConnection?.addReading(mv: adjReading)
                    }
                }
                //let readingStr = inString.components(separatedBy: "*")[1]
                
                //print("reading: \()")
                
                let charArr = Array(inString)
                print(charArr)
                
                //bleReadString = inString
                //print(bleReadString)
                
            }
        }
    }
}

