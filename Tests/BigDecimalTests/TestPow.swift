//
//  TestPow.swift
//  BigDecimalTests
//
//  Created by PhiNM on 25/05/2024.
//

import XCTest

@testable import BigDecimal

class TestPow: XCTestCase {
    let a55 = BigDecimal("5.5")
    
    func testPow() throws {
        XCTAssertEqual(a55.pow(-3, .decimal128).asString(), "0.006010518407212622088655146506386176")
        XCTAssertEqual(BigDecimal(5.5).pow(-3, .decimal128).round(.decimal32).asString(), "0.006010518")
        XCTAssertEqual(BigDecimal.pow(a55, BigDecimal("-3")).asString(), "0.006010518407212622088655146506386176")
        XCTAssertEqual(a55.pow(3).asString(), "166.375")
        XCTAssertEqual(BigDecimal.pow(a55, BigDecimal("3.2")).asString(), "233.9702323679928009901371156854989")
        XCTAssertEqual(BigDecimal.pow(BigDecimal("2"), BigDecimal("-4")).asString(), "0.0625")
    }
    
    func testExp() throws {
        XCTAssertEqual(BigDecimal.exp(a55).asString(), "244.6919322642203879151889495118394")
        XCTAssertEqual(BigDecimal.expMinusOne(a55).asString(), "243.6919322642203879151889495118394")
        XCTAssertEqual(BigDecimal.exp2(a55).asString(), "45.25483399593904156165403917471034")
    }
}
