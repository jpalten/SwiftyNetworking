//
//  ViewController.swift
//  SnmpSampleApp_iOS
//
//  Created by Jelle Alten on 30-11-17.
//

import UIKit
import Snmp

class ViewController: UIViewController {

    let snmpDiscovery = SnmpDiscoverySocket(queue: scanQueue)
    static var scanQueue = DispatchQueue(label: "snmp discovery")
    let socketQueue = DispatchQueue(label: "snmp walking")
    var snmpSocks = [IPAddress:SnmpReceiver]()

    var serialNumber: String? = nil

    override func viewDidLoad() {

        super.viewDidLoad()

        snmpDiscovery.delegate = self
    }

    @IBAction func startScanning(_ sender: Any) {

        snmpDiscovery.startDiscovery(discoveryRequestOid: Oid.sysDescr_0)

//        to get the serial number back instead of system description
//        snmpDiscovery.startDiscovery(discoveryRequestOid: Oid.entPhysicalSerialNum_1)
    }
}

extension ViewController : SnmpProbeDelegate {

    func snmpDiscovered(deviceWithIp ipAddress: IPAddress, value: String?, oids: [String: SnmpValue]?) {

        print("found snmp on \(ipAddress) \(value ?? "")")

        socketQueue.async { [weak self] in

//            print("start walking \(ipAddress)")
//            self?.startSnmpWalk(forIp: ipAddress)

            if ipAddress == "10.1.1.222" {
                print("find serial number for \(ipAddress)")
                self?.snmpFindSerialNumber(forIp: ipAddress)
            } else if ipAddress == "10.10.1.2" || value?.starts(with: "ArubaOS (MODEL: Aruba7205)") == true {
                self?.getArubaInfo(forIp: ipAddress)
            }
        }
    }

    func snmpFailed(deviceWithIp ipAddress: IPAddress) {

    }
}

extension ViewController: SnmpDelegate {

    func getArubaInfo(forIp ipAddress: IPAddress) {

        var sock : SnmpReceiver = SnmpClientSocket(ipAddress: ipAddress, queue: socketQueue)
        sock.delegate = self
        snmpSocks[ipAddress] = sock
        sock.startGatheringInfo(forOids: Oid.interestingOids + Oid.interestingWlanOids)
    }

    func startSnmpWalk(forIp ipAddress: IPAddress) {

        let sock = SnmpClientSocket(ipAddress: ipAddress, queue: socketQueue)
        sock.delegate = self
        snmpSocks[ipAddress] = sock
        sock.startGatheringInfo()
    }

    func snmpFindSerialNumber(forIp ipAddress: IPAddress) {
        let sock = SnmpClientSocket(ipAddress: ipAddress, queue: socketQueue)
        sock.delegate = self
        snmpSocks[ipAddress] = sock
        sock.getSerialNumber()
    }


    func snmpDiscovered(deviceWithIp ipAddress: IPAddress) {
        print("found snmp on \(ipAddress)")
    }
    
    func snmpRecieved(from ipAddress: IPAddress, oidValues: [String:SnmpValue], topOid: Oid?) {
        for (_, value) in oidValues.sorted(by: { $0.0 < $1.0 }) {

            if serialNumber == nil, case let SnmpValue.string(serial) = value, serial != "" {
                serialNumber = serial
                print("found serial number \(serial)!")
                break
            }
        }
    }
    func snmpFinished(for ipAddress: IPAddress) {
        if serialNumber == nil{
            print("no serial number :-(")
        }

    }
    func snmpConnectionClosed(for ipAddress: IPAddress, withError error: Error?) {

    }

}
