//
//  TestConstructor.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 28/04/2021.
//

import XCTest
@testable import BigDecimal
import BigInt

class TestConstructor: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    let value = BInt(12345908)
    let value2 = BInt(12334560000)

    func test1() {
        let big = BigDecimal(value)
        XCTAssertEqual(big.digits, value)
        XCTAssertEqual(big.exponent, 0)
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    func test2() {
        let big = BigDecimal(value2, -5)
        XCTAssertEqual(big.digits, value2)
        XCTAssertEqual(big.exponent, -5)
        XCTAssertEqual(big.asString(), "123345.60000")
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    func test3() throws {
        var big = BigDecimal(123E04)
        XCTAssertEqual(big.asString(), "1230000")
        big = BigDecimal(1.2345E-12)
        XCTAssertEqual(big.asDouble(), 1.2345E-12)
        big = BigDecimal(-12345E-3)
        XCTAssertEqual(big.asDouble(), -12.345)
        big = BigDecimal(5.1234567897654321e138)
        XCTAssertEqual(big.asDouble(), 5.1234567897654321E138)
        XCTAssertEqual(big.exponent, 0)
        big = BigDecimal(0.1)
        XCTAssertEqual(big.asDouble(), 0.1)
        big = BigDecimal(0.00345)
        XCTAssertEqual(big.asDouble(), 0.00345)
        big = BigDecimal(-0.0)
        XCTAssertEqual(big.exponent, 0)
        XCTAssertFalse(BigDecimal.nanFlag)
    }
    
    func test4() throws {
        var big = BigDecimal("345.23499600293850")
        XCTAssertEqual(big.asString(), "345.23499600293850")
        XCTAssertEqual(big.exponent, -14)
        big = BigDecimal("-12345")
        XCTAssertEqual(big.asString(), "-12345")
        XCTAssertEqual(big.exponent, 0)
        big = BigDecimal("123.")
        XCTAssertEqual(big.asString(), "123")
        XCTAssertEqual(big.exponent, 0)
        _ = BigDecimal("1.234E02")
        XCTAssertFalse(BigDecimal("1.234E02").isNaN)
        XCTAssertTrue(BigDecimal("").isNaN)
        XCTAssertTrue(BigDecimal("+35e+-2").isNaN)
        XCTAssertTrue(BigDecimal("-35e-+2").isNaN)
        XCTAssertTrue(BigDecimal.nanFlag)
    }

}
