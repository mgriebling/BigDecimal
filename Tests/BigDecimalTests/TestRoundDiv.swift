//
//  TestRoundDiv.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 08/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestRoundDiv: XCTestCase {

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

    let tests1: [test] = [
        test("12345", "1"),
        test("12345", "1.0001"),
        test("12345", "1.001"),
        test("12345", "1.01"),
        test("12345", "1.1"),
        test("12355", "4"),
        test("12345", "4"),
        test("12355", "4.0001"),
        test("12345", "4.0001"),
        test("12345", "4.9"),
        test("12345", "4.99"),
        test("12345", "4.999"),
        test("12345", "4.9999"),
        test("12345", "5"),
        test("12345", "5.0001"),
        test("12345", "5.001"),
        test("12345", "5.01"),
        test("12345", "5.1"),
    ]

    let res11: [String] = [ // .down results
        "12345", "12343", "12332", "12222", "11222", "3088.7", "3086.2", "3088.6", "3086.1", "2519.3", "2473.9", "2469.4", "2469.0", "2469", "2468.9", "2468.5", "2464.0", "2420.5",]
    let res12: [String] = [ // .towardZero results
        "12345", "12344", "12333", "12223", "11223", "3088.7", "3086.2", "3088.7", "3086.2", "2519.4", "2473.9", "2469.5", "2469.0", "2469", "2469.0", "2468.5", "2464.1", "2420.6",]
    let res13: [String] = [ // .toNearestOrEven results
        "12345", "12344", "12333", "12223", "11223", "3088.8", "3086.2", "3088.7", "3086.2", "2519.4", "2473.9", "2469.5", "2469.0", "2469", "2469.0", "2468.5", "2464.1", "2420.6",]
    let res14: [String] = [ // .toNearestOrAwayFromZero results
        "12345", "12344", "12333", "12223", "11223", "3088.8", "3086.3", "3088.7", "3086.2", "2519.4", "2473.9", "2469.5", "2469.0", "2469", "2469.0", "2468.5", "2464.1", "2420.6",]
    let res15: [String] = [ // .up results
        "12345", "12344", "12333", "12223", "11223", "3088.8", "3086.3", "3088.7", "3086.2", "2519.4", "2474.0", "2469.5", "2469.1", "2469", "2469.0", "2468.6", "2464.1", "2420.6",]
    let res16: [String] = [ // .towardZero results
        "12345", "12343", "12332", "12222", "11222", "3088.7", "3086.2", "3088.6", "3086.1", "2519.3", "2473.9", "2469.4", "2469.0", "2469", "2468.9", "2468.5", "2464.0", "2420.5",]
    let res17: [String] = [ // .awayFromZero results
        "12345", "12344", "12333", "12223", "11223", "3088.8", "3086.3", "3088.7", "3086.2", "2519.4", "2474.0", "2469.5", "2469.1", "2469", "2469.0", "2468.6", "2464.1", "2420.6",]

    func test1() throws {
        let rnd1 = Rounding(.down, 5)
        for i in 0 ..< tests1.count {
            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd1).asString(), res11[i])
        }
//        let rnd2 = Rounding(.halfDown, 5)
//        for i in 0 ..< tests1.count {
//            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd2).asString(), res12[i])
//        }
        let rnd3 = Rounding(.toNearestOrEven, 5)
        for i in 0 ..< tests1.count {
            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd3).asString(), res13[i])
        }
        let rnd4 = Rounding(.toNearestOrAwayFromZero, 5)
        for i in 0 ..< tests1.count {
            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd4).asString(), res14[i])
        }
        let rnd5 = Rounding(.up, 5)
        for i in 0 ..< tests1.count {
            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd5).asString(), res15[i])
        }
        let rnd6 = Rounding(.towardZero, 5)
        for i in 0 ..< tests1.count {
            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd6).asString(), res16[i])
        }
        let rnd7 = Rounding(.awayFromZero, 5)
        for i in 0 ..< tests1.count {
            XCTAssertEqual(BigDecimal(tests1[i].x).divide(BigDecimal(tests1[i].y), rnd7).asString(), res17[i])
        }
    }

    let tests2: [test] = [
        test("2", "3"),
        test("2", "-3"),
        test("1", "3"),
        test("1", "-3"),
        test("55555", "100000"),
        test("55555", "-100000"),
        test("555555", "1000000"),
        test("555555", "-1000000"),
    ]
    
    let res21: [String] = [ // .down results
        "0.6666", "-0.6666", "0.3333", "-0.3333", "0.5555", "-0.5555", "0.5555", "-0.5555",]
    let res22: [String] = [ // .HALF_DOWN results
        "0.6667", "-0.6667", "0.3333", "-0.3333", "0.5555", "-0.5555", "0.5556", "-0.5556",]
    let res23: [String] = [ // .halfEven results
        "0.6667", "-0.6667", "0.3333", "-0.3333", "0.5556", "-0.5556", "0.5556", "-0.5556",]
    let res24: [String] = [ // .halfUp results
        "0.6667", "-0.6667", "0.3333", "-0.3333", "0.5556", "-0.5556", "0.5556", "-0.5556",]
    let res25: [String] = [ // .up results
        "0.6667", "-0.6667", "0.3334", "-0.3334", "0.5556", "-0.5556", "0.5556", "-0.5556",]
    let res26: [String] = [ // .floor results
        "0.6666", "-0.6667", "0.3333", "-0.3334", "0.5555", "-0.5556", "0.5555", "-0.5556",]
    let res27: [String] = [ // .CEILING results
        "0.6667", "-0.6666", "0.3334", "-0.3333", "0.5556", "-0.5555", "0.5556", "-0.5555",]

    func test2() throws {
        let rnd1 = Rounding(.down, 4)
        for i in 0 ..< tests2.count {
            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd1).asString(), res21[i])
        }
//        let rnd2 = Rounding(.halfDown, 4)
//        for i in 0 ..< tests2.count {
//            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd2).asString(), res22[i])
//        }
        let rnd3 = Rounding(.toNearestOrEven, 4)
        for i in 0 ..< tests2.count {
            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd3).asString(), res23[i])
        }
        let rnd4 = Rounding(.toNearestOrAwayFromZero, 4)
        for i in 0 ..< tests2.count {
            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd4).asString(), res24[i])
        }
        let rnd5 = Rounding(.up, 4)
        for i in 0 ..< tests2.count {
            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd5).asString(), res25[i])
        }
        let rnd6 = Rounding(.towardZero, 4)
        for i in 0 ..< tests2.count {
            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd6).asString(), res26[i])
        }
        let rnd7 = Rounding(.awayFromZero, 4)
        for i in 0 ..< tests2.count {
            XCTAssertEqual(BigDecimal(tests2[i].x).divide(BigDecimal(tests2[i].y), rnd7).asString(), res27[i])
        }
    }

}
