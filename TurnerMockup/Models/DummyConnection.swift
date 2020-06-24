//
//  DummyConnection.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

class DummyConnection {
    
    private var timer = Timer()
    var readings: [DummyReading] = []
    var testClosure: (() -> Void)?
    var graphClosure: (() -> Void)?
    
    struct DummyReading {
        var mV: Int
        var date: Date
    }
    
    private func addReading() {
        if readings.count == 0 {
            let number = Int.random(in: 1000...4000)
            readings.append(DummyReading(mV: number, date: Date()))
        } else {
            let lastReadingMV = readings[readings.count - 1].mV
            var low = lastReadingMV - 250
            var high = lastReadingMV + 250
            if low < 0 {low = 0}
            if high > 5000 {high = 5000}
            let newMV = Int.random(in: low...high)
            readings.append(DummyReading(mV: newMV, date: Date()))
        }
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
        //print("timer fired")
        addReading()
        
        testClosure?()
        graphClosure?()
    }
}

