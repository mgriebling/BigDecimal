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

/// Implementation of the 32-bit Decimal32 floating-point operations from
/// IEEE STD 754-2008 for Floating-Point Arithmetic.
///
/// The IEEE Standard 754-2008 for Floating-Point Arithmetic supports two
/// encoding formats: the decimal encoding format, and the binary encoding
/// format. The Intel(R) Decimal Floating-Point Math Library supports primarily
/// the binary encoding format for decimal floating-point values, but the
/// decimal encoding format is supported too in the library, by means of
/// conversion functions between the two encoding formats.
public struct Decimal32 : DecimalType, Codable, Hashable {

    // Decimal32 characteristics
    static let largestNumber  = UInt32(9_999_999)
    static let exponentBias   = 101
    static let maxExponent    = 90
    static let exponentBits   = 8
    static let maxDigits      = 7
    
    public typealias ID = BigDecimal
    
    public typealias RawExponent = UInt
    public typealias RawSignificand = UInt32
    public typealias RawBitPattern = UInt32
    
    // Internal data store for the binary integer decimal encoded number.
    // The internal representation is always binary integer decimal.
    var bid : UInt32
    
    // Raw data initializer -- only for internal use.
    public init(bid: UInt32) { self.bid = bid }
    init(bid: ID)            { self.bid = bid.asDecimal32(.bid) }
    
    /// Creates a NaN ("not a number") value with the specified payload.
    ///
    /// NaN values compare not equal to every value, including themselves. Most
    /// operations with a NaN operand produce a NaN result. Don't use the
    /// equal-to operator (`==`) to test whether a value is NaN. Instead, use
    /// the value's `isNaN` property.
    ///
    ///     let x = Decimal32(nan: 0, signaling: false)
    ///     print(x == .nan)
    ///     // Prints "false"
    ///     print(x.isNaN)
    ///     // Prints "true"
    ///
    /// - Parameters:
    ///   - payload: The payload to use for the new NaN value.
    ///   - signaling: Pass `true` to create a signaling NaN or `false` to
    ///     create a quiet NaN.
    public init(nan payload: RawSignificand, signaling: Bool) {
        bid = ID(signaling ? .snan : .qnan, BInt(payload)).asDecimal32(.bid)
    }
}

extension Decimal32 : AdditiveArithmetic {
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(bid: ID(lhs.bid, .bid).subtract(ID(rhs.bid, .bid),
                                             Rounding.decimal32))
    }
    
    public mutating func negate() { bid = (-ID(bid, .bid)).asDecimal32(.bid) }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(bid: ID(lhs.bid, .bid).add(ID(rhs.bid, .bid), Rounding.decimal32))
    }
    
    public static var zero: Self { Self(bid: ID.zero) }
}

extension Decimal32 : Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        ID(lhs.bid, .bid) == ID(rhs.bid, .bid)
    }
}

extension Decimal32 : Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        ID(lhs.bid, .bid) < ID(rhs.bid, .bid)
    }
    
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        ID(lhs.bid, .bid) >= ID(rhs.bid, .bid)
    }
    
    public static func > (lhs: Self, rhs: Self) -> Bool {
        ID(lhs.bid, .bid) > ID(rhs.bid, .bid)
    }
}

extension Decimal32 : LosslessStringConvertible {
    public init?(_ description: String) {
        bid = ID(description).asDecimal32(.bid)
    }
}

extension Decimal32 : CustomStringConvertible {
    public var description: String {
        ID(bid, .bid).asString()
    }
}

extension Decimal32 : ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        bid = ID(value).asDecimal32(.bid)
    }
}

extension Decimal32 : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        bid = ID(value).asDecimal32(.bid)
    }
}

extension Decimal32 : ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(stringLiteral: value, rounding: .toNearestOrEven)
    }
    
    init(stringLiteral value: StringLiteralType, rounding rule: RoundingRule) {
        bid = ID(value).asDecimal32(.bid)
    }
}

extension Decimal32 : Strideable {
    public func distance(to other: Self) -> Self { other - self }
    public func advanced(by n: Self) -> Self { self + n }
}

extension Decimal32 : FloatingPoint {
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Initializers for FloatingPoint
    
    public init(sign: Sign, exponent: Int, significand: Self) {
        let sig = ID(significand.bid, .bid)
        bid = ID(sign:sign,exponent:exponent,significand:sig).asDecimal32(.bid)
    }
    
