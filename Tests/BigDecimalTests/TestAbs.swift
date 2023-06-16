//
//  TestAbs.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 05/08/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestAbs: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct test {

        let x: String
        let abs: String

        init(_ x: String, _ abs: String) {
            self.x = x
            self.abs = abs
        }
    }

    let tests15: [test] = [
        test("12345678000", "12345678000"),
        test("1234567800", "1234567800"),
        test("1234567890", "1234567890"),
        test("1234567891", "1234567891"),
        test("12345678901", "12345678901"),
        test("1234567896", "1234567896"),
    ]

    let tests9: [test] = [
        test("1", "1"),
        test("-1", "1"),
        test("1.00", "1.00"),
        test("-1.00", "1.00"),
        test("0", "0"),
        test("0.00", "0.00"),
        test("00.0", "0.0"),
        test("00.00", "0.00"),
        test("00", "0"),
        test("-2000000", "2000000"),
        test("2000000", "2000000"),
        test("-56267E-10", "0.0000056267"),
        test("-56267E-5", "0.56267"),
        test("-56267E-2", "562.67"),
        test("-56267E-1", "5626.7"),
        test("-56267E-0", "56267"),
        test("12345678000", "1.23456780E+10"),
        test("1234567800", "1.23456780E+9"),
        test("1234567890", "1.23456789E+9"),
        test("1234567891", "1.23456789E+9"),
        test("12345678901", "1.23456789E+10"),
        test("1234567896", "1.23456790E+9"),
    ]

    let tests7: [test] = [
        test("-2000000", "2000000"),
        test("2000000", "2000000"),
    ]

    let tests6: [test] = [
        test("-2000000", "2.00000E+6"),
        test("2000000", "2.00000E+6"),
    ]

    let tests3: [test] = [
        test("-2000000", "2.00E+6"),
        test("2000000", "2.00E+6"),
        test("+0.1", "0.1"),
        test("-0.1", "0.1"),
        test("+0.01", "0.01"),
        test("-0.01", "0.01"),
        test("+0.001", "0.001"),
        test("-0.001", "0.001"),
        test("+0.000001", "0.000001"),
        test("-0.000001", "0.000001"),
        test("+0.000000000001", "1E-12"),
        test("-0.000000000001", "1E-12"),
        test("1.00E-999", "1.00E-999"),
        test("0.1E-999", "1E-1000"),
        test("0.10E-999", "1.0E-1000"),
        test("0.100E-999", "1.0E-1000"),
        test("0.01E-999", "1E-1001"),
    ]

    func test15() throws {
        let rnd = Rounding(.halfUp, 15)
        for t in tests15 {
            XCTAssertEqual(BigDecimal(t.x).round(rnd).abs, BigDecimal(t.abs))
        }
    }

    func test9() throws {
        let rnd = Rounding(.halfUp, 9)
        for t in tests9 {
            XCTAssertEqual(BigDecimal(t.x).round(rnd).abs, BigDecimal(t.abs))
        }
    }

    func test7() throws {
        let rnd = Rounding(.halfUp, 7)
        for t in tests7 {
            XCTAssertEqual(BigDecimal(t.x).round(rnd).abs, BigDecimal(t.abs))
        }
    }

    func test6() throws {
        let rnd = Rounding(.halfUp, 6)
        for t in tests6 {
            XCTAssertEqual(BigDecimal(t.x).round(rnd).abs, BigDecimal(t.abs))
        }
    }

    func test3() throws {
        let rnd = Rounding(.halfUp, 3)
        for t in tests3 {
            XCTAssertEqual(BigDecimal(t.x).round(rnd).abs, BigDecimal(t.abs))
        }
    }

}
