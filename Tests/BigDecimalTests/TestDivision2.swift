//
//  TestDivision2.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 06/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//
// ddDivide and dqDivide

import XCTest
@testable import BigDecimal

class TestDivision2: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.nanFlag)
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

    let tests1: [test] = [
        test("1", "1", "1"),
        test("2", "1", "2"),
        test("1", "2", "0.5"),
        test("2", "2", "1"),
        test("0", "1", "0"),
        test("0", "2", "0"),
        test("3", "3", "1"),
        test("2.4", "1", "2.4"),
        test("2.4", "-1", "-2.4"),
        test("-2.4", "1", "-2.4"),
        test("-2.4", "-1", "2.4"),
        test("2.40", "1", "2.40"),
        test("2.400", "1", "2.400"),
        test("2.4", "2", "1.2"),
        test("2.400", "2", "1.200"),
        test("2.", "2", "1"),
        test("20", "20", "1"),
        test("187", "187", "1"),
        test("5", "2", "2.5"),
        test("50", "20", "2.5"),
        test("500", "200", "2.5"),
        test("50.0", "20.0", "2.5"),
        test("5.00", "2.00", "2.5"),
        test("5", "2.0", "2.5"),
        test("5", "2.000", "2.5"),
        test("5", "0.20", "25"),
        test("5", "0.200", "25"),
        test("10", "1", "10"),
        test("100", "1", "100"),
        test("1000", "1", "1000"),
        test("1000", "100", "10"),
        test("1", "2", "0.5"),
        test("1", "4", "0.25"),
        test("1", "8", "0.125"),
        test("1", "16", "0.0625"),
        test("1", "32", "0.03125"),
        test("1", "64", "0.015625"),
        test("1", "-2", "-0.5"),
        test("1", "-4", "-0.25"),
        test("1", "-8", "-0.125"),
        test("1", "-16", "-0.0625"),
        test("1", "-32", "-0.03125"),
        test("1", "-64", "-0.015625"),
        test("-1", "2", "-0.5"),
        test("-1", "4", "-0.25"),
        test("-1", "8", "-0.125"),
        test("-1", "16", "-0.0625"),
        test("-1", "32", "-0.03125"),
        test("-1", "64", "-0.015625"),
        test("-1", "-2", "0.5"),
        test("-1", "-4", "0.25"),
        test("-1", "-8", "0.125"),
        test("-1", "-16", "0.0625"),
        test("-1", "-32", "0.03125"),
        test("-1", "-64", "0.015625"),
        test("0.", "1", "0"),
        test(".0", "1", "0.0"),
        test("0.00", "1", "0.00"),
        test("0.00E+9", "1", "0E+7"),
        test("0.0000E-50", "1", "0E-54"),
        test("1", "1E-8", "1E+8"),
        test("1", "1E-9", "1E+9"),
        test("1", "1E-10", "1E+10"),
        test("1", "1E-11", "1E+11"),
        test("1", "1E-12", "1E+12"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual((BigDecimal(t.x).divide(BigDecimal(t.y))).asString(), t.result)
        }
    }
    
    let tests2: [test] = [
        test("1", "3", "0.3333333333333333"),
        test("2", "3", "0.6666666666666667"),
        test("1", "7", "0.1428571428571429"),
        test("1.2345678", "1.9876543", "0.6211179680490717"),

    ]

    func test2() throws {
        let rnd = Rounding.decimal64
        for t in tests2 {
            XCTAssertEqual((BigDecimal(t.x).divide(BigDecimal(t.y), rnd)).asString(), t.result)
        }
    }

    let tests3: [test] = [
        test("1", "3", "0.3333333333333333333333333333333333"),
        test("2", "3", "0.6666666666666666666666666666666667"),
        test("1", "7", "0.1428571428571428571428571428571429"),
        test("1.2345678", "1.9876543", "0.6211179680490717123193907511985359"),
        test("12345", "4.999", "2469.493898779755951190238047609522"),
        test("12345", "4.99", "2473.947895791583166332665330661323"),
        test("12345", "4.9", "2519.387755102040816326530612244898"),
        test("12345", "5", "2469"),
        test("12345", "5.1", "2420.588235294117647058823529411765"),
        test("12345", "5.01", "2464.071856287425149700598802395210"),
        test("12345", "5.001", "2468.506298740251949610077984403119"),
        test("391", "597", "0.6549413735343383584589614740368509"),
        test("391", "-597", "-0.6549413735343383584589614740368509"),
        test("-391", "597", "-0.6549413735343383584589614740368509"),
        test("-391", "-597", "0.6549413735343383584589614740368509"),
    ]

    func test3() throws {
        let rnd = Rounding.decimal128
        for t in tests3 {
            XCTAssertEqual((BigDecimal(t.x).divide(BigDecimal(t.y), rnd)).asString(), t.result)
        }
    }

}
