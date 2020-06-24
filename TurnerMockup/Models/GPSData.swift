//
//  GPSData.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 4/10/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import CoreLocation

class GPSData: NSObject {
    
    var locationManager = CLLocationManager()
    var requestCallIndices = [Int]()
    var getCoordinatesCompletion: ((_ index: Int, _ location: CLLocation) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters//kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    }
    
    public func getCoordinates(forIndex: Int) {
        requestCallIndices.append(forIndex)
        locationManager.requestLocation()
    }
}

extension GPSData: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            if let firstIndex = requestCallIndices.first {
                print("index \(firstIndex): \(location.coordinate.latitude),\(location.coordinate.longitude)")
                requestCallIndices.remove(at: 0)
                getCoordinatesCompletion?(firstIndex, location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
