//
//  TestCompare.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 04/10/2022.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestCompare: XCTestCase {

    override func setUpWithError() throws {
       BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
       XCTAssertFalse(BigDecimal.nanFlag)
    }

    struct test {

        let x: String
        let y: String
        let result: Int

        init(_ x: String, _ y: String, _ result: Int){
            self.x = x
            self.y = y
            self.result = result
        }
    }

    let tests1: [test] = [
        test("9.99999999E+999999999", "9.99999999E+999999999", 0),
        test("-9.99999999E+999999999", "9.99999999E+999999999", -1),
        test("9.99999999E+999999999", "-9.99999999E+999999999", 1),
        test("-9.99999999E+999999999", "-9.99999999E+999999999", 0),
        test("1.0", "0.1", 1),
        test("0.1", "1.0", -1),
        test("10.0", "0.1", 1),
        test("0.1", "10.0", -1),
        test("100", "1.0", 1),
        test("1.0", "100", -1),
        test("1000", "10.0", 1),
        test("10.0", "1000", -1),
        test("10000", "100.0", 1),
        test("100.0", "10000", -1),
        test("100000", "1000.0", 1),
        test("1000.0", "100000", -1),
        test("1000000", "10000.0", 1),
        test("10000.0", "1000000", -1),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), t.result)
        }
    }

    let tests2: [test] = [
        test("7.0" ,"7.0", 0),
        test("7.0" ,"7", 0),
        test("7" ,"7.0", 0),
        test("7E+0" ,"7.0", 0),
        test("70E-1" ,"7.0", 0),
        test("0.7E+1" ,"7", 0),
        test("70E-1" ,"7", 0),
        test("7.0" ,"7E+0", 0),
        test("7.0" ,"70E-1", 0),
        test("7" ,"0.7E+1", 0),
        test("7" ,"70E-1", 0),
        test("8.0" ,"7.0", 1),
        test("8.0" ,"7", 1),
        test("8" ,"7.0", 1),
        test("8E+0" ,"7.0", 1),
        test("80E-1" ,"7.0", 1),
        test("0.8E+1" ,"7", 1),
        test("80E-1" ,"7", 1),
        test("8.0" ,"7E+0", 1),
        test("8.0" ,"70E-1", 1),
        test("8" ,"0.7E+1", 1),
        test("8" ,"70E-1", 1),
        test("8.0" ,"9.0", -1),
        test("8.0" ,"9", -1),
        test("8" ,"9.0", -1),
        test("8E+0" ,"9.0", -1),
        test("80E-1" ,"9.0", -1),
        test("0.8E+1" ,"9", -1),
        test("80E-1" ,"9", -1),
        test("8.0" ,"9E+0", -1),
        test("8.0" ,"90E-1", -1),
        test("8" ,"0.9E+1", -1),
        test("8" ,"90E-1", -1),
    ]

    func test2() throws {
        for t in tests2 {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), t.result)
            XCTAssertEqual((-BigDecimal(t.x)).compare(BigDecimal(t.y)), -1)
            XCTAssertEqual(BigDecimal(t.x).compare(-BigDecimal(t.y)), 1)
            XCTAssertEqual((-BigDecimal(t.x)).compare(-BigDecimal(t.y)), -t.result)
        }
    }

    let tests3: [test] = [
        test("123.4560000000000000E789", "123.456E789", 0),
        test("123.456000000000000E-89", "123.456E-89", 0),
        test("123.45600000000000E789", "123.456E789", 0),
        test("123.4560000000000E-89", "123.456E-89", 0),
        test("123.456000000000E789", "123.456E789", 0),
        test("123.45600000000E-89", "123.456E-89", 0),
        test("123.4560000000E789", "123.456E789", 0),
        test("123.456000000E-89", "123.456E-89", 0),
        test("123.45600000E789", "123.456E789", 0),
        test("123.4560000E-89", "123.456E-89", 0),
        test("123.456000E789", "123.456E789", 0),
        test("123.45600E-89", "123.456E-89", 0),
        test("123.4560E789", "123.456E789", 0),
        test("123.456E-89", "123.456E-89", 0),
        test("123.456E-89", "123.4560000000000000E-89", 0),
        test("123.456E789", "123.456000000000000E789", 0),
        test("123.456E-89", "123.45600000000000E-89", 0),
        test("123.456E789", "123.4560000000000E789", 0),
        test("123.456E-89", "123.456000000000E-89", 0),
        test("123.456E789", "123.45600000000E789", 0),
        test("123.456E-89", "123.4560000000E-89", 0),
        test("123.456E789", "123.456000000E789", 0),
        test("123.456E-89", "123.45600000E-89", 0),
        test("123.456E789", "123.4560000E789", 0),
        test("123.456E-89", "123.456000E-89", 0),
        test("123.456E789", "123.45600E789", 0),
        test("123.456E-89", "123.4560E-89", 0),
        test("123.456E789", "123.456E789", 0),
    ]

    func test3() throws {
        for t in tests3 {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), t.result)
        }
    }
    
    let tests4: [test] = [
        test("1", "1E-15", 1),
        test("1", "1E-14", 1),
        test("1", "1E-13", 1),
        test("1", "1E-12", 1),
        test("1", "1E-11", 1),
        test("1", "1E-10", 1),
        test("1", "1E-9", 1),
        test("1", "1E-8", 1),
        test("1", "1E-7", 1),
        test("1", "1E-6", 1),
        test("1", "1E-5", 1),
        test("1", "1E-4", 1),
        test("1", "1E-3", 1),
        test("1", "1E-2", 1),
        test("1", "1E-1", 1),
        test("1", "1E-0", 0),
        test("1", "1E+1", -1),
        test("1", "1E+2", -1),
        test("1", "1E+3", -1),
        test("1", "1E+4", -1),
        test("1", "1E+5", -1),
        test("1", "1E+6", -1),
        test("1", "1E+7", -1),
        test("1", "1E+8", -1),
        test("1", "1E+9", -1),
        test("1", "1E+10", -1),
        test("1", "1E+11", -1),
        test("1", "1E+12", -1),
        test("1", "1E+13", -1),
        test("1", "1E+14", -1),
        test("1", "1E+15", -1),
    ]

    func test4() throws {
        for t in tests4 {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), t.result)
            XCTAssertEqual(BigDecimal(t.y).compare(BigDecimal(t.x)), -t.result)
        }
    }
    
    let tests5: [test] = [
        test("0.000000987654321", "1E-15", 1),
        test("0.000000987654321", "1E-14", 1),
        test("0.000000987654321", "1E-13", 1),
        test("0.000000987654321", "1E-12", 1),
        test("0.000000987654321", "1E-11", 1),
        test("0.000000987654321", "1E-10", 1),
        test("0.000000987654321", "1E-9", 1),
        test("0.000000987654321", "1E-8", 1),
        test("0.000000987654321", "1E-7", 1),
        test("0.000000987654321", "1E-6", -1),
        test("0.000000987654321", "1E-5", -1),
        test("0.000000987654321", "1E-4", -1),
        test("0.000000987654321", "1E-3", -1),
        test("0.000000987654321", "1E-2", -1),
        test("0.000000987654321", "1E-1", -1),
        test("0.000000987654321", "1E-0", -1),
        test("0.000000987654321", "1E+1", -1),
        test("0.000000987654321", "1E+2", -1),
        test("0.000000987654321", "1E+3", -1),
        test("0.000000987654321", "1E+4", -1),
    ]

    func test5() throws {
        for t in tests5 {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), t.result)
        }
    }

    let tests6: [test] = [
        test("1", "0.9999999", 1),
        test("1", "1.0000", 0),
        test("1", "1.00001", -1),
        test("1", "1.000001", -1),
        test("1", "1.0000001", -1),
        test("0.9999999", "1", -1),
        test("0.999999", "1", -1),
        test("0.99999", "1", -1),
        test("1.0000", "1", 0),
        test("1.00001", "1", 1),
        test("1.000001", "1", 1),
        test("1.0000001", "1", 1),
    ]

    func test6() throws {
        for t in tests6 {
            XCTAssertEqual(BigDecimal(t.x).compare(BigDecimal(t.y)), t.result)
        }
    }

    func test7() throws {
        let x = BigDecimal("1")
        let y = BigDecimal("2")
        XCTAssertFalse(x == y)
        XCTAssertTrue(x != y)
        XCTAssertTrue(x < y)
        XCTAssertTrue(x <= y)
        XCTAssertFalse(x > y)
        XCTAssertFalse(x >= y)
        
        XCTAssertFalse(-x == y)
        XCTAssertTrue(-x != y)
        XCTAssertTrue(-x < y)
        XCTAssertTrue(-x <= y)
        XCTAssertFalse(-x > y)
        XCTAssertFalse(-x >= y)

        XCTAssertFalse(x == -y)
        XCTAssertTrue(x != -y)
        XCTAssertFalse(x < -y)
        XCTAssertFalse(x <= -y)
        XCTAssertTrue(x > -y)
        XCTAssertTrue(x >= -y)
        
        XCTAssertFalse(-x == -y)
        XCTAssertTrue(-x != -y)
        XCTAssertFalse(-x < -y)
        XCTAssertFalse(-x <= -y)
        XCTAssertTrue(-x > -y)
        XCTAssertTrue(-x >= -y)
    }
    
    func test8() throws {
        let x = BigDecimal("1")
        let y = BigDecimal("2")
        XCTAssertFalse(x.isEqual(to: y))
        XCTAssertTrue(x.isLess(than: y))
        XCTAssertTrue(x.isLessThanOrEqualTo(y))
        
        XCTAssertFalse((-x).isEqual(to: y))
        XCTAssertTrue((-x).isLess(than: y))
        XCTAssertTrue((-x).isLessThanOrEqualTo(y))

        XCTAssertFalse(x.isEqual(to: -y))
        XCTAssertFalse(x.isLess(than: -y))
        XCTAssertFalse(x.isLessThanOrEqualTo(-y))
        
        XCTAssertFalse((-x).isEqual(to: -y))
        XCTAssertFalse((-x).isLess(than: -y))
        XCTAssertFalse((-x).isLessThanOrEqualTo(-y))
        
        XCTAssertFalse(x.isNaN)
        XCTAssertFalse(x.isZero)
        XCTAssertTrue(x.isPositive)
        XCTAssertTrue(x.isFinite)
        XCTAssertTrue(x.isNormal)
        XCTAssertTrue(x.isCanonical)
    }
}
