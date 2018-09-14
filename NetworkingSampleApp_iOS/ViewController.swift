//
//  ViewController.swift
//  SnmpSampleApp_iOS
//
//  Created by Jelle Alten on 30-11-17.
//

import UIKit
import SwiftyNetworking

class ViewController: UIViewController {

    var serialNumber: String?

    override func viewDidLoad() {

        super.viewDidLoad()
        print(Networking.getWiFiAddress())

        doNothing_justCompile()

    }

    @IBAction func startScanning(_ sender: Any) {

    }

    func doNothing_justCompile() {

        let ipAddress = IPAddress("1.1.1.1")
        let macAddress = MacAddress(hex: "01:02:03:04:05:06")
        print(ipAddress.byteString)
        print(macAddress.byteString)

        _ = "0f0f0a00d00f0".bytesFromHex
    }
}
