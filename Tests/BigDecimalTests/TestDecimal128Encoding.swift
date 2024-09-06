//
//  TestDecimal128Encoding.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 03/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal
import BigInt
// import UInt128

class TestDecimal128Encoding: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    func string2UInt128(_ s: String) -> UInt128 {
        let b = BInt(s, radix: 16)!
        let lo = b.words[0]
        let hi = b.words.count == 1 ? 0 : b.words[1]
        return UInt128(_low: UInt64(lo), _high: UInt64(hi))
    }

    struct test {

        let input: String
        let result: String
        let enc: BigDecimal.Encoding

        init(_ input: String, _ result: String, _ enc: BigDecimal.Encoding = .dpd) {
            self.input = input
            self.result = result
            self.enc = enc
        }
    }
    
    let tests1: [test] = [
        test("A20780000000000000000000000003D0", "-7.50"),
        test("A20840000000000000000000000003D0", "-7.50E+3"),
        test("A20800000000000000000000000003D0", "-750"),
        test("A207c0000000000000000000000003D0", "-75.0"),
        test("A20700000000000000000000000003D0", "-0.0750"),
        test("A20680000000000000000000000003D0", "-0.000750"),
        test("A20600000000000000000000000003D0", "-0.00000750"),
        test("A205c0000000000000000000000003D0", "-7.50E-7"),
        test("2608134b9c1e28e56f3c127177823534", "1234567890123456789012345678901234"),
        test("a608134b9c1e28e56f3c127177823534", "-1234567890123456789012345678901234"),
        test("26080912449124491244912449124491", "1111111111111111111111111111111111"),
        test("77ffcff3fcff3fcff3fcff3fcff3fcff", "9.999999999999999999999999999999999E+6144"),
        test("47ffd34b9c1e28e56f3c127177823534", "1.234567890123456789012345678901234E+6144"),
        test("47ffd300000000000000000000000000", "1.230000000000000000000000000000000E+6144"),
        test("47ffc000000000000000000000000000", "1.000000000000000000000000000000000E+6144"),
        test("220800000000000000000000000049c5", "12345"),
        test("22080000000000000000000000000534", "1234"),
        test("220800000000000000000000000000a3", "123"),
        test("22080000000000000000000000000012", "12"),
        test("22080000000000000000000000000001", "1"),
        test("220780000000000000000000000000a3", "1.23"),
        test("220780000000000000000000000049c5", "123.45"),
        test("00084000000000000000000000000001", "1E-6143"),
        test("04000000000000000000000000000000", "1.000000000000000000000000000000000E-6143"),
        test("04000000000000000000000000000001", "1.000000000000000000000000000000001E-6143"),
        test("00000800000000000000000000000000", "1.00000000000000000000000000000000E-6144"),
        test("00000000000000000000000000000010", "1.0E-6175"),
        test("00004000000000000000000000000001", "1E-6175"),
        test("00000000000000000000000000000001", "1E-6176"),
        test("f7ffcff3fcff3fcff3fcff3fcff3fcff", "-9.999999999999999999999999999999999E+6144"),
        test("c7ffd34b9c1e28e56f3c127177823534", "-1.234567890123456789012345678901234E+6144"),
        test("c7ffd300000000000000000000000000", "-1.230000000000000000000000000000000E+6144"),
        test("c7ffc000000000000000000000000000", "-1.000000000000000000000000000000000E+6144"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(string2UInt128(t.input), t.enc), BigDecimal(t.result))
            XCTAssertEqual(BigDecimal(string2UInt128(t.input), t.enc).asString(), t.result)
        }
    }

}
