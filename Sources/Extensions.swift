//
//  Extensions.swift
//  networking
//
//  Created by Jelle Alten on 13-09-18.
//

import Foundation

public extension String {

    public var bytesFromHex: [UInt8] {

        var bytes = [UInt8]()

        if let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) {

            regex.enumerateMatches(in: self, options: [], range: NSRange(0..<count)) { match, flags, stop in

                let hexString = (self as NSString).substring(with: match!.range)
                if let byte = UInt8(hexString, radix: 16) {

                    bytes.append(byte)
                }
            }
        }

        return bytes
    }
}


protocol printable: CustomStringConvertible {

    var numbers: [UInt8] { get }
    var byteString: String { get }
}

extension printable {

    public var byteString: String {

        return numbers.map { (byte) -> String in

            return String(format: "%d", byte)
            }.joined(separator: ".")
    }
    public var description: String {

        return byteString
    }
}

