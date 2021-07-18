//
//  URLBuilderTests.swift
//  
//
//  Created by Ariel Rodriguez on 17/07/2021.
//

@testable import VolonbolonKit
import XCTest

final class URLBuilderTests: XCTestCase {
    var builder: URLBuilder!
    
    override func setUp() {
        builder = URLBuilder()
    }
    
    func testCanBuildSchemeAndPath() {
        let url = builder.set(scheme: "https")
            .set(path: "path")
            .set(host: "localhost")
            .set(port: 80)
            .addQueryItem(name: "first_query", value: "first query value")
            .addQueryItem(name: "second_query", value: "72")
            .build()
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "https")
        XCTAssertEqual(url?.host, "localhost")
        XCTAssertEqual(url?.path, "/path")
        XCTAssertEqual(url?.port, 80)
        guard let query = url?.query else {
            XCTFail("Unable to retrieve the Query")
            return
        }
        XCTAssertTrue(query.contains("first_query=first%20query%20value"), "\(query), should containts 'first_query=first%20query%20value'")
        XCTAssertTrue(query.contains("second_query=72"), "\(query), should containts 'second_query=72'")
    }
    
    static var allTests = [
        ("testCanBuildSchemeAndPath", testCanBuildSchemeAndPath),
    ]
}
