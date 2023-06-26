//
//  TestDecimal.swift
//  BigDecimalTestTests
//
//  Created by Leif Ibsen on 11/11/2022.
//

import XCTest
@testable import BigDecimal
import BigInt

final class TestDecimal: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    func testBasic() throws {
        let d0 = Decimal(0.0)
        let x0 = BigDecimal(d0)
        XCTAssertTrue(x0.isZero)
        let d1 = Decimal(1.0)
        let x1 = BigDecimal(d1)
        XCTAssertEqual(x1, BigDecimal.one)
        let dm1 = Decimal(-1.0)
        let xm1 = BigDecimal(dm1)
        XCTAssertEqual(xm1, -BigDecimal.one)
        let d10 = Decimal(10.0)
        let x10 = BigDecimal(d10)
        XCTAssertEqual(x10, BigDecimal.ten)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testMax() throws {
        let xx = UInt16(0xffff)
        let max = Decimal(_exponent: 127, _length: 8, _isNegative: 0, _isCompact: 0, _reserved: 0, _mantissa: (xx,xx,xx,xx,xx,xx,xx,xx))

        let x = BigDecimal(max)
        XCTAssertEqual(x.exponent, 127)
        XCTAssertEqual(x.significand, BInt([0xffffffffffffffff, 0xffffffffffffffff]))
        XCTAssertEqual(max, x.asDecimal())

        let d = (x + 1).asDecimal()
        XCTAssertEqual(d, Decimal.nan)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testMin() throws {
        let min = Decimal(_exponent: -128, _length: 1, _isNegative: 0, _isCompact: 0, _reserved: 0, _mantissa: (1, 0, 0, 0, 0, 0, 0, 0))
        XCTAssertTrue(min > 0.0)
        let x = BigDecimal(min)
        XCTAssertEqual(x.exponent, -128)
        XCTAssertEqual(x.significand, BInt.one)
        XCTAssertEqual(min, x.asDecimal())

        let d = BigDecimal(BInt.one, -129).asDecimal()
        XCTAssertEqual(d, 0.0)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testNaN() throws {
        let d = Decimal.nan
        let x = BigDecimal(d)
        XCTAssertTrue(x.isNaN)
        let d1 = BigDecimal.nan.asDecimal()
        XCTAssertEqual(d1, Decimal.nan)
        XCTAssertTrue(BigDecimal.NaNFlag)
    }

    func test1() throws {
        for _ in 0 ..< 100 {
            let x = BInt(1000000).randomLessThan()
            for i in -10 ... 10 {
                let b1 = BigDecimal(x, i * 10)
                let b2 = BigDecimal(-x, i * 10)
                XCTAssertEqual(b1, BigDecimal(b1.asDecimal()))
                XCTAssertEqual(b2, BigDecimal(b2.asDecimal()))
            }
        }
    }
}
