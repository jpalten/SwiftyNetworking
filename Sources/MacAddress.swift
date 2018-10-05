//
//  Addresses.swift
//  SnmpWalker
//
//  Created by Jelle Alten on 18-12-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
public struct MacAddress {

    let numbers: [UInt8]
    public lazy var hexString: String  = {

        return MacAddress.hexString(ofBytes: numbers)
    }()
    var vendorPrefix: String {

        let hexStr = numbers.map { (byte) -> String in

            return String(format: "%02x", byte)
            }.joined(separator: "")
        return String(hexStr.prefix(6))
    }
    public var byteString: String {

        return numbers.map { (byte) -> String in

            return String(format: "%d", byte)
            }.joined(separator: ".")
    }

    public init( bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) ) {

        let (b1, b2, b3, b4, b5, b6) = bytes
        numbers = [b1, b2, b3, b4, b5, b6]
    }

    public init(numbers: [UInt8]) {

        self.numbers = numbers
    }

    public init(hex: String) {

        numbers = hex.bytesFromHex
    }

    public init(data: Data) {

        numbers = data.map { UInt8($0) }
    }

    public init(bytes: String) {

        let parts = bytes.components(separatedBy: ".").map { (byteStr) -> UInt8 in

            return UInt8(byteStr) ?? 0
        }
        numbers = parts
    }

    public init(chars: String) {

        numbers = chars.utf8.map { UInt8($0) }
    }

    public init?(_ str: String?) {

        guard let str = str else {

            return nil
        }

        if str.components(separatedBy: ":").count == 6 || str.lengthOfBytes(using: .utf8) == 12 {

            self = MacAddress(hex: str)
        } else if str.utf8.count == 6 {

            self = MacAddress(chars: str)
        } else {

            return nil
        }
    }

    public var isValid: Bool {

        return numbers.count == 6 && numbers != [0, 0, 0, 0, 0, 0] && numbers != [255, 255, 255, 255, 255, 255]
    }

    internal static func hexString(ofBytes numbers: [UInt8]) -> String {

        return numbers.map { (byte) -> String in

            let hex = String(byte, radix: 16, uppercase: false)
            return byte < 16 ? "0" + hex : hex
            }.joined(separator: ":")
    }

    internal static func hexFormatted_1(ofBytes numbers: [UInt8]) -> String {

        return numbers.map { (byte) -> String in

            return String(format: "%02x", byte)
            }.joined(separator: ":")
    }

    internal static func hexFormatted_2(ofBytes numbers: [UInt8]) -> String {

        return String(format: "%02x:%02x:%02x:%02x:%02x:%02x", arguments: numbers)
    }

}
//
//extension MacAddress: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        <#code#>
//    }
//
//
//    public var debugDescription: String { mutating get {return hexString }
//    }
//}

extension MacAddress: Equatable {

    public static func == (lhs: MacAddress, rhs: MacAddress) -> Bool {

        return lhs.numbers == rhs.numbers
    }
//    public static func < ( lhs: MacAddress, var rhs: MacAddress) -> Bool {
//
//        return lhs.hexString < rhs.hexString
//    }
}

extension MacAddress: Hashable {

    public var hashValue: Int {

        return numbers.reduce(0) { result, number in

            return result * 256 + Int(number)
        }
    }
}

//extension MacAddress: printable {
//
//    public var description: String {
//
//        return hexString
//    }
//}

//extension MacAddress: CustomStringConvertible {
//
//}

extension MacAddress: Codable {

    public func encode(to encoder: Encoder) throws {

        try MacAddress.hexString(ofBytes: numbers).encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {

        let hex = try String(from: decoder)
        numbers = hex.bytesFromHex
    }
}
