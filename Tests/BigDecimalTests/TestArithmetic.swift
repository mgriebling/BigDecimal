//
//  TestArithmetic.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 06/05/2021.
//

import XCTest

class TestArithmetic: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func doTest1(_ a: BigDecimal, _ b: BigDecimal) {
        XCTAssertEqual(a + b, b + a)
        XCTAssertEqual(a + BigDecimal.ZERO, a)
        XCTAssertEqual(BigDecimal.ZERO + b, b)
        XCTAssertEqual(a + a, a * BigDecimal(2))
        XCTAssertEqual(a + b, a - (-b))
    }

    func test1() throws {
        doTest1(BigDecimal.ONE, BigDecimal.TEN)
        doTest1(BigDecimal("1234.5678"), BigDecimal(23, 5))
    }

    func test2() throws {
        XCTAssertEqual((BigDecimal("12.345") * BigDecimal.ONE).asString(), "12.345")
        XCTAssertEqual((BigDecimal("12.345") * BigDecimal.ZERO).asString(), "0.000")
        XCTAssertEqual((BigDecimal("-12.345") * BigDecimal.ONE).asString(), "-12.345")
        XCTAssertEqual((BigDecimal("-12.345") * BigDecimal.ZERO).asString(), "0.000")
    }
}
