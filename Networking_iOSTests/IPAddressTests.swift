//
//  IPAddressTests.swift
//  Networking_iOSTests
//
//  Created by Jelle Alten on 29-09-18.
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

    func testCodable() {

        let ip = IPAddress("128.0.0.1")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        do {

            let container = [ "ip": ip ]
            let newData = try encoder.encode(container)

            print(String(data: newData, encoding: .utf8) ?? "no proper data?")

            let newContainer = try decoder.decode([String: IPAddress].self, from: newData)
            XCTAssertEqual(newContainer["ip"], container["ip"])

        } catch let error {

            XCTFail("\(error)")
        }
    }
}
