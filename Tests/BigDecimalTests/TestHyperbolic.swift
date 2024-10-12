//
//  TestHyperbolic.swift
//  BigDecimal
//
//  Created by Mike Griebling on 11.10.2024.
//

import XCTest
@testable import BigDecimal

final class TestHyperbolic: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        XCTAssertEqual(BigDecimal.sinh(.one).asString(), "1.175201193643801456882381850595601")
        XCTAssertEqual(BigDecimal.cosh(.one).asString(), "1.543080634815243778477905620757062")
        XCTAssertEqual(BigDecimal.tanh(.one).asString(), "0.7615941559557648881194582826047937")
        XCTAssertEqual(BigDecimal.asinh(BigDecimal.sinh(.one)).asString(), "1.000000000000000000000000000000000")
        XCTAssertEqual(BigDecimal.acosh(BigDecimal.cosh(.one)).asString(), "1.000000000000000000000000000000000")
        XCTAssertEqual(BigDecimal.atanh(BigDecimal.tanh(.one)).asString(), "1.000000000000000000000000000000000")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
