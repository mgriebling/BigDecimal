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

/// Definition of the data storage for the Decimal64 floating-point data type.
/// the `IntDecimal` protocol defines many supporting operations
/// including packing and unpacking of the Decimal64 sign, exponent, and
/// significand fields.  By specifying some key bit positions, it is possible
/// to completely define many of the Decimal64 operations.  The `data` word
/// holds all 64 bits of the Decimal64 data type.
//struct IntDecimal64 : IntDecimal {
//  typealias RawSignificand = UInt64
//  typealias RawData = UInt64
//  typealias RawBitPattern = UInt64
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
//  static var exponentBias:       Int {  398 }
//  static var maxEncodedExponent: Int {  767 }
//  static var maximumDigits:      Int {   16 }
//  static var exponentBits:       Int {   10 }
//
//  static var largestNumber: RawBitPattern { 9_999_999_999_999_999 }
//}

/// Implementation of the 64-bit Decimal64 floating-point operations from
/// IEEE STD 754-2000 for Floating-Point Arithmetic.
///
/// The IEEE Standard 754-2008 for Floating-Point Arithmetic supports two
/// encoding formats: the decimal encoding format, and the binary encoding
/// format. The Intel(R) Decimal Floating-Point Math Library supports primarily
/// the binary encoding format for decimal floating-point values, but the
/// decimal encoding format is supported too in the library, by means of
/// conversion functions between the two encoding formats.
public struct Decimal64 : Codable, Hashable {
  public typealias ID = BigDecimal
  var bid: UInt64
  
  public init(bid: UInt64) { self.bid = bid }
    init(bid: ID)          { self.bid = bid.asDecimal64(.bid) }
}

extension Decimal64 : AdditiveArithmetic {
  public static func - (lhs: Self, rhs: Self) -> Self {
    lhs // lhs.subtracting(rhs, rounding: .toNearestOrEven)
  }
  
    public mutating func negate() { bid = (-ID(bid, .bid)).asDecimal64(.bid) }
  
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs // lhs.adding(to: rhs, rounding: .toNearestOrEven)
  }
  
  public static var zero: Self { Self(bid: ID.zero) }
  
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
//  public init(nan payload: RawSignificand, signaling: Bool) {
//    self.bid = ID.init(nan: payload, signaling: signaling)
//  }
}

//extension Decimal64 : Equatable {
//  public static func == (lhs: Self, rhs: Self) -> Bool {
//    ID.equals(lhs: lhs.bid, rhs: rhs.bid)
//  }
//}
//
//extension Decimal64 : Comparable {
//  public static func < (lhs: Self, rhs: Self) -> Bool {
//    ID.lessThan(lhs: lhs.bid, rhs: rhs.bid)
//  }
//
//  public static func >= (lhs: Self, rhs: Self) -> Bool {
//    ID.greaterOrEqual(lhs: lhs.bid, rhs: rhs.bid)
//  }
//
//  public static func > (lhs: Self, rhs: Self) -> Bool {
//    ID.greaterThan(lhs: lhs.bid, rhs: rhs.bid)
//  }
//}
//
//extension Decimal64 : LosslessStringConvertible {
//  public init?(_ description: String) {
//    if let x:ID=numberFromString(description, round: .toNearestOrEven) {
//      bid = x
//    } else {
//      return nil
//    }
//  }
//}
//
//extension Decimal64 : CustomStringConvertible {
//  public var description: String {
//    string(from: bid)
//  }
//}
//
//extension Decimal64 : ExpressibleByFloatLiteral {
//  public init(floatLiteral value: Double) {
//    self.init(value, rounding: .toNearestOrEven)
//  }
//}
//
//extension Decimal64 : ExpressibleByIntegerLiteral {
//  public init(integerLiteral value: IntegerLiteralType) {
//    if IntegerLiteralType.isSigned {
//      let x = Int(value).magnitude
//      bid = ID.bid(from: UInt64(x), .toNearestOrEven)
//      if value.signum() < 0 { self.negate() }
//    } else {
//      bid = ID.bid(from: UInt64(value), .toNearestOrEven)
//    }
//  }
//}
//
//extension Decimal64 : ExpressibleByStringLiteral {
//  public init(stringLiteral value: StringLiteralType) {
//    bid = numberFromString(value, round: .toNearestOrEven) ?? Self.zero.bid
//  }
//}
//
//extension Decimal64 : Strideable {
//  public func distance(to other: Self) -> Self { other - self }
//  public func advanced(by n: Self) -> Self { self + n }
//}

