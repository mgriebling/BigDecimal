//
//  TestRandom.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 16/05/2021.
//

import XCTest
@testable import BigDecimal
import BigInt

class TestRandom: XCTestCase {

    override func setUpWithError() throws {
        // FIXME: where to put nanFlag?
        // BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        // FIXME: where to put nanFlag?
        // XCTAssertFalse(BigDecimal.nanFlag)
    }

    func test1() throws {
        for _ in 0 ..< 50 {
            let sig = BInt(bitWidth: 100)
            for _ in 0 ..< 10 {
                let exponent = Int.random(in: -50...50)
                let x = BigDecimal(sig, exponent)
                let s1 = x.asString(.plain)
                let s2 = x.asString(.engineering)
                let s3 = x.asString(.scientific)
                XCTAssertEqual(x, BigDecimal(s1))
                XCTAssertEqual(x, BigDecimal(s2))
                XCTAssertEqual(x, BigDecimal(s3))
                let x1 = -x
                let s11 = x1.asString(.plain)
                let s21 = x1.asString(.engineering)
                let s31 = x1.asString(.scientific)
                XCTAssertEqual(x1, BigDecimal(s11))
                XCTAssertEqual(x1, BigDecimal(s21))
                XCTAssertEqual(x1, BigDecimal(s31))
            }
        }
    }


}
