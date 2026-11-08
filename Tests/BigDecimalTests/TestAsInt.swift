//
//  TestAsInt.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 04/10/2022.
//

import Testing
@testable import BigDecimal
import BigInt

@Suite("Test asInt<I:FixedWidthInteger>()", .serialized)
final class TestAsInt  {

    struct test<I: FixedWidthInteger & Sendable>: Sendable, CustomStringConvertible {

        let x: String
        let int: I?

        init(_ x: String, _ int: I?) {
            self.x = x
            self.int = int
        }

        init(_ x: BInt, _ int: I?) {        
            self.x = x.asString()
            self.int = int
        }

        init(_ x: I) {
            self.x = String(x)
            self.int = x
        }

        var description: String {
            return "\(I.self): \(x) should yield \(int?.description ?? "nil")"
        }
    }
    
    static func genTests<I: FixedWidthInteger & SignedInteger>(_ type: I.Type) -> [test<I>] {
        return [
            test(BInt(I.max) + 1, nil),
            test(I.max),
            test(I.max - 1),
            test(I.max / 2),
            test(I.max / 4),
            test(I.max / 8),
            test(1),
            test(0),
            test("-0", 0),
            test(-1),
            test(I.max / -8),
            test(I.max / -4),
            test(I.max / -2),
            test(I.min + 1),
            test(I.min),
            test(BInt(I.min) - 1, nil),
            test("123.0", 123),
            test("1.0", 1),
            test("0.0", 0),
            test("-0.0", 0),
            test("-1.0", -1),
            test("-123.0", -123),
            test("123.00", 123),
            test("1.00", 1),
            test("0.00", 0),
            test("-0.00", 0),
            test("-1.00", -1),
            test("-123.00", -123),
            test("\(I.max).000", I.max),
            test("\(I.max-1).000", I.max-1),
            test("123.000", 123),
            test("1.000", 1),
            test("0.000", 0),
            test("-0.000", 0),
            test("-1.000", -1),
            test("-123.000", -123),
            test("\(I.min+1).000", I.min+1),
            test("\(I.min).000", I.min),
            test("0.4", nil),
            test("1.4", nil),
            test("123.4", nil),
            test("\(I.max).4", nil),
            test("-0.4", nil),
            test("-1.4", nil),
            test("-123.4", nil),
            test("\(I.min).4", nil),
            test("0.45", nil),
            test("1.45", nil),
            test("123.45", nil),
            test("\(I.max).45", nil),
            test("-0.45", nil),
            test("-1.45", nil),
            test("-123.45", nil),
            test("\(I.min).45", nil),
            test("0.456", nil),
            test("1.456", nil),
            test("123.456", nil),
            test("\(I.max).456", nil),
            test("-0.456", nil),
            test("-1.456", nil),
            test("-123.456", nil),
            test("\(I.min).456", nil),
            test("0.4567", nil),
            test("1.4567", nil),
            test("123.4567", nil),
            test("\(I.max).4567", nil),
            test("-0.4567", nil),
            test("-1.4567", nil),
            test("-123.4567", nil),
            test("\(I.min).4567", nil),
        ]
    }

    @Test("Test Int", arguments: genTests(Int.self)) func testInts(t: test<Int>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test Int8", arguments: genTests(Int8.self)) func testInt8s(t: test<Int8>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test Int16", arguments: genTests(Int16.self)) func testInt16s(t: test<Int16>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test Int32", arguments: genTests(Int32.self)) func testInt32s(t: test<Int32>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test Int64", arguments: genTests(Int64.self)) func testInt64s(t: test<Int64>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 1, macCatalyst 18, *)
    @Test("Test Int128", arguments: genTests(Int128.self)) func testInt128s(t: test<Int128>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    
    static func genTests<I: FixedWidthInteger & UnsignedInteger>(_ type: I.Type) -> [test<I>] {
        return [
            test(BInt(I.max) + 1, nil),
            test(I.max),
            test(I.max - 1),
            test(I.max / 2),
            test(I.max / 4),
            test(I.max / 8),
            test(1),
            test(0),
            test("-0", 0),
            test(-1, nil),
            test("123.0", 123),
            test("1.0", 1),
            test("0.0", 0),
            test("-0.0", 0),
            test("-1.0", nil),
            test("123.00", 123),
            test("1.00", 1),
            test("0.00", 0),
            test("-0.00", 0),
            test("-1.00", nil),
            test("\(I.max).000", I.max),
            test("\(I.max-1).000", I.max-1),
            test("123.000", 123),
            test("1.000", 1),
            test("0.000", 0),
            test("-0.000", 0),
            test("-1.000", nil),
            test("0.4", nil),
            test("1.4", nil),
            test("123.4", nil),
            test("\(I.max).4", nil),
            test("-0.4", nil),
            test("-1.4", nil),
            test("-123.4", nil),
            test("\(I.min).4", nil),
            test("0.45", nil),
            test("1.45", nil),
            test("123.45", nil),
            test("\(I.max).45", nil),
            test("-0.45", nil),
            test("-1.45", nil),
            test("-123.45", nil),
            test("\(I.min).45", nil),
            test("0.456", nil),
            test("1.456", nil),
            test("123.456", nil),
            test("\(I.max).456", nil),
            test("-0.456", nil),
            test("-1.456", nil),
            test("-123.456", nil),
            test("\(I.min).456", nil),
            test("0.4567", nil),
            test("1.4567", nil),
            test("123.4567", nil),
            test("\(I.max).4567", nil),
            test("-0.4567", nil),
            test("-1.4567", nil),
            test("-123.4567", nil),
            test("\(I.min).4567", nil),
        ]
    }

    @Test("Test UInt", arguments: genTests(UInt.self)) func testUInts(t: test<UInt>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test UInt8", arguments: genTests(UInt8.self)) func testUInt8s(t: test<UInt8>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test UInt16", arguments: genTests(UInt16.self)) func testUInt16s(t: test<UInt16>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test UInt32", arguments: genTests(UInt32.self)) func testUInt32s(t: test<UInt32>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @Test("Test UInt64", arguments: genTests(UInt64.self)) func testUInt64s(t: test<UInt64>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }

    @available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 1, macCatalyst 18, *)
    @Test("Test UInt128", arguments: genTests(UInt128.self)) func testUInt128s(t: test<UInt128>) {
        #expect(BigDecimal(t.x).asInt() == t.int)
    }
}