//extension Decimal64 : FloatingPoint {
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - Initializers for FloatingPoint
//
//  public init(sign: Sign, exponent: Int, significand: Self) {
//    self.bid = ID(sign: sign, expBitPattern: exponent+ID.exponentBias,
//                    sigBitPattern: significand.bid.unpack().sigBits)
//  }
//
//  public mutating func round(_ rule: Rounding) {
//    self.bid = ID.round(self.bid, rule)
//  }
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - DecimalFloatingPoint properties and attributes
//
//  public static var exponentBitCount: Int      {ID.exponentBits}
//  public static var significandDigitCount: Int {ID.maximumDigits}
//  public static var nan: Self                  { Self(bid:ID.nan()) }
//  public static var signalingNaN: Self         { Self(bid:ID.snan) }
//  public static var infinity: Self             { Self(bid:ID.infinite()) }
//
//  public static var greatestFiniteMagnitude: Self {
//    Self(bid:ID(expBitPattern:ID.maxEncodedExponent,
//                sigBitPattern:ID.largestNumber))
//  }
//
//  public static var leastNormalMagnitude: Self {
//    Self(bid:ID(expBitPattern:ID.minEncodedExponent,
//                sigBitPattern:ID.largestNumber))
//  }
//
//  public static var leastNonzeroMagnitude: Self {
//    Self(bid: ID(expBitPattern: ID.minEncodedExponent, sigBitPattern: 1))
//  }
//
//  public static var pi: Self {
//    Self(bid: ID(expBitPattern: ID.exponentBias-ID.maximumDigits+1,
//                   sigBitPattern: 3_141_592_653_589_793))
//  }
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - Instance properties and attributes
//
//  public var ulp: Self            { nextUp - self }
//  public var nextUp: Self         { Self(bid: ID.nextup(self.bid)) }
//  public var sign: Sign           { bid.sign }
//  public var isNormal: Bool       { bid.isNormal }
//  public var isSubnormal: Bool    { bid.isSubnormal }
//  public var isFinite: Bool       { bid.isFinite }
//  public var isZero: Bool         { bid.isZero }
//  public var isInfinite: Bool     { bid.isInfinite && !bid.isNaN }
//  public var isNaN: Bool          { bid.isNaN }
//  public var isSignalingNaN: Bool { bid.isSNaN }
//  public var isCanonical: Bool    { bid.isCanonical }
//  public var exponent: Int        { bid.expBitPattern - ID.exponentBias }
//
//  public var significand: Self {
//    let (_, _, man, valid) = bid.unpack()
//    if !valid { return self }
//    return Self(bid: ID(expBitPattern: Int(exponentBitPattern),
//                        sigBitPattern: man))
//  }
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - Floating-point basic operations with rounding
//
//  public func adding(to other: Self, rounding rule: Rounding) -> Self {
//    Self(bid: ID.add(self.bid, other.bid, rounding: rule))
//  }
//
//  public func subtracting(_ other: Self, rounding rule: Rounding) -> Self {
//    var negated = other
//    if !other.isNaN { negated.negate() }
//    return self.adding(to: negated, rounding: rule)
//  }
//
//  public func multiplying(by other: Self, rounding rule: Rounding) -> Self {
//    Self(bid: ID.mul(self.bid, other.bid, rule))
//  }
//
//  public func dividing(by other: Self, rounding rule: Rounding) -> Self {
//    Self(bid: ID.div(self.bid, other.bid, rule))
//  }
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - Floating-point basic operations
//
//  public static func * (lhs: Self, rhs: Self) -> Self {
//    lhs.multiplying(by: rhs, rounding: .toNearestOrEven)
//  }
//
//  public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }
//
//  public static func / (lhs: Self, rhs: Self) -> Self {
//    lhs.dividing(by: rhs, rounding: .toNearestOrEven)
//  }
//
//  public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }
//
//  public mutating func formRemainder(dividingBy other: Self) {
//    bid = ID.rem(self.bid, other.bid)
//  }
//
//  public mutating func formTruncatingRemainder(dividingBy other: Self) {
//    let q = (self/other).rounded(.towardZero)
//    self -= q * other
//  }
//
//  public mutating func formSquareRoot() {
//    bid = ID.sqrt(self.bid, .toNearestOrEven)
//  }
//
//  /// Rounding method equivalend of the `formSquareRoot`
//  public mutating func formSquareRoot(round: Rounding) {
//    bid = ID.sqrt(self.bid, round)
//  }
//
//  public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
//    self.addProduct(lhs, rhs, round: .toNearestOrEven)
//  }
//
//  /// Rounding method equivalent of the `addProduct`
//  public mutating func addProduct(_ lhs: Self, _ rhs: Self, round: Rounding) {
//    bid = ID.fma(lhs.bid, rhs.bid, self.bid, round)
//  }
//
//  public func isEqual(to other: Self) -> Bool  { self == other }
//  public func isLess(than other: Self) -> Bool { self < other }
//
//  public func isLessThanOrEqualTo(_ other: Self) -> Bool {
//    isEqual(to: other) || isLess(than: other)
//  }
//
//  public var magnitude: Self {
//    var data = bid.data; data.clear(bit: ID.signBit)
//    return Self(bid: data)
//  }
//}

