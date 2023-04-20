//
//  TestRoundAdd.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 09/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestRoundAdd: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct test {

        let x: String
        let y: String

        init(_ x: String, _ y: String) {
            self.x = x
            self.y = y
        }
    }

    let tests: [test] = [
        test("12345", "-0.1"),
        test("12345", "-0.01"),
        test("12345", "-0.001"),
        test("12345", "-0.00001"),
        test("12345", "-0.000001"),
        test("12345", "-0.0000001"),
        test("12345", "0"),
        test("12345", "0.0000001"),
        test("12345", "0.000001"),
        test("12345", "0.00001"),
        test("12345", "0.0001"),
        test("12345", "0.001"),
        test("12345", "0.01"),
        test("12345", "0.1"),
        test("12346", "0.49999"),
        test("12346", "0.5"),
        test("12346", "0.50001"),
        test("12345", "0.4"),
        test("12345", "0.49"),
        test("12345", "0.499"),
        test("12345", "0.49999"),
        test("12345", "0.5"),
        test("12345", "0.50001"),
        test("12345", "0.5001"),
        test("12345", "0.501"),
        test("12345", "0.51"),
        test("12345", "0.6"),
    ]

    let res1: [String] = [ // .DOWN results
        "12344", "12344", "12344", "12344", "12344", "12344", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",
        "12346", "12346", "12346", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",]
    let res2: [String] = [ // .HALF_DOWN results
        "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",
        "12346", "12346", "12347", "12345", "12345", "12345", "12345", "12345", "12346", "12346", "12346", "12346", "12346",]
    let res3: [String] = [ // .HALF_EVEN results
        "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",
        "12346", "12346", "12347", "12345", "12345", "12345", "12345", "12346", "12346", "12346", "12346", "12346", "12346",]
    let res4: [String] = [ // .HALF_UP results
        "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",
        "12346", "12347", "12347", "12345", "12345", "12345", "12345", "12346", "12346", "12346", "12346", "12346", "12346",]
    let res5: [String] = [ // .UP results
        "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12346", "12346", "12346", "12346", "12346", "12346", "12346",
        "12347", "12347", "12347", "12346", "12346", "12346", "12346", "12346", "12346", "12346", "12346", "12346", "12346",]
    let res6: [String] = [ // .FLOOR results
        "12344", "12344", "12344", "12344", "12344", "12344", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",
        "12346", "12346", "12346", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12345",]
    let res7: [String] = [ // .CEILING results
        "12345", "12345", "12345", "12345", "12345", "12345", "12345", "12346", "12346", "12346", "12346", "12346", "12346", "12346",
        "12347", "12347", "12347", "12346", "12346", "12346", "12346", "12346", "12346", "12346", "12346", "12346", "12346",]

    func test1() throws {
        let rnd1 = Rounding(.DOWN, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd1.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res1[i])
        }
        let rnd2 = Rounding(.HALF_DOWN, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd2.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res2[i])
        }
        let rnd3 = Rounding(.HALF_EVEN, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd3.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res3[i])
        }
        let rnd4 = Rounding(.HALF_UP, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd4.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res4[i])
        }
        let rnd5 = Rounding(.UP, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd5.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res5[i])
        }
        let rnd6 = Rounding(.FLOOR, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd6.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res6[i])
        }
        let rnd7 = Rounding(.CEILING, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd7.round(BigDecimal(tests[i].x) + BigDecimal(tests[i].y)).asString(), res7[i])
        }
    }

}
