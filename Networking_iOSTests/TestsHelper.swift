//
//  TestsHelper.swift
//  NetworkNinja
//
//  Created by Jelle Alten on 26-12-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import Foundation

class TestsHelper {

    static func loadDatagramsFromHexStringsInFile(name: String) -> [Data]? {

        var packets = [Data]()

        guard let path = Bundle.fixturePath(fromFile: name, withExtension: "hex") else {

            assert(false, "can't load file \(name)")
            return nil
        }

        if let reader = StreamReader(path: path.absoluteString) {

            var count = 0
            for line in reader {

                let hexString: String
                if line.contains("data: "),
                    let rest = line.components(separatedBy: "data: ").last {

                    hexString = rest
                } else {

                    hexString = line
                }
                if let datagram = hexString.dataFromHex {

                    //                    if count > 2460 {
                    packets.append(datagram)
                    //                    }
                    count += 1
                }
            }
        }
        return packets
    }

}

private let hexRegex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)

extension String {

    var dataFromHex: Data? {

        var data = Data()

        if let regex = hexRegex  {

            regex.enumerateMatches(in: self, options: [], range: NSRange(0..<utf8.count)) {

                match, flags, stop in
                let byteString = (self as NSString).substring(with: match!.range)
                var num = UInt8(byteString, radix: 16)
                data.append(&num!, count: 1)
            }
        }
        return data
    }
    var bytesFromHex: [UInt8] {

        var bytes = [UInt8]()

        if let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) {

            regex.enumerateMatches(in: self, options: [], range: NSRange(0..<utf8.count)) { match, flags, stop in

                let hexString = (self as NSString).substring(with: match!.range)
                if let byte = UInt8(hexString, radix: 16) {

                    bytes.append(byte)
                }
            }
        }

        return bytes
    }

    var bytes: [UInt8] {
        return self.utf8.map { UInt8($0) }
    }
}
