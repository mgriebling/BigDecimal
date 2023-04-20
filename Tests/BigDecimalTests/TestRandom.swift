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
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func test1() throws {
        for _ in 0 ..< 50 {
            let sig = BInt(bitWidth: 100)
            for _ in 0 ..< 10 {
                let exponent = Int.random(in: -50...50)
                let x = BigDecimal(sig, exponent)
                let s1 = x.asString(.PLAIN)
                let s2 = x.asString(.ENGINEERING)
                let s3 = x.asString(.SCIENTIFIC)
                XCTAssertEqual(x, BigDecimal(s1))
                XCTAssertEqual(x, BigDecimal(s2))
                XCTAssertEqual(x, BigDecimal(s3))
                let x1 = -x
                let s11 = x1.asString(.PLAIN)
                let s21 = x1.asString(.ENGINEERING)
                let s31 = x1.asString(.SCIENTIFIC)
                XCTAssertEqual(x1, BigDecimal(s11))
                XCTAssertEqual(x1, BigDecimal(s21))
                XCTAssertEqual(x1, BigDecimal(s31))
            }
        }
    }


}
