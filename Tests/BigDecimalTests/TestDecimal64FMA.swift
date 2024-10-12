//
//  TestDecimal64FMA.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 10/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest
@testable import BigDecimal

class TestDecimal64FMA: XCTestCase {

    override func setUpWithError() throws {
        // FIXME: where to put nanFlag?
        // BigDecimal.nanFlag = false
    }

    override func tearDownWithError() throws {
        // FIXME: where to put nanFlag?
        // XCTAssertFalse(BigDecimal.nanFlag)
    }

    struct testa {

        let a: String
        let b: String
        let c: String
        let x: String

        init(_ a: String, _ b: String, _ c: String, _ x: String) {
            self.a = a
            self.b = b
            self.c = c
            self.x = x
        }
    }

    let testsa: [testa] = [
        testa("1", "1", "1", "2"),
        testa("25.2", "63.6", "-438", "1164.72"),
        testa("0.301", "0.380", "334", "334.114380"),
        testa("49.2", "-4.8", "23.3", "-212.86"),
        testa("4.22", "0.079", "-94.6", "-94.26662"),
        testa("903", "0.797", "0.887", "720.578"),
        testa("6.13", "-161", "65.9", "-921.03"),
        testa("28.2", "727", "5.45", "20506.85"),
        testa("4", "605", "688", "3108"),
        testa("93.3", "0.19", "0.226", "17.953"),
        testa("0.169", "-341", "5.61", "-52.019"),
        testa("-72.2", "30", "-51.2", "-2217.2"),
        testa("-0.409", "13", "20.4", "15.083"),
        testa("317", "77.0", "19.0", "24428.0"),
        testa("47", "6.58", "1.62", "310.88"),
        testa("1.36", "0.984", "0.493", "1.83124"),
        testa("72.7", "274", "1.56", "19921.36"),
        testa("335", "847", "83", "283828"),
        testa("666", "0.247", "25.4", "189.902"),
        testa("-3.87", "3.06", "78.0", "66.1578"),
        testa("0.742", "192", "35.6", "178.064"),
        testa("-91.6", "5.29", "0.153", "-484.411"),
        testa("2", "2", "0e+384", "4"),
        testa("2", "3", "0e+384", "6"),
        testa("5", "1", "0e+384", "5"),
        testa("5", "2", "0e+384", "10"),
        testa("1.20", "2", "0e+384", "2.40"),
        testa("1.20", "0", "0e+384", "0.00"),
        testa("1.20", "-2", "0e+384", "-2.40"),
        testa("-1.20", "2", "0e+384", "-2.40"),
        testa("-1.20", "0", "0e+384", "0.00"),
        testa("-1.20", "-2", "0e+384", "2.40"),
        testa("5.09", "7.1", "0e+384", "36.139"),
        testa("2.5", "4", "0e+384", "10.0"),
        testa("2.50", "4", "0e+384", "10.00"),
        testa("1.23456789", "1.00000000", "0e+384", "1.234567890000000"),
        testa("2.50", "4", "0e+384", "10.00"),
        testa("9.999999999", "9.999999999", "0e+384", "99.99999998000000"),
        testa("9.999999999", "-9.999999999", "0e+384", "-99.99999998000000"),
        testa("-9.999999999", "9.999999999", "0e+384", "-99.99999998000000"),
        testa("-9.999999999", "-9.999999999", "0e+384", "99.99999998000000"),
    ]

    func test1() throws {
        for t in testsa {
            let a = BigDecimal(t.a)
            let b = BigDecimal(t.b)
            let c = BigDecimal(t.c)
            let x = c.fma(a, b, Rounding.decimal64)
            XCTAssertEqual(x.asString(), t.x)
        }
    }

    struct testb {

        let a: String
        let b: String
        let c: String
        let fused: String
        let notfused: String

        init(_ a: String, _ b: String, _ c: String, _ fused: String, _ notfused: String) {
            self.a = a
            self.b = b
            self.c = c
            self.fused = fused
            self.notfused = notfused
        }
    }
    
    let testsb: [testb] = [
        testb("27583489.6645", "2582471078.04", "2593183.42371", "7.123356429257970E+16", "7.123356429257969E+16"),
        testb("24280.355566", "939577.397653", "2032.013252", "22813275328.80507", "22813275328.80506"),
        testb("7848976432", "-2586831.2281", "137903.517909", "-2.030397734278061E+16", "-2.030397734278062E+16"),
        testb("56890.388731", "35872030.4255", "339337.123410", "2040774094814.078", "2040774094814.077"),
        testb("7533543.57445", "360317763928", "5073392.31638", "2.714469575205050E+18", "2.714469575205049E+18"),
        testb("739945255.563", "13672312784.1", "-994381.53572", "1.011676297716715E+19", "1.011676297716716E+19"),
        testb("-413510957218", "704729988550", "9234162614.0", "-2.914135721455314E+23", "-2.914135721455315E+23"),
        testb("437484.00601", "598906432790", "894450638.442", "2.620119863365787E+17", "2.620119863365786E+17"),
        testb("73287556929", "173651305.784", "-358312568.389", "1.272647995808177E+19", "1.272647995808178E+19"),
        testb("203258304486", "-8628278.8066", "153127.446727", "-1.753769320861850E+18", "-1.753769320861851E+18"),
        testb("42560533.1774", "-3643605282.86", "178277.96377", "-1.550737835263347E+17", "-1.550737835263346E+17"),
        testb("142656587375", "203118879670", "604576103991", "2.897624620576004E+22", "2.897624620576005E+22"),
    ]
    
    func test2() throws {
        for t in testsb {
            let a = BigDecimal(t.a)
            let b = BigDecimal(t.b)
            let c = BigDecimal(t.c)
            let x1 = c.fma(a, b, Rounding.decimal64)
            let x2 = ((a * b).round(Rounding.decimal64) + c).round(Rounding.decimal64)
            XCTAssertEqual(x1.asString(), t.fused)
            XCTAssertEqual(x2.asString(), t.notfused)
        }
    }

}
