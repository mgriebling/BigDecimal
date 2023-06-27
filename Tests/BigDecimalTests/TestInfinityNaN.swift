//
//  TestInfinityNaN.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 07/10/2022.
//

import XCTest
@testable import BigDecimal

final class TestInfinityNaN: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    struct test {

        let x: String
        let y: String
        let result: String

        init(_ x: String, _ y: String, _ result: String) {
            self.x = x
            self.y = y
            self.result = result
        }
    }

    let testsAdd: [test] = [
        test("-Infinity", "-Infinity", "-Infinity"),
        test("-Infinity", "-1000", "-Infinity"),
        test("-Infinity", "-1", "-Infinity"),
        test("-Infinity", "-0", "-Infinity"),
        test("-Infinity", "0", "-Infinity"),
        test("-Infinity", "1", "-Infinity"),
        test("-Infinity", "1000", "-Infinity"),
        test("-1000", "-Infinity", "-Infinity"),
        test("-Infinity", "-Infinity", "-Infinity"),
        test("-1", "-Infinity", "-Infinity"),
        test("-0", "-Infinity", "-Infinity"),
        test("0", "-Infinity", "-Infinity"),
        test("1", "-Infinity", "-Infinity"),
        test("1000", "-Infinity", "-Infinity"),
        test("+Infinity", "-Infinity", "NaN"),
        test("+Infinity", "-Infinity", "NaN"),
        test("+Infinity", "-1000", "+Infinity"),
        test("+Infinity", "-1", "+Infinity"),
        test("+Infinity", "0", "+Infinity"),
        test("+Infinity", "1", "+Infinity"),
        test("+Infinity", "1000", "+Infinity"),
        test("+Infinity", "1", "+Infinity"),
        test("+Infinity", "1000", "+Infinity"),
        test("-1000", "+Infinity", "+Infinity"),
        test("-Infinity", "+Infinity", "NaN"),
        test("-1", "+Infinity", "+Infinity"),
        test("-0", "+Infinity", "+Infinity"),
        test("0", "+Infinity", "+Infinity"),
        test("1", "+Infinity", "+Infinity"),
        test("1000", "+Infinity", "+Infinity"),
        test("+Infinity", "+Infinity", "+Infinity"),
    ]

    func testAdd() throws {
        for t in testsAdd {
            XCTAssertEqual((BigDecimal(t.x) + BigDecimal(t.y)).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }
    
    let testsSub: [test] = [
        test("-Infinity", "+Infinity", "-Infinity"),
        test("-Infinity", "1000", "-Infinity"),
        test("-Infinity", "1", "-Infinity"),
        test("-Infinity", "-0", "-Infinity"),
        test("-Infinity", "-1", "-Infinity"),
        test("-Infinity", "-1000", "-Infinity"),
        test("-1000", "+Infinity", "-Infinity"),
        test("-Infinity", "+Infinity", "-Infinity"),
        test("-1", "+Infinity", "-Infinity"),
        test("0", "+Infinity", "-Infinity"),
        test("1", "+Infinity", "-Infinity"),
        test("1000", "+Infinity", "-Infinity"),
        test("+Infinity", "+Infinity", "NaN"),
        test("+Infinity", "1000", "+Infinity"),
        test("+Infinity", "1", "+Infinity"),
        test("+Infinity", "0", "+Infinity"),
        test("+Infinity", "-0", "+Infinity"),
        test("+Infinity", "-1", "+Infinity"),
        test("+Infinity", "-1000", "+Infinity"),
        test("+Infinity", "-Infinity", "+Infinity"),
        test("-1000", "-Infinity", "+Infinity"),
        test("-Infinity", "-Infinity", "NaN"),
        test("-1", "-Infinity", "+Infinity"),
        test("-0", "-Infinity", "+Infinity"),
        test("0", "-Infinity", "+Infinity"),
        test("1", "-Infinity", "+Infinity"),
        test("1000", "-Infinity", "+Infinity"),
        test("+Infinity", "-Infinity", "+Infinity"),
    ]

    func testSub() throws {
        for t in testsSub {
            XCTAssertEqual((BigDecimal(t.x) - BigDecimal(t.y)).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    let testsMul: [test] = [
        test("+Infinity", "-Infinity", "-Infinity"),
        test("+Infinity", "-1000", "-Infinity"),
        test("+Infinity", "-1", "-Infinity"),
        test("+Infinity", "-0", "NaN"),
        test("+Infinity", "0", "NaN"),
        test("+Infinity", "1", "+Infinity"),
        test("+Infinity", "1000", "+Infinity"),
        test("+Infinity", "+Infinity", "+Infinity"),
        test("-1000", "+Infinity", "-Infinity"),
        test("-Infinity", "+Infinity", "-Infinity"),
        test("-1", "+Infinity", "-Infinity"),
        test("-0", "+Infinity", "NaN"),
        test("0", "+Infinity", "NaN"),
        test("1", "+Infinity", "+Infinity"),
        test("1000", "+Infinity", "+Infinity"),
        test("+Infinity", "+Infinity", "+Infinity"),
        test("-Infinity", "-Infinity", "+Infinity"),
        test("-Infinity", "-1000", "+Infinity"),
        test("-Infinity", "-1", "+Infinity"),
        test("-Infinity", "-0", "NaN"),
        test("-Infinity", "0", "NaN"),
        test("-Infinity", "1", "-Infinity"),
        test("-Infinity", "1000", "-Infinity"),
        test("-Infinity", "+Infinity", "-Infinity"),
        test("-1000", "+Infinity", "-Infinity"),
        test("-Infinity", "-Infinity", "+Infinity"),
        test("-1", "-Infinity", "+Infinity"),
        test("-0", "-Infinity", "NaN"),
        test("0", "-Infinity", "NaN"),
        test("1", "-Infinity", "-Infinity"),
        test("1000", "-Infinity", "-Infinity"),
        test("+Infinity", "-Infinity", "-Infinity"),
    ]
    
    func testMul() throws {
        for t in testsMul {
            XCTAssertEqual((BigDecimal(t.x) * BigDecimal(t.y)).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    let testsDiv: [test] = [
        test("0", "0", "NaN"),
        test("-1", "0", "-Infinity"),
        test("-1", "-0", "-Infinity"),
        test("1", "0", "+Infinity"),
        test("1", "-0", "+Infinity"),
        test("+Infinity", "-Infinity", "NaN"),
        test("+Infinity", "-1000", "-Infinity"),
        test("+Infinity", "-1", "-Infinity"),
        test("+Infinity", "-0", "+Infinity"),
        test("+Infinity", "0", "+Infinity"),
        test("+Infinity", "1", "+Infinity"),
        test("+Infinity", "1000", "+Infinity"),
        test("+Infinity", "+Infinity", "NaN"),
        test("-1000", "+Infinity", "0"),
        test("-Infinity", "+Infinity", "NaN"),
        test("-1", "+Infinity", "0"),
        test("-0", "+Infinity", "0"),
        test("0", "+Infinity", "0"),
        test("1", "+Infinity", "0"),
        test("1000", "+Infinity", "0"),
        test("+Infinity", "+Infinity", "NaN"),
        test("-Infinity", "-Infinity", "NaN"),
        test("-Infinity", "-1000", "+Infinity"),
        test("-Infinity", "-1", "+Infinity"),
        test("-Infinity", "-0", "-Infinity"),
        test("-Infinity", "0", "-Infinity"),
        test("-Infinity", "1", "-Infinity"),
        test("-Infinity", "1000", "-Infinity"),
        test("-Infinity", "+Infinity", "NaN"),
        test("-1000", "+Infinity", "0"),
        test("-Infinity", "-Infinity", "NaN"),
        test("-1", "-Infinity", "0"),
        test("-0", "-Infinity", "0"),
        test("0", "-Infinity", "0"),
        test("1", "-Infinity", "0"),
        test("1000", "-Infinity", "0"),
        test("+Infinity", "-Infinity", "NaN"),
    ]

    func testDiv() throws {
        for t in testsDiv {
            XCTAssertEqual((BigDecimal(t.x) / BigDecimal(t.y)).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    let testsRem: [test] = [
        test("0", "0", "NaN"),
        test("-1", "0", "NaN"),
        test("-1", "-0", "NaN"),
        test("1", "0", "NaN"),
        test("1", "-0", "NaN"),
        test("+Infinity", "-Infinity", "NaN"),
        test("+Infinity", "-1000", "NaN"),
        test("+Infinity", "-1", "NaN"),
        test("+Infinity", "0", "NaN"),
        test("+Infinity", "-0", "NaN"),
        test("+Infinity", "1", "NaN"),
        test("+Infinity", "1000", "NaN"),
        test("+Infinity", "+Infinity", "NaN"),
        test("-1000", "+Infinity", "-1000"),
        test("-Infinity", "+Infinity", "NaN"),
        test("-1", "+Infinity", "-1"),
        test("0", "+Infinity", "0"),
        test("-0", "+Infinity", "0"),
        test("1", "+Infinity", "1"),
        test("1000", "+Infinity", "1000"),
        test("+Infinity", "+Infinity", "NaN"),
        test("-Infinity", "-Infinity", "NaN"),
        test("-Infinity", "-1000", "NaN"),
        test("-Infinity", "-1", "NaN"),
        test("-Infinity", "-0", "NaN"),
        test("-Infinity", "0", "NaN"),
        test("-Infinity", "1", "NaN"),
        test("-Infinity", "1000", "NaN"),
        test("-Infinity", "+Infinity", "NaN"),
        test("-Infinity", "-Infinity", "NaN"),
        test("-1000", "+Infinity", "-1000"),
        test("-1", "-Infinity", "-1"),
        test("-0", "-Infinity", "0"),
        test("0", "-Infinity", "0"),
        test("1", "-Infinity", "1"),
        test("1000", "-Infinity", "1000"),
        test("+Infinity", "-Infinity", "NaN"),
    ]

    func testRem() throws {
        for t in testsRem {
            XCTAssertEqual((BigDecimal(t.x) % BigDecimal(t.y)).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    let testsPow: [test] = [
        test("0", "0", "1"),
        test("0", "-3", "+Infinity"),
        test("0", "-4", "+Infinity"),
        test("0", "3", "0"),
        test("0", "4", "0"),
        test("+Infinity", "-1000", "0"),
        test("+Infinity", "-1", "0"),
        test("+Infinity", "-0", "1"),
        test("+Infinity", "0", "1"),
        test("+Infinity", "1", "+Infinity"),
        test("+Infinity", "1000", "+Infinity"),
        test("-Infinity", "-1000", "0"),
        test("-Infinity", "-1", "0"),
        test("-Infinity", "-0", "1"),
        test("-Infinity", "0", "1"),
        test("-Infinity", "1", "-Infinity"),
        test("-Infinity", "1000", "+Infinity"),
    ]

    func testPow() throws {
        for t in testsPow {
            XCTAssertEqual((BigDecimal(t.x).pow(Int(t.y)!)).asString(), t.result)
        }
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    let testsCompare: [test] = [
        test("+Infinity", "-Infinity", "1"),
        test("+Infinity", "-1000", "1"),
        test("+Infinity", "-1", "1"),
        test("+Infinity", "-0", "1"),
        test("+Infinity", "0", "1"),
        test("+Infinity", "1", "1"),
        test("+Infinity", "1000", "1"),
        test("+Infinity", "+Infinity", "0"),
        test("-1000", "+Infinity", "-1"),
        test("-Infinity", "+Infinity", "-1"),
        test("-1", "+Infinity", "-1"),
        test("-0", "+Infinity", "-1"),
        test("0", "+Infinity", "-1"),
        test("1", "+Infinity", "-1"),
        test("1000", "+Infinity", "-1"),
        test("+Infinity", "+Infinity", "0"),
    ]

    func testCompare() throws {
        for t in testsCompare {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), Int(t.result)!)
        }
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testNaN() throws {
        XCTAssertFalse(BigDecimal.nan < BigDecimal(1))
        XCTAssertFalse(BigDecimal.nan <= BigDecimal(1))
        XCTAssertFalse(BigDecimal.nan > BigDecimal(1))
        XCTAssertFalse(BigDecimal.nan >= BigDecimal(1))
        XCTAssertFalse(BigDecimal.nan == BigDecimal(1))
        XCTAssertTrue(BigDecimal.nan != BigDecimal(1))
        XCTAssertTrue(BigDecimal.nan != BigDecimal.nan)
        XCTAssertFalse(BigDecimal.NaNFlag)
        XCTAssertTrue(BigDecimal(BigDecimal.nan.asString()).isNaN)
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    func testRound() throws {
        XCTAssertEqual(Rounding.decimal32.round(BigDecimal.infinity), BigDecimal.infinity)
        XCTAssertEqual(Rounding.decimal32.round(-BigDecimal.infinity), -BigDecimal.infinity)
        XCTAssertTrue(Rounding.decimal32.round(BigDecimal.nan).isNaN)
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    let testsQuantize: [test] = [
        test("+Infinity", "-Infinity", "+Infinity"),
        test("+Infinity", "1E-299", "NaN"),
        test("+Infinity", "1E-1", "NaN"),
        test("+Infinity", "1E0", "NaN"),
        test("+Infinity", "1E1", "NaN"),
        test("+Infinity", "1E299", "NaN"),
        test("+Infinity", "+Infinity", "+Infinity"),
        test("-1000", "+Infinity", "NaN"),
        test("-Infinity", "+Infinity", "-Infinity"),
        test("-1", "+Infinity", "NaN"),
        test("0", "+Infinity", "NaN"),
        test("1", "+Infinity", "NaN"),
        test("1000", "+Infinity", "NaN"),
        test("+Infinity", "+Infinity", "+Infinity"),
        test("+Infinity", "1E-0", "NaN"),
        test("-0", "+Infinity", "NaN"),
        test("-Infinity", "-Infinity", "-Infinity"),
        test("-Infinity", "1E-299", "NaN"),
        test("-Infinity", "1E-1", "NaN"),
        test("-Infinity", "1E0", "NaN"),
        test("-Infinity", "1E1", "NaN"),
        test("-Infinity", "1E299", "NaN"),
        test("-Infinity", "+Infinity", "-Infinity"),
        test("-1000", "+Infinity", "NaN"),
        test("-Infinity", "-Infinity", "-Infinity"),
        test("-1", "-Infinity", "NaN"),
        test("0", "-Infinity", "NaN"),
        test("1", "-Infinity", "NaN"),
        test("1000", "-Infinity", "NaN"),
        test("+Infinity", "-Infinity", "+Infinity"),
        test("-Infinity", "1E-0", "NaN"),
        test("-0", "-Infinity", "NaN"),
    ]

    func testQuantize() throws {
        for t in testsQuantize {
            XCTAssertEqual(BigDecimal(t.x).quantize(BigDecimal(t.y), Mode.toNearestOrEven).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }
}
