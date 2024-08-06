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

/// Implementation of the 64-bit Decimal64 floating-point operations from
/// IEEE STD 754-2019 for Floating-Point Arithmetic.
///
/// The IEEE Standard 754-2008 for Floating-Point Arithmetic supports two
/// encoding formats: the decimal encoding format, and the binary encoding
/// format. This package supports both the binary encoding format for
/// decimal floating-point values and the decimal encoding format.
///
/// Calculations convert Decimal64 numbers to BigDecimal format, perform
/// the operation, and convert back to Decimal64 format.
public struct Decimal64 : DecimalType, Codable, Hashable, Sendable {
    
    // Decimal64 characteristics
    static let largestNumber = UInt64(9_999_999_999_999_999)
    static let exponentBias  = 398
    static let maxExponent   = 369
    static let exponentBits  = 10
    static let maxDigits     = 16
    
    public typealias ID = BigDecimal
    public typealias RawSignificand = UInt64
//    public typealias RawBitPattern = UInt64
    
    var bid: UInt64 = 0
    
    public init(bid: UInt64) { self.bid = bid }
    init(bid: ID)            { self.bid = bid.asDecimal64(.bid) }
    
    /// convenience method to get the BigDecimal version of `bid`
    var bd : BigDecimal { ID(self.bid, .bid) }
}

extension Decimal64 : AdditiveArithmetic {
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(bid: lhs.bd.subtract(rhs.bd, Rounding.decimal64))
    }
    
    public mutating func negate() { bid = Self(bid: -self.bd).bid }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(bid: lhs.bd.add(rhs.bd, Rounding.decimal64))
    }
    
    public static var zero: Self { Self(bid: ID.zero) }
}

extension Decimal64 : Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.bd == rhs.bd }
}

extension Decimal64 : Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool  { lhs.bd < rhs.bd }
    public static func >= (lhs: Self, rhs: Self) -> Bool { lhs.bd >= rhs.bd }
    public static func > (lhs: Self, rhs: Self) -> Bool  { lhs.bd > rhs.bd }
}

extension Decimal64 : LosslessStringConvertible {
    public init?(_ description: String) { self.init(bid: ID(description)) }
}

extension Decimal64 : CustomStringConvertible {
    public var description: String { self.bd.asString() }
}

extension Decimal64 : ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self.init(bid: ID(value)) }
}

extension Decimal64 : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(bid: ID(value))
    }
}

extension Decimal64 : ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(bid: ID(value))
    }
}

extension Decimal64 : Strideable {
    public func distance(to other: Self) -> Self { other - self }
    public func advanced(by n: Self) -> Self { self + n }
}

extension Decimal64 : FloatingPoint {
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Initializers for FloatingPoint
    
    public init(sign: Sign, exponent: Int, significand: Self) {
        let sig = significand.bd
        bid = Self(bid:ID(sign:sign,exponent:exponent,significand:sig)).bid
    }
    
    public mutating func round(_ rule: RoundingRule) {
        let digits = Rounding.decimal64.precision
        bid = Self(self.bd.round(Rounding(rule, digits))).bid
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Type properties and attributes
    
    public static var infinity: Self { Self(bid: ID.infinity) }
    public static var pi: Self       { Self(bid: ID.pi) }
    
    public static var greatestFiniteMagnitude: Self {
        Self(bid: ID(Int(largestNumber), maxExponent))
    }
    
    public static var leastNormalMagnitude: Self {
        Self(bid: ID(Int(largestNumber), minExponent))
    }
    
    public static var leastNonzeroMagnitude: Self {
        Self(bid: ID(1, minExponent))
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Instance properties and attributes
    
    public var ulp: Self         { nextUp - self }
    public var nextUp: Self      { Self(bid: ID(bid, .bid).nextUp) }
    public var significand: Self { Self(bid: ID(significandBitPattern)) }
    public var exponent: Int     { exponentBitPattern - Self.exponentBias }

    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Floating-point basic operations with rounding
    
    public func adding(other: Self, rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal64.precision)
        return Self(bid: self.bd.add(other.bd, round))
    }
    
    public mutating func add(other: Self, rounding rule: RoundingRule) {
        self = self.adding(other: other, rounding: rule)
    }
    
    public mutating func subtract(other: Self, rounding rule: RoundingRule) {
        self = self.subtracting(other: other, rounding: rule)
    }
    
    public func subtracting(other: Self, rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal64.precision)
        return Self(bid: self.bd.subtract(other.bd, round))
    }
    
