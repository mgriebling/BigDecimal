//
//  TestRoundPow.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 09/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestRoundPow: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct test {

        let x: String
        let n: Int

        init(_ x: String, _ n: Int) {
            self.x = x
            self.n = n
        }
    }

    let tests: [test] = [
        test("12345", -5),
        test("12345", -4),
        test("12345", -3),
        test("12345", -2),
        test("12345", -1),
        test("12345", 0),
        test("12345", 1),
        test("12345", 2),
        test("12345", 3),
        test("12345", 4),
        test("12345", 5),
        test("415", 2),
        test("75", 3),
    ]

    let res1: [String] = [ // .down results
        "3.4877E-21", "4.3056E-17", "5.3152E-13", "6.5617E-9", "0.000081004", "1", "12345", "1.5239E+8", "1.8813E+12", "2.3225E+16", "2.8671E+20", "1.7222E+5", "4.2187E+5",]
    let res2: [String] = [ // .halfDown results
        "3.4877E-21", "4.3056E-17", "5.3153E-13", "6.5617E-9", "0.000081004", "1", "12345", "1.5240E+8", "1.8814E+12", "2.3225E+16", "2.8672E+20", "1.7222E+5", "4.2187E+5",]
    let res3: [String] = [ // .halfEven results
        "3.4877E-21", "4.3056E-17", "5.3153E-13", "6.5617E-9", "0.000081004", "1", "12345", "1.5240E+8", "1.8814E+12", "2.3225E+16", "2.8672E+20", "1.7222E+5", "4.2188E+5",]
    let res4: [String] = [ // .halfUp results
        "3.4877E-21", "4.3056E-17", "5.3153E-13", "6.5617E-9", "0.000081004", "1", "12345", "1.5240E+8", "1.8814E+12", "2.3225E+16", "2.8672E+20", "1.7223E+5", "4.2188E+5",]
    let res5: [String] = [ // .up results
        "3.4878E-21", "4.3057E-17", "5.3153E-13", "6.5618E-9", "0.000081005", "1", "12345", "1.5240E+8", "1.8814E+12", "2.3226E+16", "2.8672E+20", "1.7223E+5", "4.2188E+5",]
    let res6: [String] = [ // .floor results
        "3.4877E-21", "4.3056E-17", "5.3152E-13", "6.5617E-9", "0.000081004", "1", "12345", "1.5239E+8", "1.8813E+12", "2.3225E+16", "2.8671E+20", "1.7222E+5", "4.2187E+5",]
    let res7: [String] = [ // .ceiling results
        "3.4878E-21", "4.3057E-17", "5.3153E-13", "6.5618E-9", "0.000081005", "1", "12345", "1.5240E+8", "1.8814E+12", "2.3226E+16", "2.8672E+20", "1.7223E+5", "4.2188E+5",]

    func test1() throws {
        let rnd1 = Rounding(.down, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd1).asString(), res1[i])
        }
        let rnd2 = Rounding(.halfDown, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd2).asString(), res2[i])
        }
        let rnd3 = Rounding(.halfEven, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd3).asString(), res3[i])
        }
        let rnd4 = Rounding(.halfUp, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd4).asString(), res4[i])
        }
        let rnd5 = Rounding(.up, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd5).asString(), res5[i])
        }
        let rnd6 = Rounding(.floor, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd6).asString(), res6[i])
        }
        let rnd7 = Rounding(.ceiling, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(BigDecimal(tests[i].x).pow(tests[i].n, rnd7).asString(), res7[i])
        }
    }

}
