//
//  TestSubtraction.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 06/05/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestSubtraction: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.nanFlag)
    }

    struct test {

        let x: String
        let y: String
        let result: String

        init(_ x: String, _ y: String, _ result: String) {
            self.x = x
            self.y = y
            self.result = result
        }
    }

    let tests1: [test] = [
        test("10.23456784", "10.23456789", "-5E-8"),
        test("10.23456785", "10.23456789", "-4E-8"),
        test("10.23456786", "10.23456789", "-3E-8"),
        test("10.23456787", "10.23456789", "-2E-8"),
        test("10.23456788", "10.23456789", "-1E-8"),
        test("10.23456789", "10.23456789", "0E-8"),
        test("10.23456790", "10.23456789", "1E-8"),
        test("10.23456791", "10.23456789", "2E-8"),
        test("10.23456792", "10.23456789", "3E-8"),
        test("10.23456793", "10.23456789", "4E-8"),
        test("10.23456794", "10.23456789", "5E-8"),
        test("10.23456781", "10.23456786", "-5E-8"),
        test("10.23456782", "10.23456786", "-4E-8"),
        test("10.23456783", "10.23456786", "-3E-8"),
        test("10.23456784", "10.23456786", "-2E-8"),
        test("10.23456785", "10.23456786", "-1E-8"),
        test("10.23456786", "10.23456786", "0E-8"),
        test("10.23456787", "10.23456786", "1E-8"),
        test("10.23456788", "10.23456786", "2E-8"),
        test("10.23456789", "10.23456786", "3E-8"),
        test("10.23456790", "10.23456786", "4E-8"),
        test("10.23456791", "10.23456786", "5E-8"),
        test("1", "0.999999999", "1E-9"),
        test("0.999999999", "1", "-1E-9"),
        test("-10.23456780", "-10.23456786", "6E-8"),
        test("-10.23456790", "-10.23456786", "-4E-8"),
        test("-10.23456791", "-10.23456786", "-5E-8"),
        test("0", ".1", "-0.1"),
        test("00", ".97983", "-0.97983"),
        test("0", ".9", "-0.9"),
        test("0", "0.102", "-0.102"),
        test("0", ".4", "-0.4"),
        test("0", ".307", "-0.307"),
        test("0", ".43822", "-0.43822"),
        test("0", ".911", "-0.911"),
        test(".0", ".02", "-0.02"),
        test("00", ".392", "-0.392"),
        test("0", ".26", "-0.26"),
        test("0", "0.51", "-0.51"),
        test("0", ".2234", "-0.2234"),
        test("0", ".2", "-0.2"),
        test(".0", ".0008", "-0.0008"),
        test("0.0", "-.1", "0.1"),
        test("0.00", "-.97983", "0.97983"),
        test("0.0", "-.9", "0.9"),
        test("0.0", "-0.102", "0.102"),
        test("0.0", "-.4", "0.4"),
        test("0.0", "-.307", "0.307"),
        test("0.0", "-.43822", "0.43822"),
        test("0.0", "-.911", "0.911"),
        test("0.0", "-.02", "0.02"),
        test("0.00", "-.392", "0.392"),
        test("0.0", "-.26", "0.26"),
        test("0.0", "-0.51", "0.51"),
        test("0.0", "-.2234", "0.2234"),
        test("0.0", "-.2", "0.2"),
        test("0.0", "-.0008", "0.0008"),
        test("0", "-.1", "0.1"),
        test("00", "-.97983", "0.97983"),
        test("0", "-.9", "0.9"),
        test("0", "-0.102", "0.102"),
        test("0", "-.4", "0.4"),
        test("0", "-.307", "0.307"),
        test("0", "-.43822", "0.43822"),
        test("0", "-.911", "0.911"),
        test(".0", "-.02", "0.02"),
        test("00", "-.392", "0.392"),
        test("0", "-.26", "0.26"),
        test("0", "-0.51", "0.51"),
        test("0", "-.2234", "0.2234"),
        test("0", "-.2", "0.2"),
        test(".0", "-.0008", "0.0008"),
    ]
    
    func test1() throws {
        for t in tests1 {
            XCTAssertEqual((BigDecimal(t.x) - BigDecimal(t.y)).asString(), t.result)
        }
    }

    let tests2: [test] = [
        test("-103519362", "-51897955.3", "-51621406.7"),
        test("159579.444", "89827.5229", "69751.9211"),
        test("333.0000000123456", "33.00000001234566", "299.9999999999999"),
        test("333.0000000123456", "33.00000001234565", "300.0000000000000"),
        test("133.0000000123456", "33.00000001234565", "99.99999999999995"),
        test("133.0000000123456", "33.00000001234564", "99.99999999999996"),
        test("133.0000000123456", "33.00000001234540", "100.0000000000002"),
        test("133.0000000123456", "43.00000001234560", "90.00000000000000"),
        test("133.0000000123456", "43.00000001234561", "89.99999999999999"),
        test("133.0000000123456", "43.00000001234566", "89.99999999999994"),
        test("101.0000000123456", "91.00000001234566",  "9.99999999999994"),
        test("101.0000000123456", "99.00000001234566",  "1.99999999999994"),
    ]

    func test2() throws {
        let rnd = Rounding(.toNearestOrEven, 16)
        for t in tests2 {
            XCTAssertEqual(rnd.round(BigDecimal(t.x) - BigDecimal(t.y)).asString(), t.result)
            XCTAssertEqual(BigDecimal(t.x).subtract(BigDecimal(t.y), rnd).asString(), t.result)
        }
    }

}
