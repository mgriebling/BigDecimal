//
//  TestEncode64.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 30/09/2022.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//
// ddEncode

import XCTest
@testable import BigDecimal

final class TestEncode64: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    static func U64(_ x: String) -> UInt64 {
        assert(x.count == 16)
        return UInt64(x, radix: 16)!
    }

    struct test {

        let dec: UInt64
        let x: String

        init(_ dec: UInt64, _ x: String) {
            self.dec = dec
            self.x = x
        }
    }

    let tests1: [test] = [
        test(U64("A2300000000003D0"), "-7.50"),
        test(U64("A23c0000000003D0"), "-7.50E+3"),
        test(U64("A2380000000003D0"), "-750"),
        test(U64("A2340000000003D0"), "-75.0"),
        test(U64("A22C0000000003D0"), "-0.750"),
        test(U64("A2280000000003D0"), "-0.0750"),
        test(U64("A2200000000003D0"), "-0.000750"),
        test(U64("A2180000000003D0"), "-0.00000750"),
        test(U64("A2140000000003D0"), "-7.50E-7"),
    ]

    func test1() {
        for t in tests1 {
            XCTAssertEqual(Decimal64(t.dec,.dpd).asBigDecimal().asString(),t.x)
            XCTAssertEqual(Decimal64(BigDecimal(t.x)).asUInt64(.dpd), t.dec)
        }
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    let tests2: [test] = [
        test(U64("223800000000006e"), "888"),
        test(U64("223800000000016e"), "888"),
        test(U64("223800000000026e"), "888"),
        test(U64("223800000000036e"), "888"),
        test(U64("223800000000006f"), "889"),
        test(U64("223800000000016f"), "889"),
        test(U64("223800000000026f"), "889"),
        test(U64("223800000000036f"), "889"),
    ]

    func test2() {
        for t in tests2 {
            XCTAssertEqual(Decimal64(t.dec, .dpd).asBigDecimal().asString(), t.x)
        }
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    let tests3: [test] = [
        test(U64("7800000000000000"), ""),
        test(U64("7900000000000000"), ""),
        test(U64("7a00000000000000"), ""),
        test(U64("7b00000000000000"), ""),
        test(U64("7c00000000000000"), ""),
        test(U64("7d00000000000000"), ""),
        test(U64("7e00000000000000"), ""),
        test(U64("7f00000000000000"), ""),
    ]

    func test3() {
        for t in tests3 {
            let bd = Decimal64(t.dec, .dpd).asBigDecimal()
            XCTAssertTrue(bd.isInfinite || bd.isNaN)
        }
        XCTAssertTrue(Decimal64(BigDecimal.nan).asBigDecimal().isNaN)
        XCTAssertTrue(BigDecimal.nanFlag)
    }

}
