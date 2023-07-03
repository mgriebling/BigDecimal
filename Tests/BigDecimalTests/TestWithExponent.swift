//
//  TestWithExponent.swift
//  BigDecimalTestTests
//
//  Created by Leif Ibsen on 24/10/2022.
//

import XCTest
@testable import BigDecimal

final class TestWithExponent: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    struct test {

        let x: String
        let n: Int
        let result: String

        init(_ x: String, _ n: Int, _ result: String) {
            self.x = x
            self.n = n
            self.result = result
        }
    }

    let tests1: [test] = [
        test("12345678000", 3, "1.2345678E+10"),
        test("0", 0, "0"),
        test("1", 0, "1"),
        test("0.1", 2, "0E+2"),
        test("0.1", 1, "0E+1"),
        test("0.1", 0, "0"),
        test("0.1", -1, "0.1"),
        test("0.1", -2, "0.10"),
        test("0.1", -3, "0.100"),
        test("0.9", 2, "0E+2"),
        test("0.9", 1, "0E+1"),
        test("0.9", 0, "1"),
        test("0.9", -1, "0.9"),
        test("0.9", -2, "0.90"),
        test("0.9", -3, "0.900"),
    ]

    func test1() throws {
        let rnd = Rounding(.toNearestOrAwayFromZero, 9)
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.x).withExponent(t.n, rnd.mode).asString(), t.result)
        }
    }

    let tests2: [test] = [
        test("1.666666E-999", -1005, "1.666666E-999"),
        test("1.666666E-1000", -1005, "1.66667E-1000"),
        test("1.666666E-1001", -1005, "1.6667E-1001"),
        test("1.666666E-1002", -1005, "1.667E-1002"),
        test("1.666666E-1003", -1005, "1.67E-1003"),
        test("1.666666E-1004", -1005, "1.7E-1004"),
        test("1.666666E-1005", -1005, "2E-1005"),
        test("1.666666E-1006", -1005, "0E-1005"),
        test("1.666666E-1007", -1005, "0E-1005"),
    ]

    func test2() throws {
        let rnd = Rounding(.toNearestOrAwayFromZero, 7)
        for t in tests2 {
            XCTAssertEqual(BigDecimal(t.x).withExponent(t.n, rnd.mode).asString(), t.result)
        }
    }

    let tests3: [test] = [
        test("0", 1, "0E+1"),
        test("0", 0, "0"),
        test("0", -1, "0.0"),
        test("0.0", -1, "0.0"),
        test("0.0", 0, "0"),
        test("0.0", 1, "0E+1"),
        test("0E+1", -1, "0.0"),
        test("0E+1", 0, "0"),
        test("0E+1", 1, "0E+1"),
        test("-0", 1, "0E+1"),
        test("-0", 0, "0"),
        test("-0", -1, "0.0"),
        test("-0.0", -1, "0.0"),
        test("-0.0", 0, "0"),
        test("-0.0", 1, "0E+1"),
        test("-0E+1", -1, "0.0"),
        test("-0E+1", 0, "0"),
        test("-0E+1", 1, "0E+1"),
    ]

    func test3() throws {
        let rnd = Rounding(.toNearestOrAwayFromZero, 15)
        for t in tests3 {
            XCTAssertEqual(BigDecimal(t.x).withExponent(t.n, rnd.mode).asString(), t.result)
        }
    }

    let tests4: [test] = [
        test("9.999", -5, "9.99900"),
        test("9.999", -4, "9.9990"),
        test("9.999", -3, "9.999"),
        test("9.999", -2, "10.00"),
        test("9.999", -1, "10.0"),
        test("9.999", 0, "10"),
        test("9.999", 1, "1E+1"),
        test("9.999", 2, "0E+2"),
        test("0.999", -5, "0.99900"),
        test("0.999", -4, "0.9990"),
        test("0.999", -3, "0.999"),
        test("0.999", -2, "1.00"),
        test("0.999", -1, "1.0"),
        test("0.999", 0, "1"),
        test("0.999", 1, "0E+1"),
        test("0.0999", -5, "0.09990"),
        test("0.0999", -4, "0.0999"),
        test("0.0999", -3, "0.100"),
        test("0.0999", -2, "0.10"),
        test("0.0999", -1, "0.1"),
        test("0.0999", 0, "0"),
        test("0.0999", 1, "0E+1"),
        test("0.00999", -5, "0.00999"),
        test("0.00999", -4, "0.0100"),
        test("0.00999", -3, "0.010"),
        test("0.00999", -2, "0.01"),
        test("0.00999", -1, "0.0"),
        test("0.00999", 0, "0"),
        test("0.00999", 1, "0E+1"),
        test("0.000999", -5, "0.00100"),
        test("0.000999", -4, "0.0010"),
        test("0.000999", -3, "0.001"),
        test("0.000999", -2, "0.00"),
        test("0.000999", -1, "0.0"),
        test("0.000999", 0, "0"),
        test("0.000999", 1, "0E+1"),
    ]

    func test4() throws {
        let rnd = Rounding(.toNearestOrAwayFromZero, 9)
        for t in tests4 {
            XCTAssertEqual(BigDecimal(t.x).withExponent(t.n, rnd.mode).asString(), t.result)
        }
    }

}
