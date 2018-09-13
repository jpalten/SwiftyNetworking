//
//  MacAddressTests.swift
//  SnmpWalker
//
//  Created by Jelle Alten on 11-12-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import XCTest
import Snmp

class MacAddressTests: XCTestCase {

    func testConversion() {
        let macAddress = MacAddress( bytes: (1, 2, 3, 4, 5, 6) )
        XCTAssertEqual(macAddress.hexString, "01:02:03:04:05:06")
        XCTAssertEqual(macAddress.byteString, "1.2.3.4.5.6")
    }

    func testInitHex() {
        let macStr = "9c:8e:99:85:c6:4f"
        let macAddress = MacAddress(hex:macStr)
        XCTAssertEqual(macAddress.hexString, macStr)
        print(macAddress.byteString)
    }

    func testInitHexNoZeros() {
        let macStr = "0:e:99:85:c6:4f"
        let macAddress = MacAddress(hex:macStr)
        XCTAssertEqual(macAddress.hexString, "00:0e:99:85:c6:4f")
        print(macAddress.byteString)
    }

    func testInitByte() {
        let byteStr = "156.142.153.133.198.79"
        let macAddress = MacAddress(bytes:byteStr)
        XCTAssertEqual(macAddress.byteString, byteStr)
    }

    func testInitString() {

        let tests : [String:String] = [
            "lqq8j=" : "6c:71:71:38:6a:3d",
        ]

        for (input,output) in tests {

            let macAddress = MacAddress(input)
            XCTAssertEqual(macAddress?.hexString, output)
        }
    }

}