    public func multiplied(by other:Self, rounding rule:RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal64.precision)
        return Self(bid: self.bd.multiply(other.bd, round))
    }
    
    public mutating func multiply(by other: Self, rounding rule:RoundingRule) {
        self = self.multiplied(by: other, rounding: rule)
    }
    
    public func divided(by other: Self, rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal64.precision)
        return Self(bid: self.bd.divide(other.bd, round))
    }
    
    public mutating func divide(by other: Self, rounding rule: RoundingRule) {
        self = self.divided(by: other, rounding: rule)
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Floating-point basic operations
    
    public static func * (lhs: Self, rhs: Self) -> Self {
        lhs.multiplied(by: rhs, rounding: .toNearestOrEven)
    }
    
    public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }
    
    public static func / (lhs: Self, rhs: Self) -> Self {
        lhs.divided(by: rhs, rounding: .toNearestOrEven)
    }
    
    public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }
    
    public mutating func formRemainder(dividingBy other: Self) {
        bid = Self(bid: self.bd.truncatingRemainder(dividingBy: other.bd)).bid
    }
    
    public mutating func formTruncatingRemainder(dividingBy other: Self) {
        let q = (self/other).rounded(.towardZero)
        self -= q * other
    }
    
    public mutating func formSquareRoot() {
        self.formSquareRoot(rounding: .toNearestOrEven)
    }
    
    public func squareRoot(rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal64.precision)
        return Self(bid: ID.sqrt(self.bd, round))
    }
    
    /// Rounding method equivalend of the `formSquareRoot`
    public mutating func formSquareRoot(rounding rule: RoundingRule) {
        self = squareRoot(rounding: rule)
    }
    
    public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
        self.addProduct(lhs, rhs, rounding: .toNearestOrEven)
    }
    
    public func addingProduct(_ lhs: Self, _ rhs: Self,
                              rounding rule: RoundingRule) -> Self {
        var x = self
        x.addProduct(lhs, rhs, rounding: rule)
        return x
    }
    
    /// Rounding method equivalent of the `addProduct`
    public mutating func addProduct(_ lhs: Self, _ rhs: Self,
                                    rounding rule: RoundingRule) {
        let round = Rounding(rule, Rounding.decimal64.precision)
        bid = Self(bid: self.bd.fma(lhs.bd, rhs.bd, round)).bid
    }
    
    public func isEqual(to other: Self) -> Bool  { self == other }
    public func isLess(than other: Self) -> Bool { self < other }
    
    public func isLessThanOrEqualTo(_ other: Self) -> Bool {
        isEqual(to: other) || isLess(than: other)
    }
    
    public var magnitude: Self { Self(bid: self.bd.magnitude) }
}

extension Decimal64 : DecimalFloatingPoint {
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Initializers for DecimalFloatingPoint
    