//extension Decimal64 : DecimalFloatingPoint {
//  public typealias RawExponent = UInt
//  public typealias RawSignificand = UInt64
//
//  // public static var rounding = Rounding.toNearestOrEven
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - Initializers for DecimalFloatingPoint
//  //  Conversions to/from binary integer decimal encoding.  These are not part
//  //  of the DecimalFloatingPoint prototype because there's no guarantee that
//  //  an integer type of the same size actually exists (e.g. Decimal128).
//  //
//  //  If we want them in a protocol at some future point, that protocol should
//  //  be "InterchangeFloatingPoint" or "PortableFloatingPoint" or similar, and
//  //  apply to IEEE 754 "interchange types".
//  /// The bit pattern of the value's encoding. A `.bid` encoding value
//  /// indicates a binary integer decimal encoding; while a `.dpd` encoding
//  /// value indicates a densely packed decimal encoding.
//  ///
//  /// The bit patterns are extracted using the `bitPattern` accessors with
//  /// an appropriate `encoding` argument. A new decimal floating point number
//  /// is created by passing an bit pattern to the
//  /// `init(bitPattern:encoding:)` initializers.
//  /// If incorrect bit encodings are used, there are no guarantees about
//  /// the resultant decimal floating point number.
//  ///
//  /// The bit patterns match the decimal interchange format defined by the
//  /// [IEEE 754 specification][spec].
//  ///
//  /// For example, a Decimal32 number has been created with the value "1000.3".
//  /// Using the `bitPattern` accessor with a `.bid` encoding value, a
//  /// 32-bit unsigned integer encoded
//  /// value of `0x32002713` is returned.  The `bitPattern` with a `.dpd`
//  /// encoding value returns the 32-bit unsigned integer encoded value of
//  /// `0x22404003`. Passing these
//  /// numbers to the appropriate initialize recreates the original value
//  /// "1000.3".
//  ///
//  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
//  public func bitPattern(_ encoding: DecimalEncoding) -> RawSignificand {
//    encoding == .bid ? bid.data : bid.dpd
//  }
//
//  public init(bitPattern: RawSignificand, encoding: DecimalEncoding) {
//    if encoding == .bid {
//      bid.data = bitPattern
//    } else {
//      bid = ID(dpd: ID.RawData(bitPattern))
//    }
//  }
//
//  public init(sign: Sign, exponentBitPattern: RawExponent,
//              significandBitPattern: RawSignificand) {
//    bid = ID(sign: sign, expBitPattern: Int(exponentBitPattern),
//             sigBitPattern: ID.RawBitPattern(significandBitPattern))
//  }
//
//  ///////////////////////////////////////////////////////////////////////////
//  // MARK: - Instance properties and attributes
//
//  public var significandBitPattern: UInt64 { UInt64(bid.sigBitPattern) }
//  public var exponentBitPattern: UInt      { UInt(bid.expBitPattern) }
//
//  public var significandDigitCount: Int {
//    guard bid.isValid else { return -1 }
//    return _digitsIn(bid.sigBitPattern)
//  }
//
//  public var decade: Self {
//    guard bid.isValid else { return self } // For infinity, Nan, sNaN
//    return Self(bid: ID(expBitPattern: bid.expBitPattern, sigBitPattern: 1))
//  }
//}
