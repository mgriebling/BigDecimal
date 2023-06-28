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

import UInt128

/// Definition of the data storage for the Decimal32 floating-point data type.
/// the `IntDecimal` protocol defines many supporting operations
/// including packing and unpacking of the Decimal32 sign, exponent, and
/// significand fields.  By specifying some key bit positions, it is possible
/// to completely define many of the Decimal32 operations.  The `data` word
/// holds all 32 bits of the Decimal32 data type.
//struct IntDecimal32 : IntDecimal {
//  typealias RawSignificand = UInt32
//  typealias RawData = UInt32
//  typealias RawBitPattern = UInt
//
//  var data: RawData = 0
//
//  init(_ word: RawData) { self.data = word }
//
//  init(sign:Sign = .plus, expBitPattern:Int=0, sigBitPattern:RawBitPattern) {
//    self.sign = sign
//    self.set(exponent: expBitPattern, sigBitPattern: sigBitPattern)
//  }
//
//  // Define the fields and required parameters
//  static var exponentBias:       Int {  101 }
//  static var maxEncodedExponent: Int {  191 }
//  static var maximumDigits:      Int {    7 }
//  static var exponentBits:       Int {    8 }
//
//  static var largestNumber: RawBitPattern { 9_999_999 }
//}

/// Implementation of the 32-bit Decimal32 floating-point operations from
/// IEEE STD 754-2008 for Floating-Point Arithmetic.
///
/// The IEEE Standard 754-2008 for Floating-Point Arithmetic supports two
/// encoding formats: the decimal encoding format, and the binary encoding
/// format. The Intel(R) Decimal Floating-Point Math Library supports primarily
/// the binary encoding format for decimal floating-point values, but the
/// decimal encoding format is supported too in the library, by means of
/// conversion functions between the two encoding formats.
public struct Decimal32 : Codable, Hashable {
  public typealias ID = BigDecimal
  
  public typealias RawExponent = UInt
  public typealias RawSignificand = UInt32
  
  // Internal data store for the binary integer decimal encoded number.
  // The internal representation is always binary integer decimal.
    var bid : UInt32
  
  // Raw data initializer -- only for internal use.
  public init(bid: UInt32) { self.bid = bid }
    init(bid: ID)          { self.bid = bid.asDecimal32(.bid) }
  
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
  ///   - signaling: Pass `true` to create a signaling NaN or `false` to create
  ///     a quiet NaN.
  public init(nan payload: RawSignificand, signaling: Bool) {
      bid = 0 // self.bid = ID.init(nan: payload, signaling: signaling)
  }
}

extension Decimal32 : AdditiveArithmetic {
  public static func - (lhs: Self, rhs: Self) -> Self {
    lhs // lhs.subtracting(other: rhs, rounding: .toNearestOrEven)
  }
  
  public mutating func negate() { /* bid.data.toggle(bit: ID.signBit) */ }
  
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs // lhs.adding(other: rhs, rounding: .toNearestOrEven)
  }
  
  public static var zero: Self { Self(bid: ID.zero) }
}

extension Decimal32 : Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    false // ID.equals(lhs: lhs.bid, rhs: rhs.bid)
  }
}

