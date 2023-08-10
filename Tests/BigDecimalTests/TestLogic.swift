//
//  TestLogic.swift
//  
//
//  Created by Mike Griebling on 18.07.2023.
//

import XCTest
@testable import BigDecimal

class TestLogic: XCTestCase {

    func doTest1(_ a: BigDecimal, _ b: BigDecimal, _ and: BigDecimal,
                 _ or: BigDecimal, _ xor: BigDecimal, _ nand: BigDecimal,
                 _ nor: BigDecimal, _ xnor: BigDecimal) {
        XCTAssertEqual(a & b, b & a)
        XCTAssertEqual(a & b, and)
        XCTAssertEqual(a | b, b | a)
        XCTAssertEqual(a | b, or)
        XCTAssertEqual(a ^ b, b ^ a)
        XCTAssertEqual(a ^ b, xor)
        XCTAssertEqual(BigDecimal.nand(a, b), nand)
        XCTAssertEqual(~BigDecimal.nand(a, b), and)
        XCTAssertEqual(BigDecimal.nor(a, b), nor)
        XCTAssertEqual(~BigDecimal.nor(a, b), or)
        XCTAssertEqual(BigDecimal.xnor(a, b), xnor)
        XCTAssertEqual(~BigDecimal.xnor(a, b), xor)
        XCTAssertEqual(~a, ~(~(~a)))
        XCTAssertEqual(~b, ~(~(~b)))
    }

    func test1() throws {
        doTest1(BigDecimal.one, BigDecimal(5), BigDecimal.one, BigDecimal(5),
                BigDecimal(4), BigDecimal(-2), BigDecimal(-6), BigDecimal(-5))
        doTest1(BigDecimal("56.7"), BigDecimal("89.13"), BigDecimal(24),
                BigDecimal(121), BigDecimal(97), BigDecimal(-25),
                BigDecimal(-122), BigDecimal(-98))
        
        let x = BigDecimal.setBit(1000, of: BigDecimal.zero)
        print(x)
    }
}
