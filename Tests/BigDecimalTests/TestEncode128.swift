//
//  TestEncode128.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 30/09/2022.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//
// dqEncode

import XCTest
@testable import BigDecimal
// import UInt128

final class TestEncode128: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    static func U128(_ x: String) -> UInt128 {
        assert(x.count == 32)
        let mid = x.index(x.startIndex, offsetBy: 16)
        return UInt128(_low: UInt64(x[mid ..< x.endIndex], radix: 16)!,
                       _high: UInt64(x[x.startIndex ..< mid], radix: 16)!)
    }

    struct test {

        let dec: UInt128
        let x: String

        init(_ dec: UInt128, _ x: String) {
            self.dec = dec
            self.x = x
        }
    }

    let tests1: [test] = [
        test(U128("A20780000000000000000000000003D0"), "-7.50"),
        test(U128("A20840000000000000000000000003D0"), "-7.50E+3"),
        test(U128("A20800000000000000000000000003D0"), "-750"),
        test(U128("A207c0000000000000000000000003D0"), "-75.0"),
        test(U128("A20740000000000000000000000003D0"), "-0.750"),
        test(U128("A20700000000000000000000000003D0"), "-0.0750"),
        test(U128("A20680000000000000000000000003D0"), "-0.000750"),
        test(U128("A20600000000000000000000000003D0"), "-0.00000750"),
        test(U128("A205c0000000000000000000000003D0"), "-7.50E-7"),
    ]

    func test1() {
        for t in tests1 {
            XCTAssertEqual(Decimal128(t.dec, .dpd).asBigDecimal().asString(), t.x)
            XCTAssertEqual(Decimal128(BigDecimal(t.x)).asUInt128(.dpd)._high,
                           t.dec._high)
            XCTAssertEqual(Decimal128(BigDecimal(t.x)).asUInt128(.dpd)._low,
                           t.dec._low)
        }
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    let tests2: [test] = [
        test(U128("2208000000000000000000000000006e"), "888"),
        test(U128("2208000000000000000000000000016e"), "888"),
        test(U128("2208000000000000000000000000026e"), "888"),
        test(U128("2208000000000000000000000000036e"), "888"),
        test(U128("2208000000000000000000000000006f"), "889"),
        test(U128("2208000000000000000000000000016f"), "889"),
        test(U128("2208000000000000000000000000026f"), "889"),
        test(U128("2208000000000000000000000000036f"), "889"),
    ]

    func test2() {
        for t in tests2 {
            XCTAssertEqual(Decimal128(t.dec, .dpd).asBigDecimal().asString(), t.x)
        }
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    let tests3: [test] = [
        test(U128("78000000000000000000000000000000"), ""),
        test(U128("79000000000000000000000000000000"), ""),
        test(U128("7a000000000000000000000000000000"), ""),
        test(U128("7b000000000000000000000000000000"), ""),
        test(U128("7c000000000000000000000000000000"), ""),
        test(U128("7d000000000000000000000000000000"), ""),
        test(U128("7e000000000000000000000000000000"), ""),
        test(U128("7f000000000000000000000000000000"), ""),
    ]

    func test3() {
        for t in tests3 {
            let bd = Decimal128(t.dec, .dpd).asBigDecimal()
            XCTAssertTrue(bd.isInfinite || bd.isNaN)
        }
        XCTAssertTrue(Decimal128(BigDecimal.nan).asBigDecimal().isNaN)
        XCTAssertTrue(BigDecimal.nanFlag)
    }

}
