//
//  ConnectedVC.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ConnectedVC: UIViewController {
    
    enum RunState {
        case continuous
        case stop
    }
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var graphView: GraphView!
    //@IBOutlet weak var graphView: UIView!
    @IBOutlet weak var btnTable: UIButton!
    @IBOutlet weak var btnGraph: UIButton!
    
    @IBOutlet weak var btnContinuousCapture: UIButton!
    @IBOutlet weak var btnSingleCapture: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    
    @IBOutlet weak var switchSensorPower: UISwitch!
    @IBOutlet weak var switchGPSEnable: UISwitch!
    
    var btnLED: UIButton?
    
    var runState: RunState!
    //var connection: DummyConnection!
    var connection: BLEConnection!
    var cbPeripheralManager: CBPeripheralManager?
    
    var dateFormatter: DateFormatter!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.runState = RunState.stop
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        //dateFormatter.dateStyle = .medium
        //dateFormatter.timeStyle = .long
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let barbtnAction = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(exportData))
        
        let imgLED = UIImage(named: "LEDIconOn")
        btnLED = UIButton(type: UIButton.ButtonType.custom)
        btnLED!.setImage(imgLED, for: UIControl.State.normal)
        let barbtnLED = UIBarButtonItem(customView: btnLED!)
        
        self.navigationItem.rightBarButtonItems = [barbtnLED, barbtnAction]
        //self.navigationItem.rightBarButtonItem = barbtnLED
        //let btnLED = UIBarButtonItem(image: imgLED, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
        
        //self.navigationItem.rightBarButtonItems?.append(btnLED)
        
        let fadeWhite = UIColor(white: 1.0, alpha: 0.3)
        
        self.navigationItem.title = "Connected"
        
        table.layer.cornerRadius = 10
        table.layer.masksToBounds = true
        table.backgroundColor = fadeWhite
        table.separatorStyle = .none
        
        btnContinuousCapture.backgroundColor = fadeWhite
        btnContinuousCapture.layer.cornerRadius = 17
        btnContinuousCapture.layer.masksToBounds = true
        
        btnSingleCapture.backgroundColor = fadeWhite
        btnSingleCapture.layer.cornerRadius = 17
        btnSingleCapture.layer.masksToBounds = true
        
        btnStop.backgroundColor = fadeWhite
        btnStop.layer.cornerRadius = 17
        btnStop.layer.masksToBounds = true
        
        graphView.isHidden = true
        graphView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        
        connection.testClosure = updateTable
        connection.graphClosure = updateGraph
        connection.disconnect = setDisconnected
    }
    
    private func setDisconnected() {
        let imgOffLED = UIImage(named: "LEDIconOff")
        self.navigationItem.title = "Disconnected"
        btnLED?.setImage(imgOffLED, for: UIControl.State.normal)
    }
    
    
    @IBAction func singleCapture(_ sender: UIButton) {
        if self.runState == RunState.stop {
            connection.singleCapture()
//            var sendVal: UInt8 = 86
//            let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
//            peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    @IBAction func beginRecord(_ sender: UIButton) {
        if self.runState == RunState.stop {
            connection.continuousCapture()
//            var sendVal: UInt8 = 85
//            let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
//            peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            
            self.runState = RunState.continuous
        }
    }
    
    @IBAction func stopRecord(_ sender: UIButton) {
        if self.runState == RunState.continuous {
            
            print("stop record")
            connection.stop()
//            var sendVal: UInt8 = 84
//            let NSsendVal = NSData(bytes: &sendVal, length: MemoryLayout<Int8>.size)
//            peripheral.writeValue(NSsendVal as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            
            self.runState = .stop
        }
    }
    
    
    @IBAction func switchSensorPowerOnChange(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            connection.sensorPowerOn()
        case false:
            connection.ledPowerOff()
        }
    }
    
    @IBAction func switchGPSonChange(_ sender: UISwitch) {
        switch switchGPSEnable.isOn {
        case true:
            connection.initGPS()
        case false:
            connection.endGPS()
        }
    }
    
    @IBAction func btnTableOnPress(_ sender: UIButton) {
        btnGraph.backgroundColor = UIColor.clear
        btnTable.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        self.table.isHidden = false
        self.graphView.isHidden = true
    }
    
    @IBAction func btnGraphOnPress(_ sender: UIButton) {
        btnTable.backgroundColor = UIColor.clear
        btnGraph.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        self.table.isHidden = true
        self.graphView.isHidden = false
        
        self.graphView.setNeedsDisplay()
    }
    
    func updateTable() {
        //print("update the table, please")
        DispatchQueue.main.async {
            //self.table.reloadData()
            self.table.beginUpdates()
            
            let path = IndexPath(row: self.connection.readings.count-1, section: 0)
            self.table.insertRows(at: [path], with: .automatic)
            
            self.table.endUpdates()
            
            self.table.scrollToRow(at: path, at: .bottom, animated: true)
        }
    }
    
    @objc func exportData(){
        
        
        
        let filename = String(describing: NSDate.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "").appending(".csv")
        let filepath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(filename)
        
        var fileText = "Date,mV,Latitude,Longitude,Altitude,\n"
        
        for reading in connection.readings {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let dateInFormat = dateFormatter.string(from: reading.date)
            
            var lat = "n/a"
            var long = "n/a"
            var altitude = "n/a"
            
            if let location = reading.gps {
                lat = "\(location.coordinate.latitude)"
                long = "\(location.coordinate.longitude)"
                altitude = "\(location.altitude)"
            }
            
            let newLine = "\(dateInFormat),\(reading.mV),\(lat),\(long),\(altitude),\n"
            fileText.append(contentsOf: newLine)
        }
        
        do {
            try fileText.write(to: filepath, atomically: true, encoding: String.Encoding.utf8)
            
            let activityVC = UIActivityViewController(activityItems: [filepath], applicationActivities: [])
            activityVC.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.postToTwitter
            ]
            
            present(activityVC, animated: true) {
                print("activity vc completion")
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func updateGraph() {
        
        if let reading = connection.readings.last{
            graphView.push(reading: reading)
        }

        
        if !graphView.isHidden {
            graphView.redraw()
        }
    }
    
    public func receiveData(dataReadingMV: Int) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ConnectedVC: UITableViewDelegate {
    
}

extension ConnectedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connection.readings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: nil)
        
        //cell.textLabel?.text = connection.readings[indexPath.row]
        let a = connection.readings[indexPath.row]
        cell.textLabel?.text = "\(a.mV) mV"
        let dateText = dateFormatter.string(from: a.date)

        cell.detailTextLabel?.text = dateText
        
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }
}

