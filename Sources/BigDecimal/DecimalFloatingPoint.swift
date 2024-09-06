/**
Copyright © 2023 Computer Inspirations. All rights reserved.
Portions are Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors

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

public typealias IntRange = ClosedRange<Int>

protocol DecimalType : Codable, Hashable, Sendable {
    
    associatedtype RawData : UnsignedInteger & FixedWidthInteger
    associatedtype RawBitPattern : UnsignedInteger & FixedWidthInteger
    associatedtype RawSignificand : UnsignedInteger & FixedWidthInteger
    
    /// Storage of the Decimal number in a raw binary integer decimal
    /// encoding as per IEEE STD 754-2019
    var bid: RawData { get set }
    
    //////////////////////////////////////////////////////////////////
    /// Initializers
    
    /// Initialize with a raw data word
    init(_ word: RawData)
    
    /// Initialize with sign, biased exponent, and unsigned significand
    init(sign: Sign, exponentBitPattern: Int,
         significandBitPattern: RawSignificand)
    
    /// Creates a NaN ("not a number") value with the specified payload.
    ///
    /// NaN values compare not equal to every value, including themselves. Most
    /// operations with a NaN operand produce a NaN result. Don't use the
    /// equal-to operator (`==`) to test whether a value is NaN. Instead, use
    /// the value's `isNaN` property.
    ///
    ///     let x = Decimal32(nan: 0, signaling: false, sign: .plus)
    ///     print(x == .nan)
    ///     // Prints "false"
    ///     print(x.isNaN)
    ///     // Prints "true"
    ///
    /// - Parameters:
    ///   - payload: The payload to use for the new NaN value.
    ///   - signaling: Pass `true` to create a signaling NaN or `false` to
    ///     create a quiet NaN.
    ///   - sign: Sets the sign bit in the number when `.minus`.
    init(nan payload: RawSignificand, signaling: Bool, sign: Sign)
    
    //////////////////////////////////////////////////////////////////
    /// Essential data to extract or update from the fields
    
    /// Sign of the number
    var sign: Sign { get set }
    
    //  /// Encoded unsigned exponent of the number
    //  var expBitPattern: Int { get }
    //
    //  /// Encoded unsigned binary integer decimal significand of the number
    //  var sigBitPattern: RawBitPattern { get }
    
    /// Setting requires both the significand and exponent so that a
    /// decision can be made on whether the significand is small or large.
    // mutating func set(exponent: Int, sigBitPattern: RawBitPattern)
    
    //////////////////////////////////////////////////////////////////
    /// Special number definitions
    //  static var snan: Self { get }
    //
    //  static func zero(_ sign: Sign) -> Self
    //  static func nan(_ sign: Sign, _ payload: RawSignificand) -> Self
    // static func infinite(_ sign: Sign) -> Self
    // static func max(_ sign: Sign) -> Self
    
    //////////////////////////////////////////////////////////////////
    /// Decimal number definitions
    static var signBit: Int { get }
    static var specialBits: IntRange { get }
    
    static var exponentBias: Int  { get }
    static var exponentBits: Int  { get }
    static var maxExponent: Int   { get }
    static var minExponent: Int   { get }
    static var maxDigits: Int     { get }
    
    static var largestNumber: RawBitPattern { get }
    
    // For large significand
    static var exponentLMBits: IntRange { get }
    static var largeSignificandBits: IntRange { get }
    
    // For small significand
    static var exponentSMBits: IntRange { get }
    static var smallSignificandBits: IntRange { get }
}

/// A radix-10 (decimal) floating-point type.
///
/// The ``DecimalFloatingPoint`` protocol extends the `FloatingPoint` protocol
/// with operations specific to floating-point decimal types, as defined by the
/// [IEEE 754 specification][spec]. ``DecimalFloatingPoint`` is implemented in
/// the standard library by ``Decimal32``, ``Decimal64``, and ``Decimal128``
/// where available.
///
/// [spec]: https://ieeexplore.ieee.org/servlet/opac?punumber=8766227
public protocol DecimalFloatingPoint : FloatingPoint {
  
  /// A type that represents the encoded significand of a value.
  associatedtype RawSignificand: BinaryInteger
  
  /// Creates a new instance from the specified sign and bit patterns.
  ///
  /// The values passed as `exponentBitPattern` is interpreted in the
  /// decimal interchange format defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: https://ieeexplore.ieee.org/servlet/opac?punumber=8766227
  ///
  /// The `significandBitPattern` are the big-endian, integer decimal digits
  /// of the number.  For example, the integer number `314` represents a
  /// significand of `314`.
  ///
  /// - Parameters:
  ///   - sign: The sign of the new value.
  ///   - exponentBitPattern: The bit pattern to use for the exponent field of
  ///     the new value.
  ///   - significandBitPattern: Bit pattern to use for the significand field
  ///     of the new value.
  init(sign:Sign, exponentBitPattern:Int, significandBitPattern:RawSignificand)
  
  /// Creates a new instance from the given value, rounded to the closest
  /// possible representation.
  ///
  /// If two representable values are equally close, the result is the value
  /// with more trailing zeros in its significand bit pattern.
  ///
  /// - Parameter value: A floating-point value to be converted.
  init<Source:DecimalFloatingPoint>(_ value: Source)
  
  /// Creates a new instance from the given value, if it can be represented
  /// exactly.
  ///
  /// If the given floating-point value cannot be represented exactly, the
  /// result is `nil`. A value that is NaN ("not a number") cannot be
  /// represented exactly if its payload cannot be encoded exactly.
  ///
  /// - Parameter value: A floating-point value to be converted.
  init?<Source:DecimalFloatingPoint>(exactly value: Source)
  
  /// The number of bits used to represent the type's exponent.
  static var exponentBitCount: Int { get }
  
  /// The available number of significand digits.
  ///
  /// For fixed-width decimal floating-point types, this is the actual number
  /// of significand digits.
  ///
  /// For extensible decimal floating-point types, `significandDigitCount`
  /// should be the maximum allowed significand width (both fractional and
  /// integral) digits of the significand. If there is no upper limit, then
  /// `significandDigitCount` should be `Int.max`.
  static var significandDigitCount: Int { get }
  
  /// The raw encoding of the value's exponent field.
  ///
  /// This value is unadjusted by the type's exponent bias.
  var exponentBitPattern: Int { get }
  
  /// The raw binary integer decimal encoding of the value's significand field.
  var significandBitPattern: RawSignificand { get }
  
  /// The floating-point value with the same sign and exponent as this value,
  /// but with a significand of 1.0.
  ///
  /// A *decade* is a set of decimal floating-point values that all have the
  /// same sign and exponent. The `decade` property is a member of the same
  /// decade as this value, but with a unit significand.
  ///
  /// In this example, `x` has a value of `21.5`, which is stored as
  /// `2.15 * 10**1`, where `**` is exponentiation. Therefore, `x.decade` is
  /// equal to `1.0 * 10**1`, or `10.0`.
  ///```
  /// let x = 21.5
  /// // x.significand == 2.15
  /// // x.exponent == 1
  ///
  /// let y = x.decade
  /// // y == 10.0
  /// // y.significand == 1.0
  /// // y.exponent == 1
  ///```
  var decade: Self { get }
  
  /// The number of digits required to represent the value's significand.
  ///
  /// If this value is a finite nonzero number, `significandDigitCount` is the
  /// number of decimal digits required to represent the value of
  /// `significand`; otherwise, `significandDigitCount` is -1. The value of
  /// `significandDigitCount` is always -1 or from one to the
  /// `significandMaxDigitCount`. For example:
  ///
  /// - For any representable power of ten, `significandDigitCount` is one,
  ///   because significand` is `1`.
  /// - If `x` is 10, `x.significand` is `10` in decimal, so
  ///   `x.significandDigitCount` is 2.
  /// - If `x` is Decimal32.pi, `x.significand` is `3.141593` in
  ///   decimal, and `x.significandDigitCount` is 7.
  var significandDigitCount: Int { get }
}

/// Free functionality when complying with DecimalType
extension DecimalType {
    
    static var highSignificandBit: RawBitPattern {
        RawBitPattern(1) << exponentLMBits.lowerBound
    }
    
    static var largestSignificand: RawBitPattern { (largestNumber+1)/10 }
    
    @inlinable static func infinite(_ s: Sign = .plus) -> RawSignificand {
        if s == .minus { return negative | infinite }
        return infinite
    }
    
    @inlinable static func max<T:BinaryFloatingPoint>(_ s:Sign) -> T {
        s == .minus ? -T.greatestFiniteMagnitude : .greatestFiniteMagnitude
    }
    
    @inlinable static func dzero<T:BinaryFloatingPoint>(_ s:Sign) -> T {
        s == .minus ? -T.zero : .zero
    }
    
    @inlinable static func inf<T:BinaryFloatingPoint>(_ s:Sign) -> T {
        s == .minus ? -T.infinity : .infinity
    }
    
    // Doesn't change for the different types of Decimals
    static var minExponent: Int { -exponentBias }
    
    /// These bit fields can be predetermined just from the size of
    /// the number type `RawDataFields` `bitWidth`
    static var maxBit: Int              { RawData.bitWidth - 1 }
    static var signBit: Int             { maxBit }
    static var specialBits: IntRange    { maxBit-2 ... maxBit-1 }
    static var nanBitRange: IntRange    { maxBit-6 ... maxBit-1 }
    static var infBitRange: IntRange    { maxBit-5 ... maxBit-1 }
    static var nanClearRange: IntRange  { 0 ... maxBit-7 }
    static var g6tog10Range: IntRange   { maxBit-11 ... maxBit-7 }
    
    static var exponentLMBits: IntRange { maxBit-exponentBits ... maxBit-1 }
    static var exponentSMBits: IntRange { maxBit-exponentBits-2 ... maxBit-3 }
    
    // Two significand sizes must be supported
    static var largeSignificandBits: IntRange { 0...maxBit-exponentBits-1 }
    static var smallSignificandBits: IntRange { 0...maxBit-exponentBits-3 }
    
    // masks for clearing bits
    static var sNanRange: IntRange      { 0 ... maxBit-6 }
    static var sInfinityRange: IntRange { 0 ... maxBit-5 }
    
    static func nanQuiet(_ x:RawBitPattern) -> Self {
        Self(RawData(x.clearing(bit:nanBitRange.lowerBound)))
    }
    
    /// bit field definitions for DPD numbers
    static var lowMan: Int    { smallSignificandBits.upperBound }
    static var upperExp1: Int { exponentSMBits.upperBound }
    static var upperExp2: Int { exponentLMBits.upperBound }
    
    static var expUpper: IntRange { lowMan+1...lowMan+6 }
    static var expLower: IntRange { lowMan...maxBit-6 }
    static var manLower: IntRange { 0...lowMan-1 }
    
    /// Bit patterns prefixes for special numbers
    static var nanPattern: Int      { 0b1_1111_0 }
    static var snanPattern: Int     { 0b1_1111_1 }
    static var infinitePattern: Int { 0b1_1110 }
    static var specialPattern: Int  { 0b11 }
    
    static var trailingPattern: Int { 0x3ff }
    
    typealias Sig = RawSignificand
    
    static var negative : Sig { Sig(1) << signBit }
    static var infinite : Sig { Sig(infinitePattern) << infBitRange.lowerBound}
    static var nanMask  : Sig { Sig(nanPattern) << nanBitRange.lowerBound }
    static var special  : Sig { Sig(specialPattern) << specialBits.lowerBound }
    
    public init?(_ s: String, rounding rule: RoundingRule = .toNearestOrEven) {
        self.init(0)
        let big = BigDecimal(s).round(Rounding(rule, Self.maxDigits))
        if Self.self == Decimal32.self {
            bid = RawData(big.asDecimal32(.bid))
        } else if Self.self == Decimal64.self {
            bid = RawData(big.asDecimal64(.bid))
        } else if Self.self == Decimal128.self {
            bid = RawData(big.asDecimal128(.bid))
        } else {
            return nil
        }
    }

    public init(nan payload: RawSignificand, signaling: Bool,
                sign: Sign = .plus) {
        let pattern = signaling ? Self.snanPattern : Self.nanPattern
        let man = payload > Self.largestNumber/10 ? 0 : RawBitPattern(payload)
        self.init(0)
        set(exponent: pattern<<(Self.exponentBits-6), sigBitPattern: man)
        self.sign = sign
    }
    
    /// Initialize from a BigDecimal
    init(_ value: BigDecimal) {
        let max = BigDecimal(BInt(Self.largestNumber), Self.maxExponent)
        let sign = value.sign
        if value.isNaN || value.isSignalingNaN {
            if let load = value.digits.asInt() {
                self.init(nan: RawSignificand(load),
                          signaling: value.isSignalingNaN, sign: sign)
            } else {
                self.init(nan: 0, signaling: value.isSignalingNaN, sign: sign)
            }
        } else if value.isInfinite {
            let x = Self.infinite(sign)
            self.init(RawData(x))
        } else if value.abs > max {
            self.init(nan: 0, signaling: false)
        } else {
            let round = Rounding(.toNearestOrEven, Self.maxDigits)
            let w = round.round(value).abs
            var exp = Self.exponentBias + w.exponent
            var sig = RawSignificand(w.digits)
            while exp > Self.exponentBias + Self.maxExponent {
                exp -= 1; sig *= 10
            }
            while exp < 0 {
                exp += 1; sig /= 10
            }
            if sig > Self.largestNumber { sig = 0 }
            self.init(sign: sign, exponentBitPattern: exp,
                      significandBitPattern: sig)
        }
    }
    
    @inlinable var isSpecial: Bool {
        bid.get(range: Self.specialBits) == Self.specialPattern
    }
    
    @inlinable var nanBits: Int { bid.getInt(range: Self.nanBitRange) }
    
    @inlinable var isNaNInf: Bool {
      nanBits & Self.nanPattern == Self.infinitePattern<<1
    }
    
    // Note: Should detect both Nan and SNan
    public var isNaN: Bool  {
        return nanBits & Self.snanPattern == Self.nanPattern
    }
    
    public var isSignalingNaN: Bool {
        nanBits & Self.snanPattern == Self.snanPattern
    }
    
    public var isFinite: Bool {
      let infinite = Self.infinitePattern
      let data = bid.getInt(range: Self.signBit-5...Self.signBit-1)
      return (data & infinite != infinite)
    }
    
    @inlinable public var isInfinite: Bool {
      let data = bid.getInt(range: Self.infBitRange)
      return (data & Self.infinitePattern) == Self.infinitePattern
    }
    
    @inlinable var isValid: Bool {
      if isNaN { return false }
      if isSpecial {
        if isInfinite { return false }
        if significandBitPattern > Self.largestNumber ||
           significandBitPattern == 0 { return false }
      } else {
        if significandBitPattern == 0 { return false }
      }
      return true
    }
    
    public var isCanonical: Bool {
      if isNaN {
        if (bid & 0x01f0 << (Self.maxBit - 16)) != 0 {
          return false
        } else if bid.get(range:Self.manLower) > Self.largestNumber/10 {
          return false
        } else {
          return true
        }
      } else if isInfinite {
        return bid.get(range:0...Self.exponentLMBits.lowerBound+2) == 0
      } else if isSpecial {
        return significandBitPattern <= Self.largestNumber
      } else {
        return true
      }
    }
    
    /// Return `self's` pieces all at once with biased exponent
    func unpack() -> (sign:Sign, exp:Int, sigBits:RawBitPattern, valid:Bool) {
      var exponent: Int, sigBits: RawBitPattern
      if isSpecial {
        if isInfinite {
          sigBits = RawBitPattern(bid).clearing(range:Self.g6tog10Range)
          if bid.get(range: Self.manLower) >= Self.largestSignificand {
            sigBits = RawBitPattern(bid).clearing(range: Self.sNanRange)
          }
          if isNaNInf {
            sigBits = RawBitPattern(bid).clearing(range: Self.sInfinityRange)
          }
          return (self.sign, 0, sigBits, false)
        }
        // small significand
        exponent = bid.getInt(range: Self.exponentSMBits)
        sigBits = RawBitPattern(bid.get(range: Self.smallSignificandBits)) +
                            Self.highSignificandBit
        if sigBits > Self.largestNumber { sigBits = 0 }
        return (self.sign, exponent, sigBits, sigBits != 0)
      } else {
        // large significand
        exponent = bid.getInt(range: Self.exponentLMBits)
        sigBits = RawBitPattern(bid.get(range: Self.largeSignificandBits))
        return (self.sign, exponent, sigBits, sigBits != 0)
      }
    }
    
    /// Return `dpd` pieces all at once
    static func unpack(dpd: RawSignificand) ->
            (sign: Sign, exponent: Int, high: Int, trailing: RawBitPattern) {
      let sgn = dpd.get(bit: signBit) == 1 ? Sign.minus : .plus
      var exponent, high: Int, trailing: RawBitPattern
      let expRange2: IntRange
      
      if dpd.get(range: specialBits) == specialPattern {
        // small significand
        expRange2 = (upperExp1-1)...upperExp1
        high = dpd.get(bit: upperExp1-2) + 8
      } else {
        // large significand
        expRange2 = (upperExp2-1)...upperExp2
        high = dpd.getInt(range: upperExp1-2...upperExp1)
      }
      exponent = dpd.getInt(range: expLower) +
                      dpd.getInt(range: expRange2) << (exponentBits-2)
      trailing = RawBitPattern(dpd.get(range: 0...lowMan-1))
      return (sgn, exponent, high, trailing)
    }
    
    /// Algorithm to decode a 10-bit portion of a densely-packed decimal
    /// number into a corresponding integer. The strategy here is the break
    /// the decoding process into a number of smaller code spaces used to
    /// calculate the corresponding integral number.
    ///
    /// This algorithm may be sped up by replacement with a table lookup as in
    /// the original code. Tests have verified that this algorithm exactly
    /// reproduces the original table.
    static func intFrom(dpd: Int) -> Int {
      precondition(dpd >= 0 && dpd < 1024, "Illegal dpd decoding input")
      func get(_ range: IntRange) -> Int { dpd.get(range: range) }
      
      // decode the 10-bit dpd number
      let select = (dpd.get(bit:3), get(1...2), get(5...6))
      let bit0 = dpd.get(bit:0), bit4 = dpd.get(bit:4), bit7 = dpd.get(bit:7)
      switch select {
        // this case covers about 50% of the numbers
        case (0, _, _):
          return get(7...9)*100 + get(4...6)*10 + get(0...2)
          
        // following 3 cases cover 37.5% of the numbers
        case (1, 0b00, _):
          return get(7...9)*100 + get(4...6)*10 + bit0 + 8
        case (1, 0b01, _):
          return get(7...9)*100 + (bit4 + 8)*10 + get(5...6)<<1 + bit0
        case (1, 0b10, _):
          return (bit7 + 8)*100 + get(4...6)*10 + get(8...9)<<1 + bit0
          
        // next 3 cases cover another 9.375% of the numbers
        case (1, 0b11, 0b00):
          return (bit7 + 8)*100 + (bit4 + 8)*10 + get(8...9)<<1 + bit0
        case (1, 0b11, 0b01):
          return (bit7 + 8)*100 + (get(8...9)<<1 + bit4)*10 + bit0 + 8
        case (1, 0b11, 0b10):
          return get(7...9)*100 + (bit4 + 8)*10 + bit0 + 8
          
        // final case covers remaining 3.125% of the numbers
        default:
          return (bit7 + 8)*100 + (bit4 + 8)*10 + bit0 + 8
      }
    }
    
    /// Algorithm to encode a 12-bit bcd integer (3 digits) into a
    /// densely-packed decimal. This is the inverse of the `intFrom(dpd:)`.
    ///
    /// This algorithm may be sped up by replacement with a table lookup as in
    /// the original code. Tests have verified that this algorithm exactly
    /// reproduces the original code table.
    static func intToDPD(_ n: Int) -> Int {
      precondition(n >= 0 && n < 1000, "Illegal dpd encoding input")
      
      let hundreds = (n / 100) % 10
      let tens = (n / 10) % 10
      let ones = n % 10
      var res = 0
      
      func setBits4to6() { res.set(range:4...6, with: tens) }
      func setBits7to9() { res.set(range:7...9, with: hundreds) }
      
      func setBit0() { res.set(bit:0, with: ones) }
      func setBit4() { res.set(bit:4, with: tens) }
      func setBit7() { res.set(bit:7, with: hundreds) }
    
      switch (hundreds>7, tens>7, ones>7) {
        case (false, false, false):
          setBits7to9(); setBits4to6(); res.set(range: 0...2, with: ones)
        case (false, false, true):
          res = 0b1000  // base encoding
          setBits7to9(); setBits4to6(); setBit0()
        case (false, true, false):
          res = 0b1010  // base encoding
          setBits7to9(); setBit4(); res.set(range:5...6, with:ones>>1); setBit0()
        case (true, false, false):
          res = 0b1100  // base encoding
          setBits4to6(); res.set(range:8...9, with:ones>>1); setBit7(); setBit0()
        case (true, true, false):
          res = 0b1110  // base encoding
          setBit7(); setBit4(); res.set(range:8...9, with:ones>>1); setBit0()
        case (true, false, true):
          res = 0b010_1110  // base encoding
          setBit7(); res.set(range: 8...9, with: tens>>1); setBit4(); setBit0()
        case (false, true, true):
          res = 0b100_1110  // base encoding
          setBits7to9(); setBit4(); setBit0()
        default:
          res = 0b110_1110 // base encoding
          setBit7(); setBit4(); setBit0()
      }
      return res
    }
    
    /// Create a new BID number from the `dpd` DPD number.
    static func getBID(from dpd: RawSignificand) -> RawSignificand {
        // Convert the dpd number to a bid number
        var (sign, exp, high, trailing) = Self.unpack(dpd: dpd)
        var nan = false
        let nanValue = dpd.getInt(range: Self.nanBitRange)
        if (nanValue & Self.nanPattern) == (Self.infinitePattern << 1) {
            return Self.infinite(sign)
        } else if (nanValue & Self.nanPattern) == Self.nanPattern {
            nan = true; exp = 0
        }
        
        let mask = RawSignificand(Self.trailingPattern)
        let mils = ((Self.maxDigits - 1) / 3) - 1
        let shift = mask.bitWidth - mask.leadingZeroBitCount
        var mant = RawSignificand(high)
        for i in stride(from: shift*mils, through: 0, by: -shift) {
            mant *= 1000
            let value = Int((RawSignificand(trailing) >> i) & mask)
            mant += RawSignificand(Self.intFrom(dpd: value))
        }
        
        if nan {
            return RawSignificand(Self(nan: mant, signaling: false).bid)
        } else {
            let value = Self(sign: sign, exponentBitPattern: exp,
                             significandBitPattern: mant)
            return RawSignificand(value.bid)
        } // (sign: sign, expBitPattern: exp, sigBitPattern: mant) }
    }
    
    /// Convert `self` to a DPD number.
    var dpd: RawSignificand {
        var res : RawSignificand = 0
        var (sign, exp, significand, _) = unpack()
        var trailing = significand.get(range: Self.manLower) // & 0xfffff
        var nanb = false
        
        if self.isNaNInf {
            return Self.infinite(sign)
        } else if self.isNaN {
            if trailing > Self.largestNumber/10 {
                trailing = 0
            }
            significand = Self.RawBitPattern(trailing); exp = 0; nanb = true
        } else {
            if significand > Self.largestNumber { significand = 0 }
        }
        
        let mils = ((Self.maxDigits - 1) / 3) - 1
        let shift = 10
        var dmant = RawSignificand(0)
        for i in stride(from: 0, through: shift*mils, by: shift) {
            dmant |= RawSignificand(Self.intToDPD(Int(significand % 1000))) << i
            significand /= 1000
        }
        
        let signBit = Self.signBit
        let expLower = Self.smallSignificandBits.upperBound...signBit-6
        let manLower = 0...Self.smallSignificandBits.upperBound-1
        
        if significand >= 8 {
            let expUpper = signBit-4...signBit-3
            let manUpper = signBit-5...signBit-5
            res.set(range: Self.specialBits, with: Self.specialPattern)
            res.set(range: expUpper, with: exp >> (Self.exponentBits-2))
            res.set(range: manUpper, with: Int(significand) & 1)
        } else {
            let expUpper = signBit-2...signBit-1
            let manUpper = signBit-5...signBit-3
            res.set(range: expUpper, with: exp >> (Self.exponentBits-2))
            res.set(range: manUpper, with: Int(significand))
        }
        res.set(bit: signBit, with: sign.rawValue)
        res.set(range: expLower, with: exp)
        res.set(range: manLower, with: dmant)
        if nanb { res.set(range: Self.nanBitRange, with: Self.nanPattern) }
        return res
    }
    
    /// if exponent < `minEncodedExponent`, the number may be subnormal
    private func checkNormalScale(_ exp: Int, _ mant: RawBitPattern) -> Bool {
        if exp < Self.minExponent+Self.maxDigits-1 {
            let tenPower = BInt(_power(10, to: exp))
            let mantPrime = BInt(mant) * tenPower
            return mantPrime > Self.largestNumber/10 // normal test
        }
        return true // normal
    }
    
    public var isNormal: Bool {
      let (_, exp, mant, valid) = self.unpack()
      if !valid { return false }
      return checkNormalScale(exp, mant)
    }
    
    public var isSubnormal: Bool {
      let (_, exp, mant, valid) = self.unpack()
      if !valid { return false }
      return !checkNormalScale(exp, mant)
    }
    
    public var isZero: Bool {
      if isInfinite { return false }
      if isSpecial {
        return significandBitPattern > Self.largestNumber
      } else {
        return significandBitPattern == 0
      }
    }
    
    public static var exponentBitCount:Int      { exponentBits }
    public static var significandDigitCount:Int { Self.maxDigits }
    public static var nan:Self                  { Self(nan:0,signaling:false) }
    public static var signalingNaN:Self         { Self(nan:0,signaling:true) }
    
    @inlinable public var sign: Sign {
        get { Sign(rawValue: bid.get(bit: Self.signBit))! }
        set { bid.set(bit: Self.signBit, with: newValue.rawValue) }
    }
    
    /// The raw encoding of the value's exponent field.
    ///
    /// This value is unadjusted by the type's exponent bias.
    @inlinable public var exponentBitPattern: Int {
        let range = isSpecial ? Self.exponentSMBits : Self.exponentLMBits
        return bid.getInt(range: range)
    }
    
    @inlinable public var significandBitPattern: RawBitPattern {
        let range = isSpecial ? Self.smallSignificandBits
        : Self.largeSignificandBits
        if isSpecial {
            return RawBitPattern(bid.get(range:range)) + Self.highSignificandBit
        } else {
            return RawBitPattern(bid.get(range:range))
        }
    }
    
    /// Note: `exponent` is assumed to be biased
    mutating func set(exponent: Int, sigBitPattern: RawBitPattern) {
      if sigBitPattern < Self.highSignificandBit {
        // large significand
        bid.set(range: Self.exponentLMBits, with: exponent)
        bid.set(range: Self.largeSignificandBits, with: sigBitPattern)
      } else {
        // small significand
        bid.set(range:Self.exponentSMBits, with: exponent)
        bid.set(range:Self.smallSignificandBits,
                 with:sigBitPattern-Self.highSignificandBit)
        bid.set(range:Self.specialBits, with: Self.specialPattern)
      }
    }
}

extension DecimalFloatingPoint {
  
  /// The radix, or base of exponentiation, for a floating-point type.
  ///
  /// The magnitude of a floating-point value `x` of type `F` can be calculated
  /// by using the following formula, where `**` is exponentiation:
  ///
  ///     let magnitude = x.significand * F.radix ** x.exponent
  ///
  /// A conforming type may use any integer radix, but values other than 2 (for
  /// binary floating-point types) or 10 (for decimal floating-point types)
  /// are extraordinarily rare in practice.
  @inlinable public static var radix: Int { 10 }
  
  /// Creates a new floating-point value using the sign of one value and the
  /// magnitude of another.
  ///
  /// The following example uses this initializer to create a new `Double`
  /// instance with the sign of `a` and the magnitude of `b`:
  ///
  ///     let a = -21.5
  ///     let b = 305.15
  ///     let c = Decimal32(signOf: a, magnitudeOf: b)
  ///     print(c)
  ///     // Prints "-305.15"
  ///
  /// This initializer implements the IEEE 754 `copysign` operation.
  ///
  /// - Parameters:
  ///   - signOf: A value from which to use the sign. The result of the
  ///     initializer has the same sign as `signOf`.
  ///   - magnitudeOf: A value from which to use the magnitude. The result of
  ///     the initializer has the same magnitude as `magnitudeOf`.
  @inlinable public init(signOf: Self, magnitudeOf: Self) {
    self.init(
      sign: signOf.sign,
      exponentBitPattern: magnitudeOf.exponentBitPattern,
      significandBitPattern: magnitudeOf.significandBitPattern
    )
  }
  
  public // @testable
  static func _convert<Source: DecimalFloatingPoint>(from source: Source) ->
  (value: Self, exact: Bool) {
    let isMinus = source.sign == .minus
    guard source.isFinite else {
      if source.isInfinite { return (isMinus ? -infinity : infinity, true) }
      
      // IEEE 754 requires that any NaN payload be propagated, if possible.
      let c = source.significandBitPattern
      let maxNaNBit = c.bitWidth - 4 - Source.exponentBitCount
      let nanMask = Source.RawSignificand(1) << maxNaNBit - 1
      var payload = RawSignificand(truncatingIfNeeded: c & nanMask)
      
      // Decimal floating point NaNs are weird, larger bit widths must be
      // scaled up from smaller bit widths and vice-versa.
      let deltaWidth = Self.RawSignificand.zero.bitWidth - c.bitWidth
      var scale: Self.RawSignificand {
        switch abs(deltaWidth) {
          case  0: return 1
          case 32: return 1_000_000_000 // 10^9
          case 64: return 1_000_000_000_000_000_000 // 10^18
          case 96: return 1_000_000_000_000_000_000_000_000_000 // 10^27
          default: assertionFailure("Unknown Decimal Type"); return 1
        }
      }
      if deltaWidth > 0 {
        payload *= scale // scale up the payload
      } else if deltaWidth < 0 {
        payload /= scale // scale down the payload
      }
      if payload > greatestFiniteMagnitude.significandBitPattern/10 {
        payload = 0
      }
      
      // sNan is cleared according to Intel documents
      let value = Self(
        sign: source.sign,
        exponentBitPattern: nan.exponentBitPattern,
        significandBitPattern: payload | nan.significandBitPattern)
      // We define exactness by equality after roundtripping; since NaN is
      // never equal to itself, it can never be converted exactly.
      return (value, false)
    }
    
    let exponent = source.exponent
    var exemplar = Self.leastNormalMagnitude
    let exponentBitPattern: Int
    var significand = source.significandBitPattern
    
    if exponent < exemplar.exponent {
      // The floating-point result is either zero or subnormal.
      exemplar = Self.leastNonzeroMagnitude
      let minExponent = exemplar.exponent
      if exponent + 1 < minExponent {
        return (isMinus ? -zero : zero, false)
      }
      if _slowPath(exponent + 1 == minExponent) {
        return source.significandDigitCount == 0
        ? (isMinus ? -zero : zero, false)
        : (isMinus ? -exemplar : exemplar, false)
      }
      
      exponentBitPattern = 0
    } else {
      // The floating-point result is either normal or infinite.
      exemplar = Self.greatestFiniteMagnitude
      if exponent > exemplar.exponent {
        return (isMinus ? -.infinity : .infinity, false)
      }
      if significand > Source.greatestFiniteMagnitude.significandBitPattern {
        significand = 0
      }
      let bias = Int(Self.zero.exponentBitPattern)
      exponentBitPattern = Int(exponent) + bias
    }
    
    let value = Self (
      sign: source.sign,
      exponentBitPattern: exponentBitPattern,
      significandBitPattern: RawSignificand(significand))
    
    if source.significandDigitCount <= Self.significandDigitCount {
      return (value, true)
    }
    
    // Numbers are rounded automatically during init so nothing else to see here
    return (value, false)
  }
  
  /// Creates a new instance from the given value, rounded to the closest
  /// possible representation.
  ///
  /// If two representable values are equally close, the result is the value
  /// with more trailing zeros in its significand bit pattern.
  ///
  /// - Parameter value: A decimal floating-point value to be converted.
  @inlinable public init<Source:DecimalFloatingPoint>(_ value: Source) {
    self = Self._convert(from: value).value
  }
  
  /// Creates a new instance from the given value, if it can be represented
  /// exactly.
  ///
  /// If the given floating-point value cannot be represented exactly, the
  /// result is `nil`.
  ///
  /// - Parameter value: A floating-point value to be converted.
  public init?<Source:DecimalFloatingPoint>(exactly value: Source) {
    if value.isNaN { return nil }
    let (value, exact) = Self._convert(from: value)
    if exact { self = value; return }
    return nil
  }
  
  /// Creates a new instance from the given value, rounded to the closest
  /// possible representation.
  ///
  /// If two representable values are equally close, the result is the value
  /// with more trailing zeros in its significand bit pattern.
  ///
  /// - Parameter value: A decimal floating-point value to be converted.
  public init<Source:BinaryFloatingPoint>(_ value:Source, rounding: RoundingRule) {
    self.init(0)
    if let x = value as? Double {
      if Self.self == Decimal32.self {
          self = Self(Decimal32(floatLiteral: x).rounded(rounding))
      } else if Self.self == Decimal64.self {
          self = Self(Decimal64(floatLiteral: x).rounded(rounding))
      } else if Self.self == Decimal128.self {
          self = Self(Decimal128(floatLiteral: x).rounded(rounding))
      }
    }
  }
  
  /// Creates a new instance from the given value, if it can be represented
  /// exactly.
  ///
  /// If the given floating-point value cannot be represented exactly, the
  /// result is `nil`.
  ///
  /// - Parameter value: A floating-point value to be converted.
  public init?<Source:BinaryFloatingPoint>(exactly value: Source) {
    if let x = value as? Double {
      self.init(value, rounding: .toNearestOrEven)
      guard Double(self) == x else { return nil }
      return
    }
    return nil
  }
  
  /// Returns a Boolean value indicating whether this instance should precede
  /// or tie positions with the given value in an ascending sort.
  ///
  /// This relation is a refinement of the less-than-or-equal-to operator
  /// (`<=`) that provides a total order on all values of the type, including
  /// signed zeros and NaNs.
  ///
  /// The following example uses `isTotallyOrdered(belowOrEqualTo:)` to sort an
  /// array of floating-point values, including some that are NaN:
  ///
  ///     var numbers = [2.5, 21.25, 3.0, .nan, -9.5]
  ///     numbers.sort { !$1.isTotallyOrdered(belowOrEqualTo: $0) }
  ///     print(numbers)
  ///     // Prints "[-9.5, 2.5, 3.0, 21.25, nan]"
  ///
  /// The `isTotallyOrdered(belowOrEqualTo:)` method implements the total order
  /// relation as defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: https://ieeexplore.ieee.org/servlet/opac?punumber=8766227
  ///
  /// - Parameter other: A floating-point value to compare to this value.
  /// - Returns: `true` if this value is ordered below or the same as `other`
  ///   in a total ordering of the floating-point type; otherwise, `false`.
  public func isTotallyOrdered(belowOrEqualTo other: Self) -> Bool {
    // Quick return when possible.
    if self < other { return true }
    if self > other { return false }  // bug in original code? "other > self"
    
    // Self and other are either equal or unordered.
    // Every negative-signed value (even NaN) is less than every positive-
    // signed value, so if the signs do not match, we simply return the
    // sign bit of self.
    if sign != other.sign { return sign == .minus }
    
    // Handle Nan and infinity
    if isNaN && !other.isNaN { return false }
    if !isNaN && other.isNaN { return true }
    if isInfinite && !other.isInfinite { return false }
    if !isInfinite && other.isInfinite { return true }
    
    // Sign bits match; look at exponents.
    if exponentBitPattern > other.exponentBitPattern { return sign == .minus }
    if exponentBitPattern < other.exponentBitPattern { return sign == .plus }
    
    // Signs and exponents match, look at significands.
    if significandDigitCount > other.significandDigitCount {
      return sign == .minus
    }
    if significandDigitCount < other.significandDigitCount {
      return sign == .plus
    }
    
    // Same sized significands -- compare them
    if significandBitPattern > other.significandBitPattern {
      return sign == .minus
    }
    if other.significandBitPattern > significandBitPattern {
      return sign == .plus
    }
    //  Sign, exponent, and significand all match.
    return true
  }
}

extension DecimalFloatingPoint where Self.RawSignificand: FixedWidthInteger {
    
  public // @testable
  static func _convert<Source:BinaryInteger>(from source: Source) ->
                                            (value: Self, exact: Bool) {
    // Note: Self's exponent is x10ⁿ where n is the radix 10 exponent whereas
    // Source's exponent is x2ª where a is the radix 2 exponent.
    // Useful constants:
    let exponentBias = Self.zero.exponentBitPattern
    
    //  Zero is really extra simple, and saves us from trying to normalize a
    //  value that cannot be normalized.
    if _fastPath(source == 0) { return (0, true) }
    
    //  We now have a non-zero value; convert it to a strictly positive value
    //  by taking the magnitude.
    // need a x10ⁿ exponent & significand digits
    let exp:Int = _digitsIn(RawSignificand(source.magnitude))
    
    //  If the exponent would be larger than the largest representable
    //  exponent, the result is just an infinity of the appropriate sign.
    guard exp <= Self.greatestFiniteMagnitude.exponent else {
      return (Source.isSigned && source < 0 ? -.infinity : .infinity, false)
    }
    
    //  Rounding occurs automatically based on the number of
    //  significandDigits in the initializer.
    let value = Self(
      sign: Source.isSigned && source < 0 ? .minus : .plus,
      exponentBitPattern: exponentBias,
      significandBitPattern: RawSignificand(source.magnitude)
    )
    return (value, exp <= Self.significandDigitCount)
  }
  
  /// Creates a new value, rounded to the closest possible representation.
  ///
  /// If two representable values are equally close, the result is the value
  /// with more trailing zeros in its significand bit pattern.
  ///
  /// - Parameter value: The integer to convert to a floating-point value.
  @inlinable public init<Source:BinaryInteger>(_ value: Source) {
    self = Self._convert(from: value).value
  }
  
  /// Creates a new value, if the given integer can be represented exactly.
  ///
  /// If the given integer cannot be represented exactly, the result is `nil`.
  ///
  /// - Parameter value: The integer to convert to a floating-point value.
  @inlinable public init?<Source:BinaryInteger>(exactly value: Source) {
    let (value_, exact) = Self._convert(from: value)
    guard exact else { return nil }
    self = value_
  }
  
  /// Returns a random value within the specified range, using the given
  /// generator as a source for randomness.
  ///
  /// Use this method to generate a floating-point value within a specific
  /// range when you are using a custom random number generator. This example
  /// creates three new values in the range `10.0 ..< 20.0`.
  ///
  ///     for _ in 1...3 {
  ///         print(Double.random(in: 10.0 ..< 20.0, using: &myGenerator))
  ///     }
  ///     // Prints "18.1900709259179"
  ///     // Prints "14.2286325689993"
  ///     // Prints "13.1485686260762"
  ///
  /// The `random(in:using:)` static method chooses a random value from a
  /// continuous uniform distribution in `range`, and then converts that value
  /// to the nearest representable value in this type. Depending on the size
  /// and span of `range`, some concrete values may be represented more
  /// frequently than others.
  ///
  /// - Note: The algorithm used to create random values may change in a future
  ///   version of Swift. If you're passing a generator that results in the
  ///   same sequence of floating-point values each time you run your program,
  ///   that sequence may change when your program is compiled using a
  ///   different version of Swift.
  ///
  /// - Parameters:
  ///   - range: The range in which to create a random value.
  ///     `range` must be finite and non-empty.
  ///   - generator: The random number generator to use when creating the
  ///     new random value.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable public static func random<T:RandomNumberGenerator>(
    in range: Range<Self>, using generator: inout T) -> Self {
    precondition(!range.isEmpty, "Can't get random value with an empty range")
    let delta = range.upperBound - range.lowerBound
    //  TODO: this still isn't quite right, because the computation of delta
    //  can overflow (e.g. if .upperBound = .maximumFiniteMagnitude and
    //  .lowerBound = -.upperBound); this should be re-written with an
    //  algorithm that handles that case correctly, but this precondition
    //  is an acceptable short-term fix.
    precondition(delta.isFinite,
                 "There is no uniform distribution on an infinite range")
    let max = UInt(delta.significandBitPattern)
      
    // get a random integer up to the maximum
    let r = generator.next(upperBound: max)
    
    // convert the integer to a Decimal number and scale to delta range
    var d = Self.init(sign: delta.sign, exponent: delta.exponent,
                      significand: Self(r))
    d += range.lowerBound // add the lower bound
    // try again if we failed above
    if d == range.upperBound { return random(in: range, using: &generator) }
    return d
  }
  
  /// Returns a random value within the specified range.
  ///
  /// Use this method to generate a floating-point value within a specific
  /// range. This example creates three new values in the range
  /// `10.0 ..< 20.0`.
  ///
  ///     for _ in 1...3 {
  ///         print(Double.random(in: 10.0 ..< 20.0))
  ///     }
  ///     // Prints "18.1900709259179"
  ///     // Prints "14.2286325689993"
  ///     // Prints "13.1485686260762"
  ///
  /// The `random()` static method chooses a random value from a continuous
  /// uniform distribution in `range`, and then converts that value to the
  /// nearest representable value in this type. Depending on the size and span
  /// of `range`, some concrete values may be represented more frequently than
  /// others.
  ///
  /// This method is equivalent to calling `random(in:using:)`, passing in the
  /// system's default random generator.
  ///
  /// - Parameter range: The range in which to create a random value.
  ///   `range` must be finite and non-empty.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable public static func random(in range: Range<Self>) -> Self {
    var g = SystemRandomNumberGenerator()
    return random(in: range, using: &g)
  }
  
  /// Returns a random value within the specified range, using the given
  /// generator as a source for randomness.
  ///
  /// Use this method to generate a floating-point value within a specific
  /// range when you are using a custom random number generator. This example
  /// creates three new values in the range `10.0 ... 20.0`.
  ///
  ///     for _ in 1...3 {
  ///         print(Double.random(in: 10.0 ... 20.0, using: &myGenerator))
  ///     }
  ///     // Prints "18.1900709259179"
  ///     // Prints "14.2286325689993"
  ///     // Prints "13.1485686260762"
  ///
  /// The `random(in:using:)` static method chooses a random value from a
  /// continuous uniform distribution in `range`, and then converts that value
  /// to the nearest representable value in this type. Depending on the size
  /// and span of `range`, some concrete values may be represented more
  /// frequently than others.
  ///
  /// - Note: The algorithm used to create random values may change in a future
  ///   version of Swift. If you're passing a generator that results in the
  ///   same sequence of floating-point values each time you run your program,
  ///   that sequence may change when your program is compiled using a
  ///   different version of Swift.
  ///
  /// - Parameters:
  ///   - range: The range in which to create a random value. Must be finite.
  ///   - generator: The random number generator to use when creating the
  ///     new random value.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable public static func random<T:RandomNumberGenerator>(
    in range: ClosedRange<Self>, using generator: inout T) -> Self {
    precondition(!range.isEmpty, "Can't get random value with an empty range")
    let delta = range.upperBound - range.lowerBound
    //  TODO: this still isn't quite right, because the computation of delta
    //  can overflow (e.g. if .upperBound = .maximumFiniteMagnitude and
    //  .lowerBound = -.upperBound); this should be re-written with an
    //  algorithm that handles that case correctly, but this precondition
    //  is an acceptable short-term fix.
    precondition(delta.isFinite,
                 "There is no uniform distribution on an infinite range")
    let max = UInt(delta.significandBitPattern)

    // get a random integer up to the maximum
    let r = generator.next(upperBound: max)
    
    // convert the integer to a Decimal number and scale to delta range
    var d = Self.init(
      sign: delta.sign, exponent: Self.Exponent(delta.exponentBitPattern),
      significand: Self.init(r))
    d += range.lowerBound // add the lower bound
    return d
  }
  
  /// Returns a random value within the specified range.
  ///
  /// Use this method to generate a floating-point value within a specific
  /// range. This example creates three new values in the range
  /// `10.0 ... 20.0`.
  ///
  ///     for _ in 1...3 {
  ///         print(Double.random(in: 10.0 ... 20.0))
  ///     }
  ///     // Prints "18.1900709259179"
  ///     // Prints "14.2286325689993"
  ///     // Prints "13.1485686260762"
  ///
  /// The `random()` static method chooses a random value from a continuous
  /// uniform distribution in `range`, and then converts that value to the
  /// nearest representable value in this type. Depending on the size and span
  /// of `range`, some concrete values may be represented more frequently than
  /// others.
  ///
  /// This method is equivalent to calling `random(in:using:)`, passing in the
  /// system's default random generator.
  ///
  /// - Parameter range: The range in which to create a random value.
  ///   Must be finite.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable public static func random(in range: ClosedRange<Self>) -> Self {
    var g = SystemRandomNumberGenerator()
    return random(in: range, using: &g)
  }
}

// Internally-used standard functions

/// Returns the number of decimal digits in `sig`.
func _digitsIn<T:FixedWidthInteger>(_ sig:T) -> Int { _digitsIn(sig).digits }

/// Returns the number of decimal digits and power of 10 in `sig`.
func _digitsIn<T:FixedWidthInteger>(_ sig: T) -> (digits: Int, tenPower: T) {
  // find power of 10 just greater than sig
  let sig = sig.magnitude
  let maxDiv10 = T.max/10
  var pow10 = 10 as T, digits = 1
  while pow10 <= sig {
    digits += 1
    if pow10 < maxDiv10 { pow10 *= 10 }
    else { return (digits, T.max) }
  }
  return (digits, pow10)
}

/// Returns x^exp where x = *num*.
/// - Precondition: x ≥ 0, exp ≥ 0
func _power<T:FixedWidthInteger>(_ num:T, to exp: Int) -> T {
  // Zero raised to anything except zero is zero (provided exponent is valid)
  guard exp >= 0 else { return T.max }
  if num == 0 { return exp == 0 ? 1 : 0 }
  var z = num
  var y : T = 1
  var n = abs(exp)
  while true {
    if !n.isMultiple(of: 2) { y *= z }
    n >>= 1
    if n == 0 { break }
    z *= z
  }
  return y
}