    public mutating func round(_ rule: RoundingRule) {
        let digits = Rounding.decimal32.precision
        bid = ID(bid, .bid).round(Rounding(rule, digits)).asDecimal32(.bid)
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - DecimalFloatingPoint properties and attributes
    
    public static var exponentBitCount:Int      { exponentBits }
    public static var significandDigitCount:Int { Rounding.decimal32.precision}
    public static var nan:Self                  { Self(nan:0,signaling:false) }
    public static var signalingNaN:Self         { Self(nan:0,signaling:true) }
    public static var infinity:Self             { Self(bid:ID.infinity) }
    
    public static var greatestFiniteMagnitude: Self {
        Self(bid: ID(Int(largestNumber), maxExponent))
    }
    
    public static var leastNormalMagnitude: Self {
        Self(bid: ID(Int(largestNumber), 0))
    }
    
    public static var leastNonzeroMagnitude: Self {
        Self(bid: ID(1, 0))
    }
    
    public static var pi: Self { Self(bid: ID.pi) }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Instance properties and attributes
    
    public var ulp: Self            { nextUp - self }
    public var nextUp: Self         { Self(bid: ID(bid, .bid).nextUp) }
    public var sign: Sign           { isNegative ? .minus : .plus }
    public var isNormal: Bool       { ID(bid, .bid).isNormal }
    public var isSubnormal: Bool    { ID(bid, .bid).isSubnormal }
    public var isFinite: Bool       { ID(bid, .bid).isFinite }
    public var isZero: Bool         { ID(bid, .bid).isZero }
//    public var isInfinite: Bool     { ID(bid, .bid).isInfinite && !isNaN }
//    public var isNaN: Bool          { ID(bid, .bid).isNaN }
    public var isSignalingNaN: Bool { ID(bid, .bid).isSignalingNaN }
    public var isCanonical: Bool    { ID(bid, .bid).isCanonical }
    public var exponent: Int {Int(self.exponentBitPattern) - Self.exponentBias}
    public var significand: Self    { Self(bid: ID(significandBitPattern)) }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Floating-point basic operations with rounding
    
    public func adding(other: Self, rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal32.precision)
        return Self(bid: ID(self.bid, .bid).add(ID(other.bid, .bid), round))
    }
    
    public mutating func add(other: Self, rounding rule: RoundingRule) {
        self = self.adding(other: other, rounding: rule)
    }
    
    public mutating func subtract(other: Self, rounding rule: RoundingRule) {
        self = self.subtracting(other: other, rounding: rule)
    }
    
    public func subtracting(other: Self, rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal32.precision)
        return Self(bid:ID(self.bid, .bid).subtract(ID(other.bid, .bid),round))
    }
    
    public func multiplied(by other:Self, rounding rule:RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal32.precision)
        return Self(bid:ID(self.bid, .bid).multiply(ID(other.bid, .bid),round))
    }
    
    public mutating func multiply(by other: Self, rounding rule:RoundingRule) {
        self = self.multiplied(by: other, rounding: rule)
    }
    
    public func divided(by other: Self, rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal32.precision)
        return Self(bid: ID(self.bid, .bid).divide(ID(other.bid, .bid), round))
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
        bid = ID(self.bid, .bid).truncatingRemainder(dividingBy:
                                        ID(other.bid, .bid)).asDecimal32(.bid)
    }
    
    public mutating func formTruncatingRemainder(dividingBy other: Self) {
        let q = (self/other).rounded(.towardZero)
        self -= q * other
    }
    
    public mutating func formSquareRoot() {
        self.formSquareRoot(rounding: .toNearestOrEven)
    }
    
    public func squareRoot(rounding rule: RoundingRule) -> Self {
        let round = Rounding(rule, Rounding.decimal32.precision)
        return Self(bid: ID.sqrt(ID(bid, .bid), round))
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
        let round = Rounding(rule, Rounding.decimal32.precision)
        bid = ID(self.bid, .bid).fma(ID(lhs.bid, .bid),
                                  ID(rhs.bid, .bid), round).asDecimal32(.bid)
    }
    
    public func isEqual(to other: Self) -> Bool  { self == other }
    public func isLess(than other: Self) -> Bool { self < other }
    
    public func isLessThanOrEqualTo(_ other: Self) -> Bool {
        isEqual(to: other) || isLess(than: other)
    }
    
    public var magnitude: Self {
        Self(ID(bid, .bid).magnitude.asDecimal32(.bid))
    }
}

extension Decimal32 : DecimalFloatingPoint {
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Initializers for DecimalFloatingPoint
    
