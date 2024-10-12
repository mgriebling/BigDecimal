//
//  TestDecimal32.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 01/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal
import BigInt

class TestDecimal32: XCTestCase {

    override func setUpWithError() throws {
        //BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        //XCTAssertFalse(BigDecimal.nanFlag)
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
        test("1.1123450", "1.112345", .awayFromZero),
        test("1.11234549", "1.112346", .awayFromZero),
        test("1.11234550", "1.112346", .awayFromZero),
        test("1.11234551", "1.112346", .awayFromZero),
        test("1.1123450", "1.112345", .up),
        test("1.11234549", "1.112346", .up),
        test("1.11234550", "1.112346", .up),
        test("1.11234551", "1.112346", .up),
        test("1.1123450", "1.112345", .towardZero),
        test("1.11234549", "1.112345", .towardZero),
        test("1.11234550", "1.112345", .towardZero),
        test("1.11234551", "1.112345", .towardZero),
        test("1.1123450", "1.112345", .down),
        test("1.11234549", "1.112345", .down),
        test("1.11234550", "1.112345", .down),
        test("1.11234551", "1.112345", .down),
        test("1.1123450", "1.112345", .toNearestOrEven),
        test("1.11234549", "1.112345", .toNearestOrEven),
        test("1.11234550", "1.112346", .toNearestOrEven),
        test("1.11234650", "1.112346", .toNearestOrEven),
        test("1.11234551", "1.112346", .toNearestOrEven),
        test("1.1123450", "1.112345", .toNearestOrAwayFromZero),
        test("1.11234549", "1.112345", .toNearestOrAwayFromZero),
        test("1.11234550", "1.112346", .toNearestOrAwayFromZero),
        test("1.11234650", "1.112347", .toNearestOrAwayFromZero),
        test("1.11234551", "1.112346", .toNearestOrAwayFromZero),
        test("-1.1123450", "-1.112345", .awayFromZero),
        test("-1.11234549", "-1.112345", .awayFromZero),
        test("-1.11234550", "-1.112345", .awayFromZero),
        test("-1.11234551", "-1.112345", .awayFromZero),
        test("-1.1123450", "-1.112345", .up),
        test("-1.11234549", "-1.112346", .up),
        test("-1.11234550", "-1.112346", .up),
        test("-1.11234551", "-1.112346", .up),
        test("-1.1123450", "-1.112345", .towardZero),
        test("-1.11234549", "-1.112346", .towardZero),
        test("-1.11234550", "-1.112346", .towardZero),
        test("-1.11234551", "-1.112346", .towardZero),
        test("-1.1123450", "-1.112345", .down),
        test("-1.11234549", "-1.112345", .down),
        test("-1.11234550", "-1.112345", .down),
        test("-1.11234551", "-1.112345", .down),
        test("-1.1123450", "-1.112345", .toNearestOrEven),
        test("-1.11234549", "-1.112345", .toNearestOrEven),
        test("-1.11234550", "-1.112346", .toNearestOrEven),
        test("-1.11234650", "-1.112346", .toNearestOrEven),
        test("-1.11234551", "-1.112346", .toNearestOrEven),
        test("-1.1123450", "-1.112345", .toNearestOrAwayFromZero),
        test("-1.11234549", "-1.112345", .toNearestOrAwayFromZero),
        test("-1.11234550", "-1.112346", .toNearestOrAwayFromZero),
        test("-1.11234650", "-1.112347", .toNearestOrAwayFromZero),
        test("-1.11234551", "-1.112346", .toNearestOrAwayFromZero),
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
        test("100", "100"),
        test("1000", "1000"),
        test("10000", "10000"),
        test("100000", "100000"),
        test("999.9", "999.9"),
        test("1000.0", "1000.0"),
        test("1000.1", "1000.1"),
        test("10000000", "1.000000E+7"),
        test("10000003", "1.000000E+7"),
        test("10000005", "1.000000E+7"),
        test("100000050", "1.000000E+8"),
        test("10000009", "1.000001E+7"),
        test("100000000", "1.000000E+8"),
        test("100000003", "1.000000E+8"),
        test("100000005", "1.000000E+8"),
        test("100000009", "1.000000E+8"),
        test("1000000000", "1.000000E+9"),
        test("1000000300", "1.000000E+9"),
        test("1000000500", "1.000000E+9"),
        test("1000000900", "1.000001E+9"),
        test("10000000000", "1.000000E+10"),
        test("10000003000", "1.000000E+10"),
        test("10000005000", "1.000000E+10"),
        test("10000009000", "1.000001E+10"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.input).round(Rounding(t.mode, 7)).asString(.scientific), t.result)
        }
    }

    func test2() throws {
        for _ in 0 ..< 100 {
            let x = BInt(1000000).randomLessThan()
            for i in -10 ... 10 {
                let b1 = BigDecimal(x, i * 9)
                let b2 = BigDecimal(-x, i * 9)
                XCTAssertEqual(b1, BigDecimal(b1.asDecimal32()))
                XCTAssertEqual(b2, BigDecimal(b2.asDecimal32()))
            }
        }
    }

}
