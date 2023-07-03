//
//  TestEncode32.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 30/09/2022.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//
// dsEncode

import XCTest
@testable import BigDecimal

final class TestEncode32: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    static func U32(_ x: String) -> UInt32 {
        assert(x.count == 8)
        return UInt32(x, radix: 16)!
    }

    struct test {

        let dec: UInt32
        let x: String

        init(_ dec: UInt32, _ x: String) {
            self.dec = dec
            self.x = x
        }
    }

    let tests1: [test] = [
        test(U32("A23003D0"), "-7.50"),
        test(U32("A26003D0"), "-7.50E+3"),
        test(U32("A25003D0"), "-750"),
        test(U32("A24003D0"), "-75.0"),
        test(U32("A22003D0"), "-0.750"),
        test(U32("A21003D0"), "-0.0750"),
        test(U32("A1f003D0"), "-0.000750"),
        test(U32("A1d003D0"), "-0.00000750"),
        test(U32("A1c003D0"), "-7.50E-7"),
    ]

    func test1() {
        for t in tests1 {
            XCTAssertEqual(Decimal32(t.dec, .dpd).asBigDecimal().asString(), t.x)
            XCTAssertEqual(BigDecimal(t.dec).asString(), t.x)
        }
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    let tests2: [test] = [
        test(U32("2250006e"), "888"),
        test(U32("2250016e"), "888"),
        test(U32("2250026e"), "888"),
        test(U32("2250036e"), "888"),
        test(U32("2250006f"), "889"),
        test(U32("2250016f"), "889"),
        test(U32("2250026f"), "889"),
        test(U32("2250036f"), "889"),
    ]

    func test2() {
        for t in tests2 {
            XCTAssertEqual(Decimal32(t.dec, .dpd).asBigDecimal().asString(), t.x)
        }
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    let tests3: [test] = [
        test(U32("78000000"), ""),
        test(U32("79000000"), ""),
        test(U32("7a000000"), ""),
        test(U32("7b000000"), ""),
        test(U32("7c000000"), ""),
        test(U32("7d000000"), ""),
        test(U32("7e000000"), ""),
        test(U32("7f000000"), ""),
    ]

    func test3() {
        for t in tests3 {
            let b = Decimal32(t.dec, .dpd)
            let bd = b.asBigDecimal()
            XCTAssertTrue(bd.isInfinite || bd.isNaN)
        }
        XCTAssertTrue(Decimal32(BigDecimal.nan).asBigDecimal().isNaN)
        XCTAssertTrue(BigDecimal.nanFlag)
    }

}
