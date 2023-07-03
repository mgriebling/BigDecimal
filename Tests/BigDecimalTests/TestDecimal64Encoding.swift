//
//  TestDecimal64Encoding.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 02/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestDecimal64Encoding: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    struct test {

        let input: UInt64
        let result: String
        let enc: BigDecimal.Encoding

        init(_ input: UInt64, _ result: String, _ enc: BigDecimal.Encoding = .dpd) {
            self.input = input
            self.result = result
            self.enc = enc
        }
    }
    
    let tests1: [test] = [
        test(0xA2300000000003D0, "-7.50"),
        test(0xA23c0000000003D0, "-7.50E+3"),
        test(0xA2380000000003D0, "-750"),
        test(0xA2340000000003D0, "-75.0"),
        test(0xA22c0000000003D0, "-0.750"),
        test(0xA2280000000003D0, "-0.0750"),
        test(0xA2200000000003D0, "-0.000750"),
        test(0xA2180000000003D0, "-0.00000750"),
        test(0xA2140000000003D0, "-7.50E-7"),
        test(0x263934b9c1e28e56, "1234567890123456"),
        test(0xa63934b9c1e28e56, "-1234567890123456"),
        test(0x260934b9c1e28e56, "1234.567890123456"),
        test(0x2638912449124491, "1111111111111111"),
        test(0x6e38ff3fcff3fcff, "9999999999999999"),
        test(0x77fcff3fcff3fcff, "9.999999999999999E+384"),
        test(0x47fd34b9c1e28e56, "1.234567890123456E+384"),
        test(0x47fd300000000000, "1.230000000000000E+384"),
        test(0x47fc000000000000, "1.000000000000000E+384"),
        test(0x22380000000049c5, "12345"),
        test(0x2238000000000534, "1234"),
        test(0x22380000000000a3, "123"),
        test(0x2238000000000012, "12"),
        test(0x2238000000000001, "1"),
        test(0x22300000000000a3, "1.23"),
        test(0x22300000000049c5, "123.45"),
        test(0x003c000000000001, "1E-383"),
        test(0x0400000000000000, "1.000000000000000E-383"),
        test(0x0400000000000001, "1.000000000000001E-383"),
        test(0x0000800000000000, "1.00000000000000E-384"),
        test(0x0000000000000010, "1.0E-397"),
        test(0x0004000000000001, "1E-397"),
        test(0x0000000000000001, "1E-398"),
        test(0x6400ff3fcff3fcff, "9.999999999999999E-383"),
        test(0x0400912449124491, "1.111111111111111E-383"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.input, t.enc), BigDecimal(t.result))
            XCTAssertEqual(BigDecimal(t.input, t.enc).asString(), t.result)
        }
    }
    
}