extension ConnectedVC: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
}


class GraphView: UIView {
    
    var maxPoints = 30
    var dataPoints = [BLEConnection.Reading]()
    
    public func push(reading: BLEConnection.Reading){
        if dataPoints.count > maxPoints {
            pop()
        }
        
        dataPoints.append(reading)
    }
    
    private func pop(){
        dataPoints.removeFirst()
    }
    
    public func redraw() {
        self.setNeedsDisplay()
    }
    
    private func mapY(at: Int) -> CGFloat {
        let reading = Double(dataPoints[at].mV)
        let scaled = reading / 5000.0
        return self.frame.height - (CGFloat(scaled) * self.frame.height)
    }
    
    private func testPath() -> UIBezierPath {
        let begin = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: self.frame.width, y: self.frame.height)
        let path = UIBezierPath()
        path.move(to: begin)
        path.addLine(to: end)
        return path
    }
    
    private func bigTickPaths() -> [UIBezierPath] {
        
        var paths = [UIBezierPath]()
        
        for index in 1...4 {
            let path = UIBezierPath()
            let beginY =  (self.frame.height / 5.0) * CGFloat(index)
            let begin = CGPoint(x: 25.0, y: beginY)
            path.move(to: begin)
            path.addLine(to: CGPoint(x: self.frame.width-5.0, y: beginY))
            path.lineWidth = 0.2
            paths.append(path)
        }
        
        return paths
    }
    
    private func smallTickPaths() -> [UIBezierPath] {
        var paths = [UIBezierPath]()
        
        for index in 1...25 {
            if index % 5 != 0 {
                let path = UIBezierPath()
                let beginY = (self.frame.height / 25.0) * CGFloat(index)
                let begin = CGPoint(x: 5.0, y: beginY)
                path.move(to: begin)
                path.addLine(to: CGPoint(x: self.frame.width-5.0, y: beginY))
                path.lineWidth = 0.1
                paths.append(path)
            }
        }
        
        return paths
    }
    
    private func dataPath() -> UIBezierPath {

        let begin = CGPoint(x: CGFloat(15.0), y: mapY(at: 0))
        let path = UIBezierPath()
        path.move(to: begin)
        
        for index in 1..<dataPoints.count {
            let segments = dataPoints.count-1
            let segmentWidth = (self.frame.width - 30.0) / CGFloat(segments)
            
            let x = (CGFloat(index) * segmentWidth) + 15.0
            let y = mapY(at: index)
            
            let point = CGPoint(x: x, y: y)
            path.addLine(to: point)
        }
        
        return path
    }
    
    private func getLabels() -> [UILabel] {
        var labels = [UILabel]()
        
        for index in 1...4 {
            let text = "\(index).0v"
            let label = UILabel()
            label.text = text
            labels.append(label)
        }
        
        return labels
    }
    
    override func draw(_ rect: CGRect) {
        
        if dataPoints.count <= 1 {
            testPath().stroke()
            return
        } else {
            for bigPath in bigTickPaths() {
                bigPath.stroke()
            }
            
            for smallPath in smallTickPaths() {
                smallPath.stroke()
            }
            
//            for index in 1...4 {
//                let text = "\(index).0v"
//                let label = UILabel()
//                label.text = text
//                self.addSubview(label)
//                let y = self.frame.height - ((self.frame.height / 5.0) * CGFloat(index))
//                label.center = CGPoint(x: 30.0, y: y)
//            }
            
            dataPath().stroke()
        }
    }
    
}