extension Decimal32 : Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
      false // ID.lessThan(lhs: lhs.bid, rhs: rhs.bid)
  }
  
  public static func >= (lhs: Self, rhs: Self) -> Bool {
    false // ID.greaterOrEqual(lhs: lhs.bid, rhs: rhs.bid)
  }
  
  public static func > (lhs: Self, rhs: Self) -> Bool {
    false // ID.greaterThan(lhs: lhs.bid, rhs: rhs.bid)
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
//    if IntegerLiteralType.isSigned {
//      let x = Int(value).magnitude
//      bid = ID.bid(from: UInt64(x), .toNearestOrEven)
//      if value.signum() < 0 { self.negate() }
//    } else {
//      bid = ID.bid(from: UInt64(value), .toNearestOrEven)
//    }
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
    bid = 0 // FIXME: - Get back to this
  }
  
  public mutating func round(_ rule: RoundingRule) {
      let digits = Rounding.decimal32.precision
      bid = ID(bid, .bid).round(Rounding(rule, digits)).asDecimal32(.bid)
  }
  
  ///////////////////////////////////////////////////////////////////////////
  // MARK: - DecimalFloatingPoint properties and attributes
  
  public static var exponentBitCount: Int      { 8 /* ID.exponentBits */ }
    public static var significandDigitCount: Int { Rounding.decimal32.precision } // ID.maximumDigits }
  public static var nan: Self                  { Self(nan:0, signaling:false) }
  public static var signalingNaN: Self         { Self(nan:0, signaling:true) }
  public static var infinity: Self             { Self(ID.infinity.asDecimal32(.bid)) }
  
  public static var greatestFiniteMagnitude: Self {
      zero
//    Self(bid:ID(expBitPattern:ID.maxEncodedExponent,
//                sigBitPattern:ID.largestNumber))
  }
  
  public static var leastNormalMagnitude: Self {
      zero
//    Self(bid:ID(expBitPattern:ID.minEncodedExponent,
//                sigBitPattern:ID.largestNumber))
  }
  
  public static var leastNonzeroMagnitude: Self {
      zero
//    Self(bid: ID(expBitPattern: ID.minEncodedExponent, sigBitPattern: 1))
  }
  
  public static var pi: Self { Self(ID.pi.asDecimal32(.bid)) }
  
  ///////////////////////////////////////////////////////////////////////////
  // MARK: - Instance properties and attributes
  
  public var ulp: Self            { nextUp - self }
  public var nextUp: Self         { Self(ID(bid, .bid).nextUp.asDecimal32(.bid)) }
    public var sign: Sign           { ID(bid, .bid).sign }
    public var isNormal: Bool       { ID(bid, .bid).isNormal }
    public var isSubnormal: Bool    { ID(bid, .bid).isSubnormal }
    public var isFinite: Bool       { ID(bid, .bid).isFinite }
    public var isZero: Bool         { ID(bid, .bid).isZero }
    public var isInfinite: Bool     { ID(bid, .bid).isInfinite && !isNaN }
  public var isNaN: Bool          { ID(bid, .bid).isNaN }
  public var isSignalingNaN: Bool { ID(bid, .bid).isSignalingNaN }
  public var isCanonical: Bool    { ID(bid, .bid).isCanonical }
    public var exponent: Int        { ID(bid, .bid).exponent }
  
  public var significand: Self {
      Self(ID(bid, .bid).significand.asDecimal32(.bid))
//    let (_, _, man, valid) = bid.unpack()
//    if !valid { return self }
//    return Self(bid: ID(expBitPattern: Int(exponentBitPattern),
//                        sigBitPattern: man))
  }
  
  ///////////////////////////////////////////////////////////////////////////
  // MARK: - Floating-point basic operations with rounding
  
  public func adding(other: Self, rounding rule: RoundingRule) -> Self {
    self // Self(bid: ID.add(self.bid, other.bid, rounding: rule))
  }
  
  public mutating func add(other: Self, rounding rule: RoundingRule) {
    // self = self.adding(other: other, rounding: rule)
  }
  
  public mutating func subtract(other: Self, rounding rule: RoundingRule) {
    self = self.subtracting(other: other, rounding: rule)
  }
  
  public func subtracting(other: Self, rounding rule: RoundingRule) -> Self {
      self
//    var negated = other
//    if !other.isNaN { negated.negate() }
//    return self.adding(other: negated, rounding: rule)
  }
  
  public func multiplied(by other: Self, rounding rule: RoundingRule) -> Self {
    self // Self(bid: ID.mul(self.bid, other.bid, rule))
  }
  
  public mutating func multiply(by other: Self, rounding rule: RoundingRule) {
    // self = self.multiplied(by: other, rounding: rule)
  }
  
  public func divided(by other: Self, rounding rule: RoundingRule) -> Self {
    self // Self(bid: ID.div(self.bid, other.bid, rule))
  }
  
  public mutating func divide(by other: Self, rounding rule: RoundingRule) {
    self = self.divided(by: other, rounding: rule)
  }

  ///////////////////////////////////////////////////////////////////////////
  // MARK: - Floating-point basic operations
  
  public static func * (lhs: Self, rhs: Self) -> Self {
    lhs // lhs.multiplied(by: rhs, rounding: .toNearestOrEven)
  }
  
  public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }
  
  public static func / (lhs: Self, rhs: Self) -> Self {
      lhs // lhs.divided(by: rhs, rounding: .toNearestOrEven)
  }
  
  public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }
  
  public mutating func formRemainder(dividingBy other: Self) {
      // bid = ID.rem(self.bid, other.bid)
  }
  
  public mutating func formTruncatingRemainder(dividingBy other: Self) {
    let q = (self/other).rounded(.towardZero)
    self -= q * other
  }
  
  public mutating func formSquareRoot() {
    self.formSquareRoot(rounding: .toNearestOrEven)
  }
  
  public func squareRoot(rounding rule: RoundingRule) -> Self {
      Self.zero // Self(bid: ID.sqrt(sbid, rule))
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
    // bid = ID.fma(lhs.bid, rhs.bid, self.bid, rule)
  }
  
  public func isEqual(to other: Self) -> Bool  { self == other }
  public func isLess(than other: Self) -> Bool { self < other }
  
  public func isLessThanOrEqualTo(_ other: Self) -> Bool {
    isEqual(to: other) || isLess(than: other)
  }
  
    public var magnitude: Self { Self(ID(bid, .bid).magnitude.asDecimal32(.bid)) }
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
      bid = 0
//    bid = ID(sign: sign, expBitPattern: Int(exponentBitPattern),
//             sigBitPattern: ID.RawBitPattern(significandBitPattern))
  }
  
  ///////////////////////////////////////////////////////////////////////////
  // MARK: - Instance properties and attributes
  
  /// The raw encoding of the value's significand field.
  public var significandBitPattern: UInt32 { 0 /* UInt32(bid.sigBitPattern) */ }
  
  /// The raw encoding of the value's exponent field.
  ///
  /// This value is unadjusted by the type's exponent bias.
  public var exponentBitPattern: UInt { 0 /* UInt(bid.expBitPattern) */ }
  
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
//    guard bid.isValid else { return -1 }
//    return _digitsIn(bid.sigBitPattern)
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
