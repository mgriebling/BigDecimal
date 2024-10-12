//
//  TestDivision1.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 29/04/2021.
//

//
// Test cases from Java BigDecimal tests translated to Swift
//

import XCTest
@testable import BigDecimal
import BigInt

class TestDivision1: XCTestCase {

    override func setUpWithError() throws {
        //BigDecimal.nanFlag = false
    }

    func equals(_ x: BigDecimal, _ y: BigDecimal) -> Bool {
        return x.digits == y.digits && x.exponent == y.exponent
    }

    func testPowersOf2and5() {
        var powerOf2 = 1
        for _ in 0 ..< 6 {
            var powerOf5 = 1
            for _ in 0 ..< 6 {
                XCTAssertFalse(BigDecimal.one.divide(BigDecimal(powerOf2 * powerOf5)).isNaN)
                XCTAssertFalse((BigDecimal(powerOf2).divide(BigDecimal(powerOf5)).isNaN))
                XCTAssertFalse((BigDecimal(powerOf5).divide(BigDecimal(powerOf5)).isNaN))
                powerOf5 *= 5
            }
            powerOf2 *= 2
        }
        //XCTAssertFalse(BigDecimal.nanFlag)
    }
    
    func testNonTerminating() {
        let primes = [1, 3, 7, 13, 17]
        for i in 0 ..< primes.count {
            for j in 0 ..< primes.count {
                for m in 0 ..< primes.count {
                    for n in m + 1 ..< primes.count {
                        let dividend = primes[i] * primes[j]
                        let divisor = primes[m] * primes[n]
                        if (dividend / divisor) * divisor != dividend {
                            XCTAssertTrue(BigDecimal(dividend).divide(BigDecimal(divisor)).isNaN)
                            //XCTAssertTrue(BigDecimal.nanFlag)
                         }
                     }
                 }
            }
        }
    }

    func testProperScales() throws {
        let testCases : [[BigDecimal]] = [
            [BigDecimal("1"), BigDecimal("5"), BigDecimal("2e-1")],
            [BigDecimal("1"), BigDecimal("50e-1"), BigDecimal("2e-1")],
            [BigDecimal("10e-1"), BigDecimal("5"), BigDecimal("2e-1")],
            [BigDecimal("1"), BigDecimal("500e-2"), BigDecimal("2e-1")],
            [BigDecimal("100e-2"), BigDecimal("5"), BigDecimal("20e-2")],
            [BigDecimal("1"), BigDecimal("32"), BigDecimal("3125e-5")],
            [BigDecimal("1"), BigDecimal("64"), BigDecimal("15625e-6")],
            [BigDecimal("1.0000000"), BigDecimal("64"), BigDecimal("156250e-7")],
        ]
        for tc in testCases {
            let quotient = tc[0].divide(tc[1])
            if !equals(quotient, tc[2]) {
                XCTFail()
            }
        }
        //XCTAssertFalse(BigDecimal.nanFlag)
    }
    
    func testTralingZero() throws {
        let mc = Rounding(.towardZero, 3)
        let testCases = [
            [BigDecimal("19"), BigDecimal("100"), BigDecimal("0.19")],
            [BigDecimal("21"), BigDecimal("110"), BigDecimal("0.190")],
        ]
        for tc in testCases {
            XCTAssertTrue(tc[0].divide(tc[1], mc) == tc[2])
            XCTAssertTrue(equals(tc[0].divide(tc[1], mc), tc[2]))
        }
        //XCTAssertFalse(BigDecimal.nanFlag)
    }
    
    func testScaledRounded1() throws {
        let a = BigDecimal("31415")
        let a_minus = -a
        let b = BigDecimal("10000")
        let c = BigDecimal("31425")
        let c_minus = -c

        let testCases: [[BigDecimal]] = [
            [a,         b, BigDecimal("3.142")],
            [a_minus,   b, BigDecimal("-3.142")],
            [a,         b, BigDecimal("3.141")],
            [a_minus,   b, BigDecimal("-3.141")],
            [a,         b, BigDecimal("3.142")],
            [a_minus,   b, BigDecimal("-3.141")],
            [a,         b, BigDecimal("3.141")],
            [a_minus,   b, BigDecimal("-3.142")],
            [a,         b, BigDecimal("3.142")],
            [a_minus,   b, BigDecimal("-3.142")],
            [a,         b, BigDecimal("3.141")],
            [a_minus,   b, BigDecimal("-3.141")],
            [a,         b, BigDecimal("3.142")],
            [a_minus,   b, BigDecimal("-3.142")],
            [c,         b, BigDecimal("3.142")],
            [c_minus,   b, BigDecimal("-3.142")],
        ]
        let mode: [RoundingRule] = [
            .up, .up, .down, .down, .awayFromZero, .awayFromZero, .towardZero,
            .towardZero, .toNearestOrAwayFromZero, .toNearestOrAwayFromZero,
            .down, .down, .toNearestOrEven, .toNearestOrEven, .toNearestOrEven,
            .toNearestOrEven]
        for i in 0 ..< testCases.count {
            let test = testCases[i]
            let quo = test[0].divide(test[1], Rounding(mode[i], 4))
            if !equals(quo, test[2]) {
                XCTFail()
            }
        }
        //XCTAssertFalse(BigDecimal.nanFlag)
    }

    func testScaledRounded2() throws {
        let testCases: [[BigDecimal]] = [
            [ BigDecimal(3090), BigDecimal(7), BigDecimal(441) ],
            [ BigDecimal("309000000000000000000000"), BigDecimal("700000000000000000000"), BigDecimal(441) ],
            [ BigDecimal("962.430000000000"), BigDecimal("8346463.460000000000"), BigDecimal("0.000115309916") ],
            [ BigDecimal("18446744073709551631"), BigDecimal("4611686018427387909"), BigDecimal(4) ],
            [ BigDecimal("18446744073709551630"), BigDecimal("4611686018427387909"), BigDecimal(4) ],
            [ BigDecimal("23058430092136939523"), BigDecimal("4611686018427387905"), BigDecimal(5) ],
            [ BigDecimal("-18446744073709551661"), BigDecimal("-4611686018427387919"), BigDecimal(4) ],
            [ BigDecimal("-18446744073709551660"), BigDecimal("-4611686018427387919"), BigDecimal(4) ],
        ]
        let precision = [3, 3, 9, 1, 1, 1, 1, 1]
        for i in 0 ..< testCases.count {
            let test = testCases[i]
            let quo = test[0].divide(test[1], Rounding(.toNearestOrAwayFromZero, precision[i]))
            if !equals(quo, test[2]) {
                XCTFail()
            }
        }
        //XCTAssertFalse(BigDecimal.nanFlag)
    }

}
