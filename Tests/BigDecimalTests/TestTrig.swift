//
//  TestTrig.swift
//  BigDecimal
//
//  Created by Mike Griebling on 11.10.2024.
//

import XCTest
@testable import BigDecimal

final class TestTrig: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTrig() throws {
        let pi2 = BigDecimal.pi / 2
        XCTAssertEqual(BigDecimal.sin(pi2).asString(), "0.8414709848078965066525023216302990")
        XCTAssertEqual(BigDecimal.cos(pi2).asString(), "0.5403023058681397174009366074429766")
        XCTAssertEqual(BigDecimal.tan(pi2).asString(), "1.557407724654902230506974807458360")
        XCTAssertEqual(BigDecimal.asin(BigDecimal.sin(pi2)).asString(), "1.000000000000000000000000000000000")
        XCTAssertEqual(BigDecimal.acos(BigDecimal.cos(pi2)).asString(), "1.000000000000000000000000000000000")
        XCTAssertEqual(BigDecimal.atan(BigDecimal.tan(pi2)).asString(), "0.9999999999999999999999999999999999")
        XCTAssertEqual(BigDecimal.atan2(y: .one, x: .ten).asString(), "0.09966865249116202737844611987802059")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
