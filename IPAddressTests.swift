//
//  IPAddressTests.swift
//  Networking_iOSTests
//
//  Created by Jelle Alten on 24-09-18.
//

import XCTest

class IPAddressTests: XCTestCase {

    func testBytesShouldNotChange() {

        var bytes: [UInt8] = [10, 1, 1, 1]
        let ip = IPAddress(bytes: bytes)

        XCTAssertEqual(ip.byteString, "10.1.1.1")

        bytes[0] = 100

        XCTAssertEqual(ip.byteString, "10.1.1.1")
    }

}
