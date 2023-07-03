//
//  TestMovePoint.swift
//  BigDecimalTestTests
//
//  Created by Leif Ibsen on 24/10/2022.
//

import XCTest
@testable import BigDecimal
import BigInt

final class TestScale: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.nanFlag = false
    }

    struct test {

        let x: String
        let n: Int
        let result: String

        init(_ x: String, _ n: Int, _ result: String) {
            self.x = x
            self.n = n
            self.result = result
        }
    }

    let tests1: [test] = [
        test("7.50", 10, "7.50E+10"),
        test("7.50", 3, "7.50E+3"),
        test("7.50", 2, "750"),
        test("7.50", 1, "75.0"),
        test("7.50", 0, "7.50"),
        test("7.50", -1, "0.750"),
        test("7.50", -2, "0.0750"),
        test("7.50", -10, "7.50E-10"),
        test("-7.50", 3, "-7.50E+3"),
        test("-7.50", 2, "-750"),
        test("-7.50", 1, "-75.0"),
        test("-7.50", 0, "-7.50"),
        test("-7.50", -1, "-0.750"),

        test("7", -2, "0.07"),
        test("-7", -2, "-0.07"),
        test("75", -2, "0.75"),
        test("-75", -2, "-0.75"),
        test("7.50", -2, "0.0750"),
        test("-7.50", -2, "-0.0750"),
        test("7.500", -2, "0.07500"),
        test("-7.500", -2, "-0.07500"),
        test("7", -1, "0.7"),
        test("-7", -1, "-0.7"),
        test("75", -1, "7.5"),
        test("-75", -1, "-7.5"),
        test("7.50", -1, "0.750"),
        test("-7.50", -1, "-0.750"),
        test("7.500", -1, "0.7500"),
        test("-7.500", -1, "-0.7500"),
        test("7", 0, "7"),
        test("-7", 0, "-7"),
        test("75", 0, "75"),
        test("-75", 0, "-75"),
        test("7.50", 0, "7.50"),
        test("-7.50", 0, "-7.50"),
        test("7.500", 0, "7.500"),
        test("-7.500", 0, "-7.500"),
        test("7", 1, "7E+1"),
        test("-7", 1, "-7E+1"),
        test("75", 1, "7.5E+2"),
        test("-75", 1, "-7.5E+2"),
        test("7.50", 1, "75.0"),
        test("-7.50", 1, "-75.0"),
        test("7.500", 1, "75.00"),
        test("-7.500", 1, "-75.00"),
        test("7", 2, "7E+2"),
        test("-7", 2, "-7E+2"),
        test("75", 2, "7.5E+3"),
        test("-75", 2, "-7.5E+3"),
        test("7.50", 2, "750"),
        test("-7.50", 2, "-750"),
        test("7.500", 2, "750.0"),
        test("-7.500", 2, "-750.0"),
        
        test("0", 1, "0E+1"),
        test("-0", 2, "0E+2"),
        test("0E+4", 3, "0E+7"),
        test("-0E+4", 4, "0E+8"),
        test("0.0000", 5, "0E+1"),
        test("-0.0000", 6, "0E+2"),
        test("0E-141", 7, "0E-134"),
        test("-0E-141", 8, "0E-133"),

        test("1E-999999999", 999999999, "1"),
        test("-1E-999999999", 999999999, "-1"),
        test("+Infinity", 1, "+Infinity"),
        test("-Infinity", 2, "-Infinity"),
        test("+Infinity", -1, "+Infinity"),
        test("-Infinity", -2, "-Infinity"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.x).scale(t.n).asString(), t.result)
        }
    }

}
