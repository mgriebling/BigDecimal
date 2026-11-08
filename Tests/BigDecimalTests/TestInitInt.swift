//
//  TestInitInt.swift
//  
//
//  Created by Leif Ibsen on 04/10/2022.
//

import Testing
@testable import BigDecimal
import BigInt

@Suite("Test init<I:BinaryInteger>(_:)", .serialized)
final class TestIntInit  {

    static func genInts<I: FixedWidthInteger & SignedInteger>(_ type: I.Type) -> [I] {
        return [
            .max,
            .max - 1,
            .max / 2,
            .max / 4,
            .max / 8,
            1,
            0,
            -1,
            .min / 8,
            .min / 4,
            .min / 2,
            .min + 1,
            .min,
        ]
    }

    @Test("Test Int", arguments: genInts(Int.self)) func testInts(t: Int) {
        #expect(BigDecimal(t).description == t.description)
    }

    @Test("Test Int8", arguments: genInts(Int8.self)) func testInt8s(t: Int8) {
        #expect(BigDecimal(t).description == t.description)
    }

    @Test("Test Int16", arguments: genInts(Int16.self)) func testInt16s(t: Int16) {
        #expect(BigDecimal(t).description == t.description)
    }

    @Test("Test Int32", arguments: genInts(Int32.self)) func testInt32s(t: Int32) {
        #expect(BigDecimal(t).description == t.description)
    }

    @Test("Test Int64", arguments: genInts(Int64.self)) func testInt64s(t: Int64) {
        #expect(BigDecimal(t).description == t.description)
    }

    @available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 1, macCatalyst 18, *)
    @Test("Test Int128", arguments: genInts(Int128.self)) func testInt128s(t: Int128) {
        #expect(BigDecimal(t).description == t.description)
    }

    static func genInts<I: FixedWidthInteger & UnsignedInteger>(_ type: I.Type) -> [I] {
        return [
            .max,
            .max - 1,
            .max / 2,
            .max / 4,
            .max / 8,
            1,
            0,
        ]
    }

    // HACK: This is a hack to force the use of `BigDecimal<I:FixedWidthInteger>.init(_ int: T)`. Without it,
    // the compiler will use `BigDecimal.init(_ value: UIntT64, _ encoding: ID.Encoding = .dpd)`; which
    // expects `bid` or `dpd` encoded integers.
    func decimal<I: FixedWidthInteger & UnsignedInteger>(_ int: I) -> BigDecimal {
        return BigDecimal(int)
    }

    @Test("Test UInt", arguments: genInts(UInt.self)) func testUInts(t: UInt) {
        #expect(decimal(t).description == t.description)
    }

    @Test("Test UInt8", arguments: genInts(UInt8.self)) func testUInt8s(t: UInt8) {
        #expect(decimal(t).description == t.description)
    }

    @Test("Test UInt16", arguments: genInts(UInt16.self)) func testUInt16s(t: UInt16) {
        #expect(decimal(t).description == t.description)
    }

    @Test("Test UInt32", arguments: genInts(UInt32.self)) func testUInt32s(t: UInt32) {
        #expect(decimal(t).description == t.description)
    }

    @Test("Test UInt64", arguments: genInts(UInt64.self)) func testUInt64s(t: UInt64) {
        #expect(decimal(t).description == t.description)
    }

    @available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 1, macCatalyst 18, *)
    @Test("Test UInt128", arguments: genInts(UInt128.self)) func testUInt128s(t: UInt128) {
        #expect(decimal(t).description == t.description)
    }
}
