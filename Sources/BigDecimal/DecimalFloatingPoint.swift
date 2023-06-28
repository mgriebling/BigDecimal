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

/// A radix-10 (decimal) floating-point type.
///
/// The `DecimalFloatingPoint` protocol extends the `FloatingPoint` protocol
/// with operations specific to floating-point decimal types, as defined by the
/// [IEEE 754 specification][spec]. `DecimalFloatingPoint` is implemented in
/// the standard library by `Decimal32`, `Decimal64`, and `Decimal128` where
/// available.
///
/// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
public protocol DecimalFloatingPoint : FloatingPoint {
  
  /// A type that represents the encoded significand of a value.
  associatedtype RawSignificand: UnsignedInteger
  
  /// A type that represents the encoded exponent of a value.
  associatedtype RawExponent : UnsignedInteger
  
  /// Creates a new instance from the specified sign and bit patterns.
  ///
  /// The values passed as `exponentBitPattern` is interpreted in the
  /// decimal interchange format defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
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
  init(sign: Sign, exponentBitPattern: RawExponent,
       significandBitPattern: RawSignificand)
  
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
  var exponentBitPattern: RawExponent { get }
  
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
      if payload > Self.greatestFiniteMagnitude.significandBitPattern/10 {
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
    let exponentBitPattern: Self.RawExponent
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
      
      exponentBitPattern = 0 as Self.RawExponent
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
      exponentBitPattern = RawExponent(Int(exponent) + bias)
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
  public init<Source:BinaryFloatingPoint>(_ value:Source, rounding: Rounding) {
    self.init(0)
      // FIXME: - Use new code
//    if let x = value as? Double {
//      if Self.self == Decimal32.self {
//        self = Self(Decimal32(bid:IntDecimal32.bid(from: x, .toNearestOrEven)))
//      } else if Self.self == Decimal64.self {
//        self = Self(Decimal64(bid:IntDecimal64.bid(from: x, .toNearestOrEven)))
//      } else if Self.self == Decimal128.self {
//        self = Self(Decimal128(bid:IntDecimal128.bid(from:x,.toNearestOrEven)))
//      }
//    }
  }
  
  /// Creates a new instance from the given value, if it can be represented
  /// exactly.
  ///
  /// If the given floating-point value cannot be represented exactly, the
  /// result is `nil`.
  ///
  /// - Parameter value: A floating-point value to be converted.
  public init?<Source:BinaryFloatingPoint>(exactly value: Source) {
      // FIXME: - Use new code
//    if let x = value as? Double {
//      self.init(value, rounding: .toNearestOrEven)
//      guard Double(self) == x else { return nil }
//      return
//    }
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
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
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
    let exp:Int = _digitsIn(Int(source.magnitude))
    
    //  If the exponent would be larger than the largest representable
    //  exponent, the result is just an infinity of the appropriate sign.
    guard exp <= Self.greatestFiniteMagnitude.exponent else {
      return (Source.isSigned && source < 0 ? -.infinity : .infinity, false)
    }
    
    //  Rounding occurs automatically based on the number of
    //  significandDigits in the initializer.
    let value = Self(
      sign: Source.isSigned && source < 0 ? .minus : .plus,
      exponentBitPattern: Self.RawExponent(exponentBias),
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
    var d = Self.init(
      sign: delta.sign, exponent: Self.Exponent(delta.exponentBitPattern),
      significand: Self.init(r))
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