    /// Creates a new instance from the specified sign and bit patterns.
    ///
    /// The values passed as `exponentBitPattern` and `significandBitPattern` are
    /// interpreted in the decimal interchange format defined by the [IEEE 754
    /// specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
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
    public init(sign: Sign, exponentBitPattern: RawExponent,
                significandBitPattern: RawSignificand) {
        self = Self(bid:ID(sign: sign,
                           exponent: Int(exponentBitPattern)-Self.exponentBias,
                           significand: ID(significandBitPattern)))
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Instance properties and attributes
    
    /// The raw encoding of the value's significand field.
    public var significandBitPattern: UInt32 {
        if isSpecial {
            // exp = (value >> 21) & 0xff
            return Self.highBit | (bid & 0x1fffff)
        } else {
            // exp = (value >> 23) & 0xff
            return bid & 0x7fffff
        }
    }
    
    /// The raw encoding of the value's exponent field.
    ///
    /// This value is unadjusted by the type's exponent bias.
    public var exponentBitPattern: UInt {
        let mask = (UInt(1) << Self.exponentBits) - 1
        if isSpecial {
            return UInt(bid >> 21) & mask
        } else {
            return UInt(bid >> 23) & mask
        }
    }
    
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
    /// For example, a Decimal32 number has been created with the value "1000.3".
    /// Using the `bitPattern` accessor with a `.bid` encoding value, a
    /// 32-bit unsigned integer encoded
    /// value of `0x32002713` is returned.  The `bitPattern` with a `.dpd`
    /// encoding value returns the 32-bit unsigned integer encoded value of
    /// `0x22404003`. Passing these
    /// numbers to the appropriate initialize recreates the original value
    /// "1000.3".
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    public func bitPattern(_ encoding: ID.Encoding) -> RawSignificand {
        encoding == .bid ? bid : ID(bid, .bid).asDecimal32(.dpd)
    }
    
    public init(bitPattern: RawSignificand, encoding: ID.Encoding) {
        if encoding == .bid {
            bid = bitPattern
        } else {
            bid = ID(bitPattern, .dpd).asDecimal32(.bid)
        }
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
    public var decade: Self { Self.zero /* Self(bid: bid.quantum) */ }
}
 
extension Decimal32 {
    // MARK: - Constants for conversion
    
    static let negative = UInt32(0x8000_0000)
    static let infinite = UInt32(0x7800_0000)
    static let nanMask  = UInt32(0x7c00_0000)
    static let highBit  = UInt32(0x0080_0000)
    static let special  = UInt32(0x6000_0000)
    
    // MARK: - Conversions to/from Decimal32
    
    init(_ value: UInt32, _ encoding: ID.Encoding = .dpd) {
        if encoding == .bid {
            self.init(bid: value)
        } else {
            // convert dpd to bid
            var sig = UInt32(0)
            var exp = UInt32(0)
            if value & Self.special == Self.special {
                exp = ((value >> 20) & 0x3f) | (((value >> 27) & 0x3) << 6)
                sig = 8 + (value >> 26) & 0x1
            } else {
                exp = ((value >> 20) & 0x3f) | ((value >> 29) & 0x3) << 6
                sig = (value >> 26) & 0x7
            }
            sig *= 1000
            sig += ID.decodeDPD[(value >> 10) & 0x3ff]
            sig *= 1000
            sig += ID.decodeDPD[value & 0x3ff]
            if sig > Self.largestNumber {
                sig = 0
            }
            let sign = value & Self.negative
            if sig < Self.highBit {
                self.init(bid: sign | exp << 23 | sig)
            } else {
                self.init(bid: sign | exp << 21 | Self.special | sig)
            }
        }
    }
    
    /// Initialize from a BigDecimal
    init(_ value: BigDecimal) {
        let sign = value.isNegative ? Self.negative : 0
        if value.isNaN {
            self.init(nan: 0, signaling: false)
        } else if value.isInfinite {
            self.init(bid: Self.infinite)
        } else if value.abs > BigDecimal.MAX32 {
            self.init(nan: 0, signaling: false)
        } else {
            let w = Rounding.decimal32.round(value).abs
            var exp = UInt32(Self.exponentBias + w.exponent)
            var sig = UInt32(w.digits.asInt()!)
            while exp > Self.exponentBias+Self.maxExponent {
                exp -= 1
                sig *= 10
            }
            while exp < 0 {
                exp += 1
                sig /= 10
            }
            if sig < Self.highBit {
                self.init(bid: sign | exp << 23 | sig)
            } else {
                self.init(bid: sign | exp << 21 | Self.special | sig)
            }
        }
    }
    
    // Attributes for this number
    public var isNaN: Bool      { bid & Self.nanMask == Self.nanMask }
    public var isInfinite: Bool { bid & Self.infinite == Self.infinite }
    var isNegative: Bool        { bid & Self.negative == Self.negative }
    
    func asBigDecimal() -> BigDecimal {
        if self.isNaN {
            return ID.flagNaN()
        } else if self.isInfinite {
            return isNegative ? -BigDecimal.infinity : BigDecimal.infinity
        } else {
            return BigDecimal(
                BInt(isNegative ? -Int(significandBitPattern)
                                : Int(significandBitPattern)),
                Int(self.exponent))
        }
    }
    
    /// Convert to special encodings
    func asUInt32(_ encoding: ID.Encoding = .dpd) -> UInt32 {
        if encoding == .bid { return bid }
        
        // convert to dpd
        let significand = significandBitPattern
        let exponent = UInt32(self.exponent + Self.exponentBias)
        assert(exponent <= Self.exponentBias + Self.maxExponent)
        assert(significand <= Self.largestNumber)
        var value = self.isNegative ? Self.negative : 0

        let d1 = UInt32(significand % 1000)
        let d2 = UInt32((significand / 1000) % 1000)
        let d3 = UInt32(significand / 1000_000)
        if d3 < 8 {
            value |= (exponent & 0xc0) << 23
            value |= d3 << 26
            value |= (exponent & 0x3f) << 20
        } else {
            value |= 0x3 << 29
            value |= (exponent & 0xc0) << 21
            value |= (d3 & 0x1) << 26
            value |= (exponent & 0x3f) << 20
        }
        value |= ID.encodeDPD[d2] << 10
        value |= ID.encodeDPD[d1]
        return value
    }

}
