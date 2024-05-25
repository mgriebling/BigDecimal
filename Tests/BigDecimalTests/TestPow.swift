//
//  TestPow.swift
//  BigDecimalTests
//
//  Created by PhiNM on 25/05/2024.
//

import XCTest

@testable import BigDecimal

class TestPow: XCTestCase {
  func testPow() throws {
    XCTAssertEqual(BigDecimal("5.5").pow(-3, .decimal128).asString(), "0.006010518407212622088655146506386176")
    XCTAssertEqual(BigDecimal(5.5).pow(-3, .decimal128).round(.decimal32).asString(), "0.006010518")
    XCTAssertEqual(BigDecimal.pow(BigDecimal("5.5"), BigDecimal("-3")).asString(), "0.006010518407212622088655146506386176")    
    XCTAssertEqual(BigDecimal("5.5").pow(3).asString(), "166.375")
    XCTAssertEqual(BigDecimal.pow(BigDecimal("5.5"), BigDecimal("3.2")).asString(), "233.9702323679928009901371156854989")
    XCTAssertEqual(BigDecimal.pow(BigDecimal("2"), BigDecimal("-4")).asString(), "0.0625")
  }
}
