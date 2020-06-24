//
//  ViewController.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/21/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var btnProducts: UIButton!
    @IBOutlet weak var btnInformation: UIButton!
    @IBOutlet weak var btnConnectDevice: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        graphicsSetup()
        //self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        //self.navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.902, green: 0.922, blue: 0.918, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.clipsToBounds = true
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()

    }
    
    private func graphicsSetup(){
        btnProducts.layer.cornerRadius = 25
        btnProducts.layer.masksToBounds = true
        
        btnInformation.layer.cornerRadius = 25
        btnInformation.layer.masksToBounds = true
        
        btnConnectDevice.layer.cornerRadius = 25
        btnConnectDevice.layer.masksToBounds = true
        
    }
    
    @IBAction func onPressProducts(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressInformation(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressConnectDevice(_ sender: UIButton) {
        //let testConnection = DummyConnection()
        //testConnection.run()
        self.performSegue(withIdentifier: "ConnectToDeviceSegue", sender: self)
    }
    
    @IBAction func onPressSignIn(_ sender: UIButton) {
    }
    
}



