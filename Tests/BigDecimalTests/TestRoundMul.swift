//
//  TestRoundMul.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 09/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestRoundMul: XCTestCase {

    override func setUpWithError() throws {
        //BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
       //XCTAssertFalse(BigDecimal.nanFlag)
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
        test("12345", "1"),
        test("12345", "1.0001"),
        test("12345", "1.001"),
        test("12345", "1.01"),
        test("12345", "1.1"),
        test("12345", "4"),
        test("12345", "4.0001"),
        test("12345", "4.9"),
        test("12345", "4.99"),
        test("12345", "4.999"),
        test("12345", "4.9999"),
        test("12345", "5"),
        test("12345", "5.0001"),
        test("12345", "5.001"),
        test("12345", "5.01"),
        test("12345", "12"),
        test("12345", "13"),
        test("12355", "12"),
        test("12355", "13"),
    ]
    
    let res1: [String] = [ // .down results
        "12345", "12346", "12357", "12468", "13579", "49380", "49381", "60490", "61601", "61712", "61723", "61725", "61726", "61737", "61848", "1.4814E+5", "1.6048E+5", "1.4826E+5", "1.6061E+5",]
    let res2: [String] = [ // .towardZero results
        "12345", "12346", "12357", "12468", "13579", "49380", "49381", "60490", "61602", "61713", "61724", "61725", "61726", "61737", "61848", "1.4814E+5", "1.6048E+5", "1.4826E+5", "1.6061E+5",]
    let res3: [String] = [ // .toNearestOrEven results
        "12345", "12346", "12357", "12468", "13580", "49380", "49381", "60490", "61602", "61713", "61724", "61725", "61726", "61737", "61848", "1.4814E+5", "1.6048E+5", "1.4826E+5", "1.6062E+5",]
    let res4: [String] = [ // .toNearestOrAwayFromZero results
        "12345", "12346", "12357", "12468", "13580", "49380", "49381", "60491", "61602", "61713", "61724", "61725", "61726", "61737", "61848", "1.4814E+5", "1.6049E+5", "1.4826E+5", "1.6062E+5",]
    let res5: [String] = [ // .up results
        "12345", "12347", "12358", "12469", "13580", "49380", "49382", "60491", "61602", "61713", "61724", "61725", "61727", "61738", "61849", "1.4814E+5", "1.6049E+5", "1.4826E+5", "1.6062E+5",]
    let res6: [String] = [ // .towardZero results
        "12345", "12346", "12357", "12468", "13579", "49380", "49381", "60490", "61601", "61712", "61723", "61725", "61726", "61737", "61848", "1.4814E+5", "1.6048E+5", "1.4826E+5", "1.6061E+5",]
    let res7: [String] = [ // .awayFromZero results
        "12345", "12347", "12358", "12469", "13580", "49380", "49382", "60491", "61602", "61713", "61724", "61725", "61727", "61738", "61849", "1.4814E+5", "1.6049E+5", "1.4826E+5", "1.6062E+5",]

    func test1() throws {
        let rnd1 = Rounding(.down, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd1.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res1[i])
        }
//        let rnd2 = Rounding(.halfDown, 5)
//        for i in 0 ..< tests.count {
//            XCTAssertEqual(rnd2.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res2[i])
//        }
        let rnd3 = Rounding(.toNearestOrEven, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd3.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res3[i])
        }
        let rnd4 = Rounding(.toNearestOrAwayFromZero, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd4.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res4[i])
        }
        let rnd5 = Rounding(.up, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd5.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res5[i])
        }
        let rnd6 = Rounding(.towardZero, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd6.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res6[i])
        }
        let rnd7 = Rounding(.awayFromZero, 5)
        for i in 0 ..< tests.count {
            XCTAssertEqual(rnd7.round(BigDecimal(tests[i].x) * BigDecimal(tests[i].y)).asString(), res7[i])
        }
    }

}
