//
//  TestDecimal64.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 02/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal
import BigInt

class TestDecimal64: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct test {

        let input: String
        let result: String
        let mode: RoundingRule

        init(_ input: String, _ result: String, _ mode: RoundingRule = .toNearestOrEven) {
            self.input = input
            self.result = result
            self.mode = mode
        }
    }

    let tests1: [test] = [
        test("1.1111111111123450", "1.111111111112345", .awayFromZero),
        test("1.11111111111234549", "1.111111111112346", .awayFromZero),
        test("1.11111111111234550", "1.111111111112346", .awayFromZero),
        test("1.11111111111234551", "1.111111111112346", .awayFromZero),
        test("1.1111111111123450", "1.111111111112345", .up),
        test("1.11111111111234549", "1.111111111112346", .up),
        test("1.11111111111234550", "1.111111111112346", .up),
        test("1.11111111111234551", "1.111111111112346", .up),
        test("1.1111111111123450", "1.111111111112345", .towardZero),
        test("1.11111111111234549", "1.111111111112345", .towardZero),
        test("1.11111111111234550", "1.111111111112345", .towardZero),
        test("1.11111111111234551", "1.111111111112345", .towardZero),
        test("1.1111111111123450", "1.111111111112345", .down),
        test("1.11111111111234549", "1.111111111112345", .down),
        test("1.11111111111234550", "1.111111111112345", .down),
        test("1.11111111111234551", "1.111111111112345", .down),
        test("1.1111111111123450", "1.111111111112345", .toNearestOrEven),
        test("1.11111111111234549", "1.111111111112345", .toNearestOrEven),
        test("1.11111111111234550", "1.111111111112346", .toNearestOrEven),
        test("1.11111111111234650", "1.111111111112346", .toNearestOrEven),
        test("1.11111111111234551", "1.111111111112346", .toNearestOrEven),
        test("1.1111111111123450", "1.111111111112345", .toNearestOrAwayFromZero),
        test("1.11111111111234549", "1.111111111112345", .toNearestOrAwayFromZero),
        test("1.11111111111234550", "1.111111111112346", .toNearestOrAwayFromZero),
        test("1.11111111111234650", "1.111111111112347", .toNearestOrAwayFromZero),
        test("1.11111111111234551", "1.111111111112346", .toNearestOrAwayFromZero),
        test("0.000000000", "0E-9"),
        test("0.00000000", "0E-8"),
        test("0.0000000", "0E-7"),
        test("0.000000", "0.000000"),
        test("0.00000", "0.00000"),
        test("0.0000", "0.0000"),
        test("0.000", "0.000"),
        test("0.00", "0.00"),
        test("0.0", "0.0"),
        test(".0", "0.0"),
        test("0.", "0"),
        test("100", "100", .toNearestOrAwayFromZero),
        test("1000", "1000", .toNearestOrAwayFromZero),
        test("10000", "10000", .toNearestOrAwayFromZero),
        test("100000", "100000", .toNearestOrAwayFromZero),
        test("999.9", "999.9", .toNearestOrAwayFromZero),
        test("1000.0", "1000.0", .toNearestOrAwayFromZero),
        test("1000.1", "1000.1", .toNearestOrAwayFromZero),
        test("10000000000000000", "1.000000000000000E+16", .toNearestOrAwayFromZero),
        test("10000000000000001", "1.000000000000000E+16", .toNearestOrAwayFromZero),
        test("10000000000000003", "1.000000000000000E+16", .toNearestOrAwayFromZero),
        test("10000000000000005", "1.000000000000001E+16", .toNearestOrAwayFromZero),
        test("100000000000000050", "1.000000000000001E+17", .toNearestOrAwayFromZero),
        test("10000000000000009", "1.000000000000001E+16", .toNearestOrAwayFromZero),
        test("100000000000000000", "1.000000000000000E+17", .toNearestOrAwayFromZero),
        test("100000000000000003", "1.000000000000000E+17", .toNearestOrAwayFromZero),
        test("100000000000000005", "1.000000000000000E+17", .toNearestOrAwayFromZero),
        test("100000000000000009", "1.000000000000000E+17", .toNearestOrAwayFromZero),
        test("1000000000000000000", "1.000000000000000E+18", .toNearestOrAwayFromZero),
        test("1000000000000000300", "1.000000000000000E+18", .toNearestOrAwayFromZero),
        test("1000000000000000500", "1.000000000000001E+18", .toNearestOrAwayFromZero),
        test("1000000000000000900", "1.000000000000001E+18", .toNearestOrAwayFromZero),
        test("10000000000000000000", "1.000000000000000E+19", .toNearestOrAwayFromZero),
        test("10000000000000003000", "1.000000000000000E+19", .toNearestOrAwayFromZero),
        test("10000000000000005000", "1.000000000000001E+19", .toNearestOrAwayFromZero),
        test("10000000000000009000", "1.000000000000001E+19", .toNearestOrAwayFromZero),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(Decimal64(BigDecimal(t.input).round(Rounding(t.mode, 16))).asBigDecimal().asString(.scientific), t.result)
        }
    }

    let tests2: [test] = [
        test("100", "100", .toNearestOrAwayFromZero),
        test("1000", "1000", .toNearestOrAwayFromZero),
        test("10000", "10000", .toNearestOrAwayFromZero),
        test("100000", "100000", .toNearestOrAwayFromZero),
        test("999.9", "999.9", .toNearestOrAwayFromZero),
        test("1000.0", "1000.0", .toNearestOrAwayFromZero),
        test("1000.1", "1000.1", .toNearestOrAwayFromZero),
        test("10000000000000000", "10.00000000000000E+15", .toNearestOrAwayFromZero),
        test("10000000000000000", "10.00000000000000E+15", .toNearestOrAwayFromZero),
        test("10000000000000001", "10.00000000000000E+15", .toNearestOrAwayFromZero),
        test("10000000000000003", "10.00000000000000E+15", .toNearestOrAwayFromZero),
        test("10000000000000005", "10.00000000000001E+15", .toNearestOrAwayFromZero),
        test("100000000000000050", "100.0000000000001E+15", .toNearestOrAwayFromZero),
        test("10000000000000009", "10.00000000000001E+15", .toNearestOrAwayFromZero),
        test("100000000000000000", "100.0000000000000E+15", .toNearestOrAwayFromZero),
        test("100000000000000003", "100.0000000000000E+15", .toNearestOrAwayFromZero),
        test("100000000000000005", "100.0000000000000E+15", .toNearestOrAwayFromZero),
        test("100000000000000009", "100.0000000000000E+15", .toNearestOrAwayFromZero),
        test("1000000000000000000", "1.000000000000000E+18", .toNearestOrAwayFromZero),
        test("1000000000000000300", "1.000000000000000E+18", .toNearestOrAwayFromZero),
        test("1000000000000000500", "1.000000000000001E+18", .toNearestOrAwayFromZero),
        test("1000000000000000900", "1.000000000000001E+18", .toNearestOrAwayFromZero),
        test("10000000000000000000", "10.00000000000000E+18", .toNearestOrAwayFromZero),
        test("10000000000000003000", "10.00000000000000E+18", .toNearestOrAwayFromZero),
        test("10000000000000005000", "10.00000000000001E+18", .toNearestOrAwayFromZero),
        test("10000000000000009000", "10.00000000000001E+18", .toNearestOrAwayFromZero),
    ]

    func test2() throws {
        for t in tests2 {
            XCTAssertEqual(Decimal64(BigDecimal(t.input).round(Rounding(t.mode, 16))).asBigDecimal().asString(.engineering), t.result)
        }
    }
    
    func test3() throws {
        for _ in 0 ..< 100 {
            let x = BInt(1000000).randomLessThan()
            for i in -10 ... 10 {
                let b1 = BigDecimal(x, i * 37)
                let b2 = BigDecimal(-x, i * 37)
                XCTAssertEqual(b1, BigDecimal(b1.asDecimal64()))
                XCTAssertEqual(b2, BigDecimal(b2.asDecimal64()))
            }
        }
    }

}
