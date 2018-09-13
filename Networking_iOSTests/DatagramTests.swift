//
//  DatagramTests.swift
//  snmptest
//
//  Created by Jelle Alten on 25-09-16.
//  Copyright © 2016 Alt-N. All rights reserved.
//

import XCTest
@testable import Snmp

// swiftlint:disable type_body_length
// swiftlint:disable line_length

class DatagramTests: XCTestCase {

    override func tearDown() {

        SnmpDatagram.report()
    }

    func testSomeDatagram() {

        if let data = "308200de02010104067075626c6963a28200cf020100020100020100308200c23082001a06082b06010201010500040e414c542d4e5f5669676f725f30313082000c06082b0601020101060004003082000d06082b0601020101070002014e3082000d06082b0601020102010002010a3082000f060a2b0601020102020101010201013082000f060a2b0601020102020101040201043082000f060a2b0601020102020101050201053082000f060a2b0601020102020101060201063082000f060a2b0601020102020101070201073082000f060a2b060102010202010108020108".dataFromHex,
            let packet = try? SnmpDatagram(data: data) {

            XCTAssertEqual(packet.pdu, .Response)
            XCTAssertEqual(packet.version, .v2c)

            XCTAssertEqual(packet.requestId, 0)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.2.1.1.5.0")

        } else {

            XCTFail("error reading datagram ")
        }
    }

    func testDatagramSingleOid() {

        if let data = "3082002702010004067075626c6963a21a020400000797020102020101300c300a06062b06010201010500".dataFromHex,
            let packet = try? SnmpDatagram(data: data) {

            XCTAssertEqual(packet.pdu, .Response)
            XCTAssertEqual(packet.version, .v1)

            XCTAssertEqual(packet.requestId, 1943)
            XCTAssertEqual(packet.errorStatus, .noSuchName)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.2.1.1")
        }

    }

    func testSomeDatagram_funnyOctetString() {

        if let data = "3081f002010104067075626c6963a281e20201010201000201003081d6300e060a2b06010201020201060104003014060a2b06010201020201060204065893963e96e33014060a2b06010201020201060304065893963e96e43014060a2b06010201020201060404065893963e96e53014060a2b06010201020201060504065893963e96e63014060a2b06010201020201060604065893963e96e73014060a2b06010201020201060704065893963e96e83014060a2b06010201020201060904065893963e96e03014060a2b06010201020201060a04065893963e96e13014060a2b06010201020201060b04065893963e96e1".dataFromHex,
            let packet = try? SnmpDatagram(data: data) {

            XCTAssertEqual(packet.pdu, .Response)
            XCTAssertEqual(packet.version, .v2c)

            XCTAssertEqual(packet.requestId, 1)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.2.1.2.2.1.6.1")

        } else {

            XCTFail("error reading datagram ")
        }
    }

    func testSomeDatagram_systemName() {

        if let data = "3082014b02010104067075626c6963a282013c020200bc0201000201003082012e302206082b0601020101010004165275636b757320576972656c657373205a4431313036301806082b06010201010200060c2b0601040181c35d03010502301006082b0601020101030043043b69542c303906082b06010201010400042d68747470733a2f2f737570706f72742e7275636b7573776972656c6573732e636f6d2f636f6e746163745f7573301506082b0601020101050004095a44313130302d3031303306082b0601020101060004273838302057204d61756465204176652e2053756e6e7976616c652c204341203934303835205553300d06082b060102010108004301743014060a2b06010201010901020106062b06010603013017060a2b06010201010901020206092b06010603100202013017060a2b06010201010901020306092b060106030a030101".dataFromHex,
            let packet = try? SnmpDatagram(data: data) {

            XCTAssertEqual(packet.pdu, .Response)
            XCTAssertEqual(packet.version, .v2c)

            XCTAssertEqual(packet.requestId, 188)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.2.1.1.1.0")

        } else {

            XCTFail("error reading datagram ")
        }
    }

