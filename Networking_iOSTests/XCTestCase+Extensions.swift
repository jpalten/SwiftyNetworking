//
//  XCTestCase+Extensions.swift
//  Vettel
//
//  Created by Jelle Alten on 30-03-17.
//
//

import XCTest

extension XCTestCase {

    func waitForExpectations() {

        waitForExpectations(timeout: 20) { (error) in

            XCTAssertNil(error, "expected no timeout error, found \(String(describing: error))")
        }
    }

    func loadJsonDict(fromFixture resourceName: String) -> [String:Any]? {

        let filename = "\(resourceName).json"

        guard let jsonData = loadFixtureData(fromFile: filename),
            let dict = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [String:Any]  else {

                XCTFail("could not convert json data to dict from \(filename)")
                return nil
        }

        return dict
    }

    func loadFixtureData(fromFile filename: String) -> Data? {

        return loadFixtureData(fromFile: filename, withExtension: nil)
    }

    func loadFixtureData(fromFile filename: String, withExtension ext: String?) -> Data? {

        guard let fixturePath = Bundle.fixturePath(fromFile: filename, withExtension: ext) else {

            return nil
        }

        guard let fileData = try? Data(contentsOf:fixturePath) else {

            XCTFail("no test read data from bundle \(filename)")
            return nil
        }

        return fileData
    }

}

class SomeClassInTheTestBundle {

}

extension Bundle {

    static func fixturesBundle() -> Bundle? {

        let bundle = Bundle(for: SomeClassInTheTestBundle.self)

        let bundleUrl = bundle.url(forResource: "Fixtures", withExtension: "bundle")
        if let bundleUrl = bundleUrl, let fixturesBundle = Bundle(url: bundleUrl) {

            return fixturesBundle
        } else {

            return nil
        }
    }

    static func fixturePath(fromFile filename: String, withExtension ext: String?) -> URL? {

        guard let testBundle = fixturesBundle() else {

            XCTFail("can't load test fixtures bundle")
            return nil
        }

        guard let fixturePath = testBundle.url(forResource: filename, withExtension: ext) else {

            XCTFail("could not determine url for resource \(filename)")
            return nil
        }
        return fixturePath
    }

}
