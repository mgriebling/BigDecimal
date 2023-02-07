//
//  TestDecimal32Encoding.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 01/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest

class TestDecimal32Encoding: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct test {

        let input: UInt32
        let result: String
        let enc: BigDecimal.Encoding

        init(_ input: UInt32, _ result: String, _ enc: BigDecimal.Encoding = .DPD) {
            self.input = input
            self.result = result
            self.enc = enc
        }
    }
    
    let tests1: [test] = [
        test(0xA23003D0, "-7.50"),
        test(0xA26003D0, "-7.50E+3"),
        test(0xA25003D0, "-750"),
        test(0xA24003D0, "-75.0"),
        test(0xA22003D0, "-0.750"),
        test(0xA21003D0, "-0.0750"),
        test(0xA1f003D0, "-0.000750"),
        test(0xA1d003D0, "-0.00000750"),
        test(0xA1c003D0, "-7.50E-7"),
        test(0x2654d2e7, "1234567"),
        test(0xa654d2e7, "-1234567"),
        test(0x26524491, "1111111"),
        test(0x77f3fcff, "9.999999E+96"),
        test(0x47f4d2e7, "1.234567E+96"),
        test(0x47f4c000, "1.230000E+96"),
        test(0x47f00000, "1.000000E+96"),
        test(0x00600001, "1E-95"),
        test(0x04000000, "1.000000E-95"),
        test(0x04000001, "1.000001E-95"),
        test(0x00020000, "1.00000E-96"),
        test(0x00000010, "1.0E-100"),
        test(0x00000001, "1E-101"),
        test(0x80000001, "-1E-101"),
        test(0x225049c5, "12345"),
        test(0x22500534, "1234"),
        test(0x225000a3, "123"),
        test(0x22500012, "12"),
        test(0x22500001, "1"),
        test(0x223000a3, "1.23"),
        test(0x223049c5, "123.45"),
        test(0x80600001, "-1E-95"),
        test(0x84000000, "-1.000000E-95"),
        test(0x84000001, "-1.000001E-95"),
        test(0x80020000, "-1.00000E-96"),
        test(0x80000010, "-1.0E-100"),
        test(0x80000001, "-1E-101"),
    ]

    func test1() throws {
        for t in tests1 {
            XCTAssertEqual(BigDecimal(t.input, t.enc), BigDecimal(t.result))
            XCTAssertEqual(BigDecimal(t.input, t.enc).asString(), t.result)
        }
    }

    let tests2: [test] = [
        test(0x22500000, "0"),
        test(0x22500009, "9"),
        test(0x22500010, "10"),
        test(0x22500019, "19"),
        test(0x22500020, "20"),
        test(0x22500029, "29"),
        test(0x22500030, "30"),
        test(0x22500039, "39"),
        test(0x22500040, "40"),
        test(0x22500049, "49"),
        test(0x22500050, "50"),
        test(0x22500059, "59"),
        test(0x22500060, "60"),
        test(0x22500069, "69"),
        test(0x22500070, "70"),
        test(0x22500071, "71"),
        test(0x22500072, "72"),
        test(0x22500073, "73"),
        test(0x22500074, "74"),
        test(0x22500075, "75"),
        test(0x22500076, "76"),
        test(0x22500077, "77"),
        test(0x22500078, "78"),
        test(0x22500079, "79"),
        test(0x2250029e, "994"),
        test(0x2250029f, "995"),
        test(0x225002a0, "520"),
        test(0x225002a1, "521"),
        test(0x225003f7, "777"),
        test(0x225003f8, "778"),
        test(0x225003eb, "787"),
        test(0x2250037d, "877"),
        test(0x2250039f, "997"),
        test(0x225003bf, "979"),
        test(0x225003df, "799"),
        test(0x2250006e, "888"),
        test(0x2250006e, "888"),
        test(0x2250016e, "888"),
        test(0x2250026e, "888"),
        test(0x2250036e, "888"),
        test(0x2250006f, "889"),
        test(0x2250016f, "889"),
        test(0x2250026f, "889"),
        test(0x2250036f, "889"),
        test(0x2250007e, "898"),
        test(0x2250017e, "898"),
        test(0x2250027e, "898"),
        test(0x2250037e, "898"),
        test(0x2250007f, "899"),
        test(0x2250017f, "899"),
        test(0x2250027f, "899"),
        test(0x2250037f, "899"),
        test(0x225000ee, "988"),
        test(0x225001ee, "988"),
        test(0x225002ee, "988"),
        test(0x225003ee, "988"),
        test(0x225000ef, "989"),
        test(0x225001ef, "989"),
        test(0x225002ef, "989"),
        test(0x225003ef, "989"),
        test(0x225000fe, "998"),
        test(0x225001fe, "998"),
        test(0x225002fe, "998"),
        test(0x225003fe, "998"),
        test(0x225000ff, "999"),
        test(0x225001ff, "999"),
        test(0x225002ff, "999"),
        test(0x225003ff, "999"),
    ]

    func test2() throws {
        for t in tests2 {
            XCTAssertEqual(BigDecimal(t.input, t.enc), BigDecimal(t.result))
            XCTAssertEqual(BigDecimal(t.input, t.enc).asString(), t.result)
        }
    }

}