    func testCreateDatagram() {

        guard let expectedPacket = loadDatagram(name: "TestPacket") else {

            XCTAssertTrue(false, "no packet named TestPacket.bin")
            return
        }
        let packet = SnmpDatagram(pdu:.GetNext,
                                  id:851748807,
                                  community: "public",
                                  oid: "1.3.6.1.4.1.25053.1.2.2.4.1.1.1.1.16")
        let data = packet.data()
        XCTAssertEqual(data, expectedPacket)

        checkNotEqual(wrongpacket1: SnmpDatagram(pdu:.Get,
                                                 id:851748807,
                                                 community: "public",
                                                 oid: "1.3.6.1.4.1.25053.1.2.2.4.1.1.1.1.16"),
                      expectedpacket: expectedPacket,
                      description: "pdu command Get")

        checkNotEqual(wrongpacket1: SnmpDatagram(pdu:.GetNext,
                                                 id:851748806,
                                                 community: "public",
                                                 oid: "1.3.6.1.4.1.25053.1.2.2.4.1.1.1.1.16"),
                      expectedpacket: expectedPacket,
                      description: "requestId 851748806")

        checkNotEqual(wrongpacket1: SnmpDatagram(pdu:.GetNext,
                                                 id:851748807,
                                                 community: "publik",
                                                 oid: "1.3.6.1.4.1.25053.1.2.2.4.1.1.1.1.16"),
                      expectedpacket: expectedPacket,
                      description: "publik")

        checkNotEqual(wrongpacket1: SnmpDatagram(pdu:.GetNext,
                                                 id:851748807,
                                                 community: "public",
                                                 oid: "1.3.6.0.4.1.25053.1.2.2.4.1.1.1.1.16"),
                      expectedpacket: expectedPacket,
                      description: "requestId -")
    }

    func testCreateDatagram_bulk() {

        guard let expectedBulkPacket = loadDatagram(name: "TestPacketBulk") else {

            XCTAssertTrue(false, "no packet named TestPacketBulk.bin")
            return
        }
        let bulkReq = SnmpDatagram(pdu:.GetBulk,
                                  id:1209053816,
                                  community: "public",
                                  oid: "1.3.6.1.2.1.17.7.1.2.2.1.2",
                                  version: .v2c)
        XCTAssertEqual(bulkReq.data(), expectedBulkPacket, "data difference \(bulkReq.data()?.hexDescription ?? "")")

    }

    func testCreateDatagram_bulk2() {

        let filename = "snmp_getBulk2"

        guard let expectedBulkPacket = loadDatagram(name: filename) else {

            XCTAssertTrue(false, "no packet named \(filename).bin")
            return
        }

        if let packet = try? SnmpDatagram(data:expectedBulkPacket) {

            XCTAssertEqual(packet.pdu, .GetBulk)
            XCTAssertEqual(packet.requestId, 63314653)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.2.1.17.7.1.2.2.1.2.1.140.12.144.63.172.178")
        } else {

            XCTFail("error reading datagram \(expectedBulkPacket.hexDescription)")
        }

        let bulkReq = SnmpDatagram(pdu: .GetBulk, id: 63314653, community: "public",
                                   oid: "1.3.6.1.2.1.17.7.1.2.2.1.2.1.140.12.144.63.172.178", version: .v2c)
        XCTAssertEqual(bulkReq.data(), expectedBulkPacket)

    }

    func checkNotEqual(wrongpacket1: SnmpDatagram, expectedpacket: Data, description: String) {

//        print("checking \(wrongpacket1.data()!.hexDescription)")
        XCTAssertNotEqual(wrongpacket1.data(), expectedpacket, "\(description): \(wrongpacket1.data()!.hexDescription)")
    }

    func testReadDatagram() {

        guard let datagram = loadDatagram(name: "TestPacket") else {

            XCTAssertTrue(false, "no packet named TestPacket.bin")
            return
        }
        print ("loaded TestPacket.bin")
        if let packet = try? SnmpDatagram(data:datagram) {

            XCTAssertEqual(packet.pdu, .GetNext)
            XCTAssertEqual(packet.requestId, 851748807)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.4.1.25053.1.2.2.4.1.1.1.1.16")
        } else {

            XCTFail("error reading datagram \(datagram.hexDescription)")
        }
    }

