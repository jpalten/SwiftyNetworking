//
//  MacAddressTests.swift
//  SnmpWalker
//
//  Created by Jelle Alten on 11-12-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import XCTest

class MacAddressTests: XCTestCase {

    func testConversion() {

        let macAddress = MacAddress( bytes: (1, 2, 3, 4, 5, 6) )
        XCTAssertEqual(macAddress.hexString, "01:02:03:04:05:06")
        XCTAssertEqual(macAddress.byteString, "1.2.3.4.5.6")
    }

    func testInitHex() {

        let macStr = "9c:8e:99:85:c6:4f"
        let macAddress = MacAddress(hex: macStr)
        XCTAssertEqual(macAddress.hexString, macStr)
        print(macAddress.byteString)
    }

    func testInitHexNoZeros() {

        let macStr = "0:e:99:85:c6:4f"
        var macAddress = MacAddress(hex: macStr)
        XCTAssertEqual(macAddress.hexString, "00:0e:99:85:c6:4f")
        print(macAddress.byteString)
    }

    func testInitByte() {

        let byteStr = "156.142.153.133.198.79"
        let macAddress = MacAddress(bytes: byteStr)
        XCTAssertEqual(macAddress.byteString, byteStr)
    }

    func testInitString() {

        let tests: [String: String] = [
            "lqq8j=": "6c:71:71:38:6a:3d"
        ]

        for (input, output) in tests {

            let macAddress = MacAddress(input)
            XCTAssertEqual(macAddress?.hexString, output)
        }
    }

    func testCodable() {

        let mac = MacAddress("01:02:03:04:05:06")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        do {

            let container = [ "mac": mac ]
            let newData = try encoder.encode(container)

            print(String(data: newData, encoding: .utf8) ?? "no proper data?")

            let newContainer = try decoder.decode([String: MacAddress].self, from: newData)
            XCTAssertEqual(newContainer["mac"], container["mac"])

        } catch let error {

            XCTFail("\(error)")
        }
    }

    let MAX_COUNT = 10000
    let numbers = [1, 2, 3, 4, 5, 6].map { UInt8($0) }

    func testPerformanceHexStrings1() {

        // This is an example of a performance test case.

        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.hexString(ofBytes: numbers)
            }
        }
    }

    func testPerformanceHexStrings2() {

        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.hexFormatted_1(ofBytes: numbers)
            }
        }
    }

    func testPerformanceHexStrings3() {

        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.hexFormatted_2(ofBytes: numbers)
            }
        }
    }

    func testPerformanceHash() {

        let macAddress = MacAddress(numbers: numbers)
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = macAddress.hashValue
            }
        }
    }
    func testPerformanceHash1() {

        let macAddress = MacAddress(numbers: numbers)
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = macAddress.hashValue_string
            }
        }
    }
    func testPerformanceEqual1() {

        let macAddress1 = MacAddress(numbers: numbers)
        let macAddress2 = MacAddress(hex: "08:07:06:05:04:03")
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = macAddress1 == macAddress2
            }
        }
    }
    func testPerformanceEqual2() {

        let macAddress1 = MacAddress(numbers: numbers)
        let macAddress2 = MacAddress(hex: "08:07:06:05:04:03")
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.eq( lhs: macAddress1, rhs: macAddress2)
            }
        }
    }
    func testPerformanceEqual3() {

        let macAddress1 = MacAddress(numbers: numbers)
        let macAddress2 = MacAddress(hex: "08:07:06:05:04:03")
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.eq_str( lhs: macAddress1, rhs: macAddress2)
            }
        }
    }

    func testPerformanceLessThan2() {

        let macAddress1 = MacAddress(numbers: numbers)
        let macAddress2 = MacAddress(hex: "08:07:06:05:04:03")
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.lt_str( lhs: macAddress1, rhs: macAddress2)
            }
        }
    }

    func testPerformanceLessThan1() {

        let macAddress1 = MacAddress(numbers: numbers)
        let macAddress2 = MacAddress(hex: "08:07:06:05:04:03")
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.lt_numbers( lhs: macAddress1, rhs: macAddress2)
            }
        }
    }
    func testPerformanceLessThan3() {

        let macAddress1 = MacAddress(numbers: numbers)
        let macAddress2 = MacAddress(hex: "08:07:06:05:04:03")
        self.measure {

            for _ in 0..<MAX_COUNT {

                _ = MacAddress.lt_hash( lhs: macAddress1, rhs: macAddress2)
            }
        }
    }

}
