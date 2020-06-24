//
//  DummyConnection.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

class BLEConnection: NSObject {
    
    //var centralManager: CBCentralManager!
    
    var peripheral: CBPeripheral!
    var txCharacteristic: CBCharacteristic!
    var rxCharacteristic: CBCharacteristic!
    var characteristicASCIIValue = NSString()
    
    private var timer = Timer()
    var readings: [Reading] = []
    var testClosure: (() -> Void)?
    var graphClosure: (() -> Void)?
    var disconnect: (() -> Void)?
    
    var gpsData: GPSData?
    
    struct Reading {
        var mV: Int
        var date: Date
        var gps: CLLocation?
    }
    
    public func initGPS() {
        gpsData = GPSData()
        gpsData?.getCoordinatesCompletion = didReceiveGPSData(forIndex:location:)
    }
    
    public func endGPS() {
        gpsData = nil
    }
    
    public func didReceiveGPSData(forIndex: Int, location: CLLocation) {
        self.readings[forIndex].gps = location
    }
    
    public func disconnected() {
        disconnect?()
    }
    
    public func addReading(mv: Int) {
        readings.append(BLEConnection.Reading(mV: mv, date: Date(), gps: nil))
        if gpsData != nil {
            let index = readings.count - 1
            gpsData?.getCoordinates(forIndex: index)
        }
        testClosure?()
        graphClosure?()
    }
    
    public func sensorPowerOn() {
        var sendVal: UInt8 = 87
        let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
        peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    public func sensorPowerOff() {
        var sendVal: UInt8 = 88
        let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
        peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    public func ledPowerOff() {
        var sendVal: UInt8 = 0
        let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
        peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    public func singleCapture(){
        fireFunction()
    }
    
    public func continuousCapture(){
        //timer = Timer(timeInterval: 2, target: self, selector: #selector(fireFunction), userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireFunction), userInfo: nil, repeats: true)
    }
    
    public func stop(){
        timer.invalidate()
    }
    
    @objc private func fireFunction(){
        var sendVal: UInt8 = 86
        let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
        peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
}

extension BLEConnection: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
}

extension BLEConnection: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
                
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
                print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        guard let descriptors = characteristic.descriptors else { return }
            
        descriptors.forEach { descript in
            print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
            print("Rx Value \(String(describing: rxCharacteristic?.value))")
            print("Tx Value \(String(describing: txCharacteristic?.value))")

        }
    }
 
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
                guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Message sent")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard characteristic == rxCharacteristic,
        let characteristicValue = characteristic.value,
        let ASCIIstring = NSString(data: characteristicValue,
                                       encoding: String.Encoding.utf8.rawValue)
        else { return }
        
        characteristicASCIIValue = ASCIIstring
        print("Value Recieved: \((characteristicASCIIValue as String))")
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
                print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
}
