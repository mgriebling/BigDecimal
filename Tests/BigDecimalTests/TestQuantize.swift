//
//  TestQuantize.swift
//  BigDecimalTestTests
//
//  Created by Leif Ibsen on 11/10/2022.
//

import XCTest
@testable import BigDecimal

final class TestQuantize: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
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
        test("2.17", "0.001", "2.170"),
        test("2.17", "0.01", "2.17"),
        test("2.17", "0.1", "2.2"),
        test("2.17", "1E+0", "2"),
        test("2.17", "1E+1", "0E+1"),
        test("-Infinity", "+Infinity", "-Infinity"),
        test("2", "+Infinity", "NaN"),
        test("-0.1", "1", "0"),
        test("-0", "1E+5", "0E+5"),
        test("217", "1E-1", "217.0"),
        test("217", "1E+0", "217"),
        test("217", "1E+1", "2.2E+2"),
        test("217", "1E+2", "2E+2"),
        test("0", "-9e0", "0"),
        test("1", "-7e0", "1"),
        test("0.1", "-1e+2", "0E+2"),
        test("0.1", "0e+1", "0E+1"),
        test("0.1", "2e0", "0"),
        test("0.1", "3e-1", "0.1"),
        test("0.1", "44e-2", "0.10"),
        test("0.1", "555e-3", "0.100"),
        test("0.9", "6666e+2", "0E+2"),
        test("0.9", "-777e+1", "0E+1"),
        test("0.9", "-88e+0", "1"),
        test("0.9", "-9e-1", "0.9"),
        test("0.9", "0e-2", "0.90"),
        test("0.9", "1.1e-3", "0.9000"),
        test("-0", "1.1e0", "0.0"),
        test("-1", "-1e0", "-1"),
        test("-0.1", "11e+2", "0E+2"),
        test("-0.1", "111e+1", "0E+1"),
        test("-0.1", "71e0", "0"),
        test("-0.1", "-91e-1", "-0.1"),
        test("-0.1", "-.1e-2", "-0.100"),
        test("-0.1", "-1e-3", "-0.100"),
        test("-0.9", "0e+2", "0E+2"),
        test("-0.9", "-0e+1", "0E+1"),
        test("-0.9", "-10e+0", "-1"),
        test("-0.9", "100e-1", "-0.9"),
        test("-0.9", "999e-2", "-0.90"),
    ]
    
    func test1() throws {
        let rnd = Rounding(.toNearestOrAwayFromZero, 9)
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.x).quantize(BigDecimal(t.y), rnd.mode).asString(), t.result)
        }
        XCTAssertTrue(BigDecimal.nanFlag)
    }

}
