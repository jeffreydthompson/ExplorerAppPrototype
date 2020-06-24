//
//  UUIDKey.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 4/9/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import CoreBluetooth
//Uart Service uuid


//arduino nano 33 ble:  19B10000-E8F2-537E-4F6C-D104768A1214
//  19B10000-E8F2-537E-4F6C-D104768A1214
let kBLEService_UUID = "19B10000-E8F2-537E-4F6C-D104768A1214"
//                                 19B10001-E8F2-537E-4F6C-D104768A1214
let kBLE_Characteristic_uuid_Tx = "19B10001-E8F2-537E-4F6C-D104768A1214"
let kBLE_Characteristic_uuid_Rx = "19B10002-E8F2-537E-4F6C-D104768A1214"
let MaxCharacters = 20


// adafruit unit:
/*let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
let MaxCharacters = 20*/

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
