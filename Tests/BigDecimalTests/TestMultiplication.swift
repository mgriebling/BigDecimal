//
//  TestMultiplication.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 06/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestMultiplication: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }
    
    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    let result1: [String] = [
        "1E+5",
        "1.5E+5",
        "1.45E+5",
        "1.454E+5",
        "1.4543E+5",
        "145433",
        "145433.3",
        "145433.29",
        "145433.291",
        "145433.2908",
        "145433.29080",
        "145433.290801",
        "145433.2908012",
        "145433.29080119",
        "145433.290801193",
        "145433.2908011934",
        "145433.29080119337",
        "145433.290801193370",
        "145433.2908011933697",
        "145433.29080119336967",
        "145433.290801193369672",
        "145433.2908011933696719",
        "145433.29080119336967192",
        "145433.290801193369671917",
        "145433.2908011933696719165",
        "145433.29080119336967191651",
        "145433.290801193369671916512",
        "145433.2908011933696719165120",
        "145433.29080119336967191651199",
        "145433.290801193369671916511993",
        "145433.2908011933696719165119928",
        "145433.29080119336967191651199283",
        "145433.290801193369671916511992830",
    ]

    let result2: [String] = [
        "1.2345E+9",
        "1.2345E+10",
        "1.2345E+11",
        "1.2345E+12",
        "1.2345E+13",
        "1.2345E+14",
        "1.2345E+15",
    ]
    
    let mul2: [String] = [
        "1E+7",
        "1E+8",
        "1E+9",
        "1E+10",
        "1E+11",
        "1E+12",
        "1E+13",
    ]

    func test1() throws {
        let x1 = BigDecimal("30269.587755640502150977251770554")
        let x2 = BigDecimal("4.8046009735990873395936309640543")
        for i in 0 ..< result1.count {
            let rnd = Rounding(.HALF_UP, i + 1)
            XCTAssertEqual(rnd.round(x1 * x2).asString(), result1[i])
            XCTAssertEqual(x1.multiply(x2, rnd).asString(), result1[i])
        }
    }

    func test2() throws {
        let x1 = BigDecimal("123.45")
        for i in 0 ..< result2.count {
            XCTAssertEqual((x1 * BigDecimal(mul2[i])).asString(), result2[i])
        }
    }

}
