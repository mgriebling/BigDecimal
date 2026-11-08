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

    /// Based on test4
    func test5() throws {
        var big: BigDecimal = "345.23499600293850"
        XCTAssertEqual(big, BigDecimal("345.23499600293850"))
        XCTAssertEqual(big.asString(), "345.23499600293850")
        XCTAssertEqual(big.exponent, -14)
        big = "-12345"
        XCTAssertEqual(big, BigDecimal("-12345"))
        XCTAssertEqual(big.asString(), "-12345")
        XCTAssertEqual(big.exponent, 0)
        big = "123."
        XCTAssertEqual(big, BigDecimal("123"))
        XCTAssertEqual(big.asString(), "123")
        XCTAssertEqual(big.exponent, 0)
        _ = "1.234E02"
        let notNaN: BigDecimal = "1.234E02"
        let candidateNaN1: BigDecimal = ""
        let candidateNaN2: BigDecimal = "+35e+-2"
        let candidateNaN3: BigDecimal = "-35e-+2"

        XCTAssertFalse(notNaN.isNaN)
        XCTAssertTrue(candidateNaN1.isNaN)
        XCTAssertTrue(candidateNaN2.isNaN)
        XCTAssertTrue(candidateNaN3.isNaN)
        XCTAssertTrue(BigDecimal.nanFlag)
    }
func test6() throws {
  let values: [BigDecimal] = [
    "123",
    "123.0",
    "123.00",
    "123.000",
    "123.0000",
    "123.00000",
    "123.000000",
    "123.0000000",
    "123.00000000",
    "123.000000000",
    BigDecimal(123).divide(100000, .decimal128).multiply(100000, .decimal128),
    BigDecimal(123).multiply(100000, .decimal128).divide(100000, .decimal128)
  ]

  values.forEach {
    XCTAssertEqual(BigDecimal(normalize: $0), $0)
    XCTAssertEqual(BigDecimal(normalize: $0), 123)
    XCTAssertEqual(BigDecimal(normalize: $0).asString(), "123")
  }
}


}
