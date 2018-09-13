//
//  vendorTests.swift
//  NetworkNinja
//
//  Created by Jelle Alten on 28-05-17.
//  Copyright © 2017 Alt-N. All rights reserved.
//

import XCTest

class VendorTests: XCTestCase {

    func testReadNewOuiTxt() {

        if let path = Bundle.fixturePath(fromFile: "oui", withExtension: "txt") {

            OUIParser.parseOUI(withSourceFilePath: path.absoluteString, andOutputFilePath: nil)
        } else {

            XCTFail("cannot load oui.txt")
        }
    }

}
