//
//  Addresses.swift
//  SnmpWalker
//
//  Created by Jelle Alten on 18-12-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import Foundation

public struct IPAddress: printable {

    let numbers: [UInt8]
    public var byteString: String {

        return numbers.map { (byte) -> String in

            return String(format: "%d", byte)
            }.joined(separator: ".")
    }
    var hexString: String {

        return numbers.reduce("") { (str, byte) -> String in

            return str.appendingFormat("%02x", byte)
        }
    }
    var uint32Value: UInt32 {

        var value: UInt32 = 0
        for byte in numbers {

            value <<= 8
            value += UInt32(byte)
        }
        return value
    }
    public init(uint32Value: UInt32) {

        var value = uint32Value
        var numbers = [UInt8]()
        for _ in 0..<4 {

            let byte = UInt8(value & 0xff)
            value >>= 8
            numbers.insert(byte, at: 0)
        }
        self.numbers = numbers
    }

    public init(bytes: [UInt8]) {

        numbers = bytes
    }
    public init(_ bytes: String) {

        let parts = bytes.components(separatedBy: ".").map { (byteStr) -> UInt8 in

            return UInt8(byteStr) ?? 0
            } as [UInt8]
        if parts.count >= 4 {

            numbers = Array(parts[0..<4])
        } else {

            print("invalid ip address: \(bytes)")
            numbers = parts
        }
    }
    public init?(_ bytes: String?) {

        if let bytes = bytes {

            self = IPAddress(bytes)
        } else {

            return nil
        }
    }

    public static func isValid(str ipStr: String) -> Bool {

        return ipStr.components(separatedBy: ".").count == 4
    }

    public var isValid: Bool {

        return numbers.count == 4
    }

}

func + (left: IPAddress, right: Int) -> IPAddress {

    let value = left.uint32Value + UInt32(right)
    return IPAddress(uint32Value: value)
}

extension IPAddress: Equatable, Comparable {

    public static func == (lhs: IPAddress, rhs: IPAddress) -> Bool {

        return lhs.numbers == rhs.numbers
    }

    public static func == (lhs: IPAddress, rhs: String) -> Bool {

        return lhs.byteString == rhs
    }

    public static func == (lhs: String, rhs: IPAddress) -> Bool {

        return lhs == rhs.byteString
    }

    public static func < (lhs: IPAddress, rhs: IPAddress) -> Bool {

        for (b1, b2) in zip(lhs.numbers, rhs.numbers) {

            if b1 < b2 { return true }
            if b1 > b2 { return false }
        }
        return false
        //       return lhs.hexString < rhs.hexString
    }
}

extension IPAddress: Hashable {

    public var hashValue: Int {

        return byteString.hash
    }
}

extension IPAddress: CustomStringConvertible {

}

extension IPAddress: CustomDebugStringConvertible {

    public var debugDescription: String {

        return byteString
    }
}


extension IPAddress: Encodable {

    public func encode(to encoder: Encoder) throws {

        try byteString.encode(to: encoder)
    }
}