    /// Creates a new instance from the specified sign and bit patterns.
    ///
    /// The values passed as `exponentBitPattern` and `significandBitPattern` are
    /// interpreted in the decimal interchange format defined by the [IEEE 754
    /// specification][spec].
    ///
    /// [spec]: https://ieeexplore.ieee.org/servlet/opac?punumber=8766227
    ///
    /// The `significandBitPattern` are the big-endian, binary integer decimal
    /// digits of the number. For example, the integer number `314` represents a
    /// significand of `314`.
    ///
    /// - Parameters:
    ///   - sign: The sign of the new value.
    ///   - exponentBitPattern: The bit pattern to use for the exponent field of
    ///     the new value.
    ///   - significandBitPattern: Bit pattern to use for the significand field
    ///     of the new value.
    public init(sign: Sign, exponentBitPattern: Int,
                significandBitPattern: RawSignificand) {
        self.init(bid: UInt64(0))
        self.sign = sign
        self.set(exponent: exponentBitPattern,
                 sigBitPattern: significandBitPattern)
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Instance properties and attributes
    
    //  Conversions to/from binary integer decimal encoding.  These are not part
    //  of the DecimalFloatingPoint prototype because there's no guarantee that
    //  an integer type of the same size actually exists (e.g. Decimal128).
    //
    //  If we want them in a protocol at some future point, that protocol should
    //  be "InterchangeFloatingPoint" or "PortableFloatingPoint" or similar, and
    //  apply to IEEE 754 "interchange types".
    /// The bit pattern of the value's encoding. A `.bid` encoding value
    /// indicates a binary integer decimal encoding; while a `.dpd` encoding
    /// value indicates a densely packed decimal encoding.
    ///
    /// The bit patterns are extracted using the `bitPattern` accessors with
    /// an appropriate `encoding` argument. A new decimal floating point number
    /// is created by passing an bit pattern to the
    /// `init(bitPattern:encoding:)` initializers.
    /// If incorrect bit encodings are used, there are no guarantees about
    /// the resultant decimal floating point number.
    ///
    /// The bit patterns match the decimal interchange format defined by the
    /// [IEEE 754 specification][spec].
    ///
    /// For example, a Decimal64 number has been created with the value "1000.3".
    /// Using the `bitPattern` accessor with a `.bid` encoding value, a
    /// 32-bit unsigned integer encoded
    /// value of `0x32002713` is returned.  The `bitPattern` with a `.dpd`
    /// encoding value returns the 32-bit unsigned integer encoded value of
    /// `0x22404003`. Passing these
    /// numbers to the appropriate initialize recreates the original value
    /// "1000.3".
    ///
    /// [spec]: https://ieeexplore.ieee.org/servlet/opac?punumber=8766227
    public func bitPattern(_ encoding: ID.Encoding) -> RawSignificand {
        encoding == .bid ? bid : self.dpd
    }
    
    public init(bitPattern: RawSignificand, encoding: ID.Encoding) {
        bid = encoding == .bid ? bitPattern : Self.getBID(from: bitPattern)
    }
    
    public var significandDigitCount: Int {
        ID(bid, .bid).significand.precision
    }
    
    /// The floating-point value with the same sign and exponent as this value,
    /// but with a significand of 1.0.
    ///
    /// A *decade* is a set of decimal floating-point values that all have the
    /// same sign and exponent. The `decade` property is a member of the same
    /// decade as this value, but with a unit significand.
    ///
    /// In this example, `x` has a value of `21.5`, which is stored as
    /// `215 * 10**(-1)`, where `**` is exponentiation. Therefore, `x.decade` is
    /// equal to `1 * 10**(-1)`, or `0.1`.
    public var decade: Self {
        Self(sign: self.sign, exponent: self.exponent, significand: 1)
    }
}
 
extension Decimal64 {
    
    // MARK: - Conversions to/from Decimal64
    
    init(_ value: UInt64, _ encoding: ID.Encoding = .dpd) {
        if encoding == .bid {
            self.init(bid: value)
        } else {
            // translate `value` from DPD to BID
            self.init(bid: Self.getBID(from: value))
        }
    }
    
    func asBigDecimal() -> BigDecimal {
        let isNegative = self.sign == .minus
        if self.isNaN {
            return BigDecimal.flagNaN(self.isSignalingNaN)
        } else if self.isInfinite {
            return isNegative ? -BigDecimal.infinity : BigDecimal.infinity
        } else {
            let big = BigDecimal(BInt(significandBitPattern), self.exponent)
            return isNegative ? -big : big
        }
    }
    
    /// Convert to special encodings
    func asUInt64(_ encoding: ID.Encoding = .dpd) -> UInt64 {
        encoding == .bid ? bid : self.dpd
    }

}

