//
//  TestTrim.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 10/05/2021.
//

import XCTest

class TestTrim: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct test {

        let x: String
        let result: String

        init(_ x: String, _ result: String) {
            self.x = x
            self.result = result
        }
    }

    let tests1: [test] = [
        test("10E+1", "1E+2"),
        test("100E+1", "1E+3"),
        test("1.0E+2", "1E+2"),
        test("1.0E+3", "1E+3"),
        test("1.1E+3", "1.1E+3"),
        test("1.00E+3", "1E+3"),
        test("1.10E+3", "1.1E+3"),
        test("-10E+1", "-1E+2"),
        test("-100E+1", "-1E+3"),
        test("-1.0E+2", "-1E+2"),
        test("-1.0E+3", "-1E+3"),
        test("-1.1E+3", "-1.1E+3"),
        test("-1.00E+3", "-1E+3"),
        test("-1.10E+3", "-1.1E+3"),
        test("11", "11"),
        test("10", "1E+1"),
        test("10.", "1E+1"),
        test("1.1E+1", "11"),
        test("1.0E+1", "1E+1"),
        test("1.10E+2", "1.1E+2"),
        test("1.00E+2", "1E+2"),
        test("1.100E+3", "1.1E+3"),
        test("1.000E+3", "1E+3"),
        test("1.000000E+6", "1E+6"),
        test("-11", "-11"),
        test("-10", "-1E+1"),
        test("-10", "-1E+1"),
        test("-1.1E+1", "-11"),
        test("-1.0E+1", "-1E+1"),
        test("-1.10E+2", "-1.1E+2"),
        test("-1.00E+2", "-1E+2"),
        test("-1.100E+3", "-1.1E+3"),
        test("-1.000E+3", "-1E+3"),
        test("-1.00000E+5", "-1E+5"),
        test("-1.000000E+6", "-1E+6"),
        test("-10.00000E+6", "-1E+7"),
        test("-100.0000E+6", "-1E+8"),
        test("-1000.000E+6", "-1E+9"),
        test("-10000.00E+6", "-1E+10"),
        test("-100000.0E+6", "-1E+11"),
        test("-1000000.E+6", "-1E+12"),
        test("2.1", "2.1"),
        test("-2.0", "-2"),
        test("1.200", "1.2"),
        test("-120", "-1.2E+2"),
        test("120.00", "1.2E+2"),
        test("0.00", "0"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.x).trim.asString(), t.result)
        }
    }

}
