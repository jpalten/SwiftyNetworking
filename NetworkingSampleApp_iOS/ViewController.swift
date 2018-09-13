//
//  ViewController.swift
//  SnmpSampleApp_iOS
//
//  Created by Jelle Alten on 30-11-17.
//

import UIKit
import SwiftyNetworking

class ViewController: UIViewController {

    var serialNumber: String? = nil

    override func viewDidLoad() {

        super.viewDidLoad()
        print(Networking.getWiFiAddress())

    }

    @IBAction func startScanning(_ sender: Any) {

    }
}

