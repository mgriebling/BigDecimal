//
//  TestMinMax.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 01/10/2022.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//
// min, max, ddMin, ddMax, dqMin, dqMax

import XCTest

final class TestMinMax: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    struct test {

        let x: String
        let y: String
        let m: String

        init(_ x: String, _ y: String, _ m: String) {
            self.x = x
            self.y = y
            self.m = m
        }
    }

    let testsMin: [test] = [
        test("-1.00E-999", "0", "-1.00E-999"),
        test("-0.1E-999", "0", "-1E-1000"),
        test("-0.10E-999", "0", "-1.0E-1000"),
        test("-0.01E-999", "0", "-1E-1001"),
        test("1.00E-383", "0", "0"),
        test("0.1E-383", "0", "0"),
        test("0.10E-383", "0", "0"),
        test("0.100E-383", "0", "0"),
        test("0.01E-383", "0", "0"),
        test("0.999E-383", "0", "0"),
        test("0.099E-383", "0", "0"),
        test("0.009E-383", "0", "0"),
        test("0.001E-383", "0", "0"),
        test("0.0009E-383", "0", "0"),
        test("0.0001E-383", "0", "0"),
        test("-1.00E-383", "0", "-1.00E-383"),
        test("-0.1E-383", "0", "-1E-384"),
        test("-0.10E-383", "0", "-1.0E-384"),
        test("-0.100E-383", "0", "-1.00E-384"),
        test("-0.01E-383", "0", "-1E-385"),
        test("-0.999E-383", "0", "-9.99E-384"),
        test("-0.099E-383", "0", "-9.9E-385"),
        test("-0.009E-383", "0", "-9E-386"),
        test("-0.001E-383", "0", "-1E-386"),
        test("-0.0009E-383", "0", "-9E-387"),
        test("-0.0001E-383", "0", "-1E-387"),
        test("1.00E-6143", "0", "0"),
        test("0.1E-6143", "0", "0"),
        test("0.10E-6143", "0", "0"),
        test("0.100E-6143", "0", "0"),
        test("0.01E-6143", "0", "0"),
        test("0.999E-6143", "0", "0"),
        test("0.099E-6143", "0", "0"),
        test("0.009E-6143", "0", "0"),
        test("0.001E-6143", "0", "0"),
        test("0.0009E-6143", "0", "0"),
        test("0.0001E-6143", "0", "0"),
        test("-1.00E-6143", "0", "-1.00E-6143"),
        test("-0.1E-6143", "0", "-1E-6144"),
        test("-0.10E-6143", "0", "-1.0E-6144"),
        test("-0.100E-6143", "0", "-1.00E-6144"),
        test("-0.01E-6143", "0", "-1E-6145"),
        test("-0.999E-6143", "0", "-9.99E-6144"),
        test("-0.099E-6143", "0", "-9.9E-6145"),
        test("-0.009E-6143", "0", "-9E-6146"),
        test("-0.001E-6143", "0", "-1E-6146"),
        test("-0.0009E-6143", "0", "-9E-6147"),
        test("-0.0001E-6143", "0", "-1E-6147"),
    ]

    let testsMax: [test] = [
        test("1.00E-999", "0", "1.00E-999"),
        test("0.1E-999", "0", "1E-1000"),
        test("0.10E-999", "0", "1.0E-1000"),
        test("0.01E-999", "0", "1E-1001"),
        test("1.00E-383", "0", "1.00E-383"),
        test("0.1E-383", "0", "1E-384"),
        test("0.10E-383", "0", "1.0E-384"),
        test("0.100E-383", "0", "1.00E-384"),
        test("0.01E-383", "0", "1E-385"),
        test("0.999E-383", "0", "9.99E-384"),
        test("0.099E-383", "0", "9.9E-385"),
        test("0.009E-383", "0", "9E-386"),
        test("0.001E-383", "0", "1E-386"),
        test("0.0009E-383", "0", "9E-387"),
        test("0.0001E-383", "0", "1E-387"),
        test("-1.00E-383", "0", "0"),
        test("-0.1E-383", "0", "0"),
        test("-0.10E-383", "0", "0"),
        test("-0.100E-383", "0", "0"),
        test("-0.01E-383", "0", "0"),
        test("-0.999E-383", "0", "0"),
        test("-0.099E-383", "0", "0"),
        test("-0.009E-383", "0", "0"),
        test("-0.001E-383", "0", "0"),
        test("-0.0009E-383", "0", "0"),
        test("-0.0001E-383", "0", "0"),
        test("1.00E-6143", "0", "1.00E-6143"),
        test("0.1E-6143", "0", "1E-6144"),
        test("0.10E-6143", "0", "1.0E-6144"),
        test("0.100E-6143", "0", "1.00E-6144"),
        test("0.01E-6143", "0", "1E-6145"),
        test("0.999E-6143", "0", "9.99E-6144"),
        test("0.099E-6143", "0", "9.9E-6145"),
        test("0.009E-6143", "0", "9E-6146"),
        test("0.001E-6143", "0", "1E-6146"),
        test("0.0009E-6143", "0", "9E-6147"),
        test("0.0001E-6143", "0", "1E-6147"),
        test("-1.00E-6143", "0", "0"),
        test("-0.1E-6143", "0", "0"),
        test("-0.10E-6143", "0", "0"),
        test("-0.100E-6143", "0", "0"),
        test("-0.01E-6143", "0", "0"),
        test("-0.999E-6143", "0", "0"),
        test("-0.099E-6143", "0", "0"),
        test("-0.009E-6143", "0", "0"),
        test("-0.001E-6143", "0", "0"),
        test("-0.0009E-6143", "0", "0"),
        test("-0.0001E-6143", "0", "0"),
    ]

    let testsNaN: [test] = [
        test("0", "NaN", "NaN"),
        test("NaN", "0", "NaN"),
        test("NaN", "NaN", "NaN"),
    ]

    func testMin() {
        for t in testsMin {
            XCTAssertEqual(BigDecimal.minimum(BigDecimal(t.x), BigDecimal(t.y)).asString(), t.m)
        }
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testMax() {
        for t in testsMax {
            XCTAssertEqual(BigDecimal.maximum(BigDecimal(t.x), BigDecimal(t.y)).asString(), t.m)
        }
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testNaN() {
        for t in testsNaN {
            XCTAssertEqual(BigDecimal.maximum(BigDecimal(t.x), BigDecimal(t.y)).asString(), t.m)
        }
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

}