    func testReadDatagram_Bulk() {

        guard let datagram = loadDatagram(name: "TestPacketBulk") else {

            XCTAssertTrue(false, "no packet named TestPacketBulk.bin")
            return
        }
        print ("loaded TestPacketBulk.bin")
        if let packet = try? SnmpDatagram(data:datagram) {

            XCTAssertEqual(packet.pdu, .GetBulk)
            XCTAssertEqual(packet.requestId, 1209053816)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "1.3.6.1.2.1.17.7.1.2.2.1.2")
            XCTAssertEqual(packet.nonRepeaters, 0)
            XCTAssertEqual(packet.maxRepetitions, 10)
        } else {

            XCTFail("error reading datagram \(datagram.hexDescription)")
        }
    }

    func testReadDatagram_EOF() {

        let sampleFile = "snmp_EOF"
        guard let datagram = loadDatagram(name: sampleFile) else {

            XCTAssertTrue(false, "no packet named \(sampleFile).bin")
            return
        }
        print ("loaded \(sampleFile).bin")
        if let packet = try? SnmpDatagram(data:datagram) {

            XCTAssertEqual(packet.pdu, .Response)
            XCTAssertEqual(packet.requestId, 322960590)
            XCTAssertEqual(packet.community, "public")
            XCTAssertEqual(packet.firstOid, "2.2.1.2.1.172.207.35.17.22.181")
            XCTAssertEqual(packet.errorStatus, .none)
            XCTAssertEqual(packet.errorIndex, 0)
            XCTAssertEqual(packet.firstValue!, SnmpValue.noSuchObject)
        } else {

            XCTFail("error reading datagram \(datagram.hexDescription)")
        }
    }

    func testReadDatagrams_fromFixtures() {

        let names = ["snmp_resp_multi2", "snmp_getmulti2", "TestPacket", "req-final", "req1", "req2", "res-final", "res1", "res2", "snmp_get_uptime", "snmp_getmulti", "snmp_name", "snmp_get_uptime2", "snmp_getmulti1", "snmp_resp_err", "snmp_uptime1", "snmp_getinvalid", "snmp_getname", "snmp_resp_multi1", "snmp_resp_uptime"]
        for name in names {

            print("reading \(name)")
//            print("parsing \(datagram?.hexDescription)")
            if let datagram = loadDatagram(name: name),
                let packet = try? SnmpDatagram(data:datagram) {

                packet.dump()
            } else {

                XCTAssertTrue(false, "no packet named \(name).bin")
                return
            }

        }
    }

    func testGetOids() {

        let hex = "3082014002010104067075626c6963a282013102010002010002010030820124301a06152b0601020111070102020102010011810532478100020100301b06162b0601020111070102020102010016814b812b308174020118301b06162b060102011107010202010201001d812a813460816802012f301b06162b0601020111070102020102010040810c8174816d1502011e301c06172b0601020111070102020102010081108129813b815b62020126301b06162b0601020111070102020102016081781d813179817202012f301c06172b060102011107010202010201810c0c81103f812c813202012f301d06182b06010201110701020201020181208119811b81561f811802012f301a06152b0601020111070102020103010011810532478100020104301b06162b0601020111070102020103010016814b812b308174020103"
        if let datagram = hex.dataFromHex, let packet = try? SnmpDatagram(data:datagram) {

            let oids = packet.oidValues(for: "1.3.6.1.2.1.17.7.1.2.2.1.2.1")
            XCTAssertEqual(oids.count, 8)
        } else {

            XCTFail("can't load hex datagram")
        }
    }

    func testhex() {

        let hex = ""
        if let datagram = hex.dataFromHex,
            let packet = try? SnmpDatagram(data:datagram) {

            packet.dump()
        } else {

            XCTFail("cant load datagram")
        }
    }

    func skip_testDatagramsFromHexFiles_includesInvalid_shouldNotCrash() {

        var errorDatagrams = [Data]()
        var packetCount = 0
        let filenames = ["snmp_v3", "req_app", "usm", "req_enc", "trap_enc", "trap_app"]
        for filename in filenames {

            print("reading file \(filename)")
            var fileErrors = 0
            if let datas = TestsHelper.loadDatagramsFromHexStringsInFile(name: filename) {

                for datagram in datas {

                    packetCount += 1
//                    print("parsing \(datagram.hexDescription)")
                    if let packet = try? SnmpDatagram(data:datagram) {

                        packet.dump()
                    } else {

                        print("could not parse \(datagram.hexDescription)")
                        errorDatagrams.append(datagram)
                        fileErrors += 1
                    }

                }
            }
            print("errors in file \(filename): \(fileErrors)")
        }
        print("coudn't parse \(errorDatagrams.count) out of \(packetCount) packet(s)")

        XCTAssertEqual(errorDatagrams.count, 28349)

    }

    func skip_testDatagramsFromHexFiles_expectAllGood() {

        var errorDatagrams = [Data]()
        let filenames = ["intermapper_snmp-2", "intermapper_snmp", "requests", "usm", "snmp_packets"]
        for filename in filenames {

            print("reading file \(filename)")
            if let datas = TestsHelper.loadDatagramsFromHexStringsInFile(name: filename) {

                for datagram in datas {

//                    print("parsing \(datagram.hexDescription)")
                    if let packet = try? SnmpDatagram(data:datagram) {

                        packet.dump()
                    } else {

                        print("could not parse \(datagram.hexDescription)")
                        errorDatagrams.append(datagram)
                    }

                }
            }
        }
        XCTAssertEqual(errorDatagrams.count, 0, "cant parse \(errorDatagrams.count) packet(s)")

    }

    func loadDatagram(name: String) -> Data? {

        return loadFixtureData(fromFile: "\(name).bin")

    }

    func testSnmpObjectIdentifier_asString() {

        let rawString = "1.2.3.4.5"
        let oid = SnmpObjectIdentifier(string: rawString)
        print(oid)
        let str: String = oid.description
        XCTAssertEqual(str, rawString)
//        let s = String(oid)
    }

}

