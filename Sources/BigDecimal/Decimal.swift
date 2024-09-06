/**
 Copyright © 2023 Computer Inspirations. All rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import BigInt

public struct RawDecimal : Codable, Hashable, Sendable {
    var raw: BInt
}

extension RawDecimal : UnsignedInteger {
    
    public static func <<= <RHS>(lhs: inout RawDecimal, rhs: RHS) where RHS : BinaryInteger {
        lhs = RawDecimal(raw: lhs.raw << rhs)
    }
    
    public static func >>= <RHS>(lhs: inout RawDecimal, rhs: RHS) where RHS : BinaryInteger {
        lhs = RawDecimal(raw: lhs.raw >> rhs)
    }
    
    
    public static prefix func ~ (x: RawDecimal) -> RawDecimal {
        RawDecimal(raw: ~x.raw)
    }
    
    public var words: [UInt] {
        raw.words
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        raw = BInt(truncatingIfNeeded: source)
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        raw = BInt(clamping: source)
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        raw = BInt(source)
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        if let x = BInt(exactly: source) {
            raw = x; return
        }
        return nil
    }
    
    public init(integerLiteral value: Int) { raw = BInt(value) }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        if let x = BInt(exactly: source) {
            raw = x; return
        }
        return nil
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        raw = BInt(source)
    }
    
    public var bitWidth: Int { 56 * 8 }
    
    public var trailingZeroBitCount: Int {
        self.raw.trailingZeroBitCount
    }
    
    public static func / (lhs: RawDecimal, rhs: RawDecimal) -> RawDecimal {
        RawDecimal(raw: lhs.raw / rhs.raw)
    }
    
    public static func /= (lhs: inout RawDecimal, rhs: RawDecimal) {
        lhs = lhs / rhs
    }
    
    public static func % (lhs: RawDecimal, rhs: RawDecimal) -> RawDecimal {
        RawDecimal(raw: lhs.raw % rhs.raw)
    }
    
    public static func %= (lhs: inout RawDecimal, rhs: RawDecimal) {
        lhs = lhs % rhs
    }
    
    public static func * (lhs: RawDecimal, rhs: RawDecimal) -> RawDecimal {
        RawDecimal(raw: lhs.raw * rhs.raw)
    }
    
    public static func *= (lhs: inout RawDecimal, rhs: RawDecimal) {
        lhs = lhs * rhs
    }
    
    public static func &= (lhs: inout RawDecimal, rhs: RawDecimal) {
        lhs = RawDecimal(lhs.raw & rhs.raw)
    }
    
    public static func |= (lhs: inout RawDecimal, rhs: RawDecimal) {
        lhs = RawDecimal(lhs.raw | rhs.raw)
    }
    
    public static func ^= (lhs: inout RawDecimal, rhs: RawDecimal) {
        lhs = RawDecimal(lhs.raw ^ rhs.raw)
    }
    
    public static func + (lhs: RawDecimal, rhs: RawDecimal) -> RawDecimal {
        RawDecimal(raw: lhs.raw + rhs.raw)
    }
    
    public static func - (lhs: RawDecimal, rhs: RawDecimal) -> RawDecimal {
        RawDecimal(raw: lhs.raw - rhs.raw)
    }
}

extension RawDecimal : FixedWidthInteger {
    public init(_truncatingBits bits: UInt) {
        // FIXME: - do non-zero count
        raw = 0
    }
    
    public static var bitWidth: Int {
        56 * 8
    }
    
    public func addingReportingOverflow(_ rhs: RawDecimal) -> (partialValue: RawDecimal, overflow: Bool) {
        (0, false) // FIXME: - do non-zero count
    }
    
    public func subtractingReportingOverflow(_ rhs: RawDecimal) -> (partialValue: RawDecimal, overflow: Bool) {
        (0, false) // FIXME: - do non-zero count
    }
    
    public func multipliedReportingOverflow(by rhs: RawDecimal) -> (partialValue: RawDecimal, overflow: Bool) {
        (0, false) // FIXME: - do non-zero count
    }
    
    public func dividedReportingOverflow(by rhs: RawDecimal) -> (partialValue: RawDecimal, overflow: Bool) {
        (0, false) // FIXME: - do non-zero count
    }
    
    public func remainderReportingOverflow(dividingBy rhs: RawDecimal) -> (partialValue: RawDecimal, overflow: Bool) {
        (0, false) // FIXME: - do non-zero count
    }
    
    public func dividingFullWidth(_ dividend: (high: RawDecimal, low: RawDecimal)) -> (quotient: RawDecimal, remainder: RawDecimal) {
        (0, 0) // FIXME: - do non-zero count
    }
    
    public var nonzeroBitCount: Int {
        0 // FIXME: - do non-zero count
    }
    
    public var leadingZeroBitCount: Int {
        self.raw.leadingZeroBitCount
    }
    
    public var byteSwapped: RawDecimal {
        self // FIXME: - do byte swapping
    }
}

/// Implementation of a clone of Apple's Decimal floating-point data type
/// using ``BigDecimal`` operations.
///
/// This implementation is entirely independent of Apple's Decimal data
/// type implementation and would be suitable for incorporation into the
/// new Foundation library.
public struct Decimal : DecimalType, Codable, Hashable {

    static var largestNumber = RawDecimal("0")!

    static var exponentBias = 0
    static var exponentBits = 32
    static var maxExponent = 128
    static var maxDigits = 38
    
    public typealias ID = Decimal
    
    public typealias RawSignificand = RawDecimal
    public typealias RawBitPattern = RawDecimal
    
    var exp: Int
    var bid: RawDecimal
    
    init(_ word: RawDecimal) {
        exp = 0
        self.bid = word
    }
    
    init(sign: Sign, exponentBitPattern: Int, significandBitPattern: RawDecimal) {
        self.exp = exponentBitPattern
        self.bid = significandBitPattern
    }
    
    init(nan payload: RawDecimal, signaling: Bool, sign: Sign) {
        self.bid = payload
        self.exp = Int.max
    }
    
}
