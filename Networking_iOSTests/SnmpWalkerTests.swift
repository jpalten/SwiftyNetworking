//
//  SnmpWalkerTests.swift
//  SnmpWalkerTests
//
//  Created by Jelle Alten on 10-12-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import XCTest

class SnmpWalkerTests: XCTestCase {
    var devices = [IPAddress:ManagedDevice]()
    var gateways = [IPAddress]()

    override func setUp() {
        devices = [IPAddress:ManagedDevice]()
    }

    func testCompareIPAddress() {
        XCTAssertFalse(IPAddress("192.168.6.1") > IPAddress("192.168.6.50") )

        XCTAssertTrue( IPAddress("192.168.6.1") < IPAddress("192.168.6.50") )
        XCTAssertTrue( IPAddress("192.168.6.1") < IPAddress("192.168.6.29") )
    }

    func testReadAll_6days() {
        fetchDevices(filename: "6days_devices")
        XCTAssertEqual(devices.count, 16)
        fetchConnections(filename: "6days_snmp_filtered")
        let switch5 = devices[IPAddress("192.168.6.5")]
        let connectedDevicesPort31 = switch5?.attached(toPort: 31)
        XCTAssertEqual(connectedDevicesPort31?.count, 119)
        let connectedDevicesPort44 = switch5?.attached(toPort: 44)
        XCTAssertEqual(connectedDevicesPort44?.count, 1)

        dumpConnections()
    }

    func skip_testPerformance1() {
        fetchDevices(filename: "e-e_devices")
        fetchConnections(filename: "e-e_snmp_filtered")
        measure() {
            let analyser = Analyser()
            analyser.devices = self.devices.map { $0.value }
            try? analyser.findConnections()
            try? analyser.findConnections_bySteppingBetween()
        }
    }

}

extension SnmpWalkerTests : TestFileReader {

}
