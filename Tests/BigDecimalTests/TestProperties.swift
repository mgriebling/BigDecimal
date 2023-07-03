//
//  TestProperties.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 27/04/2021.
//

import XCTest
@testable import BigDecimal

class TestProperties: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    func doTest1(_ x: BigDecimal) {
        if x.isNegative {
            XCTAssertEqual(x.abs, x * (-BigDecimal.one))
            XCTAssertEqual(x.signum, -1)
        } else if x.isPositive {
            XCTAssertEqual(x.abs, x)
            XCTAssertEqual(x.signum, 1)
        } else {
            XCTAssertEqual(x.abs, BigDecimal.zero)
            XCTAssertEqual(x.signum, 0)
        }
        XCTAssertEqual(x.trim, x)
    }

    func test1() throws {
        doTest1(BigDecimal("1.2e4"))
        doTest1(BigDecimal("-1.2e4"))
        doTest1(BigDecimal("1.2e-4"))
        doTest1(BigDecimal("-1.2e-4"))
    }

}
