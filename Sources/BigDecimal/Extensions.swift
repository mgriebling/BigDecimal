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

// import UInt128
import BigInt
import Foundation


extension UInt128 {
    public init(w: [UInt64]) {
        self.init(_low: w[0], _high:w[1])
    }
}

extension FloatingPointSign {
  public var toggle: Sign { self == .minus ? .plus : .minus }
}

// MARK: - Type Extensions

extension BInt {
    func comparedTo(_ x: BInt) -> Int { self < x ? -1 : ( self > x ? 1 : 0 ) }
}

extension Array where Element == Int {
    subscript(i: UInt64) -> UInt64 { UInt64(self[Int(i)]) }
    subscript(i: UInt32) -> UInt32 { UInt32(self[Int(i)]) }
}

extension FloatingPointClassification : Swift.CustomStringConvertible {
  public var description: String {
    switch self {
      case .negativeInfinity: return "Negative Infinity"
      case .negativeNormal: return "Negative Normal"
      case .negativeSubnormal: return "Negative Subnormal"
      case .negativeZero: return "Negative Zero"
      case .positiveInfinity: return "Positive Infinity"
      case .positiveNormal: return "Positive Normal"
      case .positiveSubnormal: return "Positive Subnormal"
      case .positiveZero: return "Positive Zero"
      case .signalingNaN: return "Signaling Nan"
      case .quietNaN: return "Quiet Nan"
    }
  }
}

extension BinaryFloatingPoint {
    @inline(__always)
    public init<T: DecimalFloatingPoint>(_ source: T,
                                    round: RoundingRule = .toNearestOrEven) {
        if Self.self == Double.self {
            let t : Double
            if let x = source as? Decimal32 {
                t = x.bd.asDouble()
            } else if let x = source as? Decimal64 {
                t = x.bd.asDouble()
            } else if let x = source as? Decimal128 {
                t = x.bd.asDouble()
            } else if let x = source as? BigDecimal {
                t = x.asDouble()
            } else {
                t = Double.nan
                assertionFailure("Unknown Decimal Floating Point type \(T.self)")
            }
            self = Self(t)
        } else if Self.self == Float.self {
            let t : Float
            if let x = source as? Decimal32 {
                t = x.bd.asFloat()
            } else if let x = source as? Decimal64 {
                t = x.bd.asFloat()
            } else if let x = source as? Decimal128 {
                t = x.bd.asFloat()
            } else if let x = source as? BigDecimal {
                t = x.asFloat()
            } else {
                t = Float.nan
                assertionFailure("Unknown Decimal Floating Point type \(T.self)")
            }
            self = Self(t)
        } else {
            self = Self.nan
            assertionFailure("Unsupported Binary Floating Point type \(Self.self)")
        }
    }
}

extension FixedWidthInteger {
  @_semantics("optimize.sil.specialize.generic.partial.never")
  public // @testable
  static func _convert<Source: DecimalFloatingPoint>(
    from source: Source) -> (value: Self?, exact: Bool) {
    guard _fastPath(!source.isZero) else { return (0, true) }
    guard _fastPath(source.isFinite) else { return (nil, false) }
    guard Self.isSigned || source > -1 else { return (nil, false) }
    let exponent = Int(source.exponent)
    let destMaxDigits : Int = _digitsIn(Self.max)   // max Self digits
    let digitWidth = source.significandDigitCount  // exact source width
    if _slowPath(digitWidth+exponent > destMaxDigits) {
      return (source.sign == .minus ? Self.min : Self.max, false)
    }
    let isExact = exponent >= 0
    let c = Self(source.significandBitPattern) // all digits
    
    // check for underflow
    if digitWidth + exponent <= 0 { return (0, false) }
    
    // check if the decimal shifting will create overflow
    let result = exponent >= 0
      ? c.multipliedReportingOverflow(by: _power(10, to:exponent))
      : c.dividedReportingOverflow(by: _power(10, to:-exponent))
    if digitWidth + exponent == destMaxDigits {
      if result.overflow {
        return (source.sign == .minus ? Self.min : Self.max, false)
      }
    }

    let magnitude = result.partialValue
    return (
      Self.isSigned && source < 0 ? 0 &- Self(magnitude) : Self(magnitude),
      isExact)
  }
  
  /// Creates an integer from the given decimal floating-point value, rounding
  /// toward zero. Any fractional part of the value passed as `source` is
  /// removed.
  ///
  ///     let x = Int(21.5)
  ///     // x == 21
  ///     let y = Int(-21.5)
  ///     // y == -21
  ///
  /// If `source` is outside the bounds of this type after rounding toward
  /// zero, a runtime error may occur.
  ///
  ///     let z = UInt(-21.5)
  ///     // Error: ...outside the representable range
  ///
  /// - Parameter source: A decimal floating-point value to convert to an
  ///    integer. `source` must be representable in this type after rounding
  ///    toward zero.
  @_semantics("optimize.sil.specialize.generic.partial.never")
  @inline(__always)
  public init<T: DecimalFloatingPoint>(_ source: T) {
    guard let value = Self._convert(from: source).value else {
      fatalError("""
        \(source) cannot be converted to \(Self.self) because it is \
        outside the representable range
        """)
    }
    self = value
  }
  
  /// Creates an integer from the given floating-point value, if it can be
  /// represented exactly.
  ///
  /// If the value passed as `source` is not representable exactly, the result
  /// is `nil`. In the following example, the constant `x` is successfully
  /// created from a value of `21.0`, while the attempt to initialize the
  /// constant `y` from `21.5` fails:
  ///
  ///     let x = Int(exactly: 21.0)
  ///     // x == Optional(21)
  ///     let y = Int(exactly: 21.5)
  ///     // y == nil
  ///
  /// - Parameter source: A floating-point value to convert to an integer.
  @_semantics("optimize.sil.specialize.generic.partial.never")
  @inlinable
  public init?<T: DecimalFloatingPoint>(exactly source: T) {
    let (temporary, exact) = Self._convert(from: source)
    guard exact, let value = temporary else { return nil }
    self = value
  }
}

/// Defines bit-related operations such as setting/getting bits of a number
extension FixedWidthInteger {
  private func mask(_ size: Int) -> Self { (Self(1) << size) - 1 }
  
  /// Returns the bits in the `range` of the current number where
  /// `range.lowerBound` ≥ 0 and the `range.upperBound` < Self.bitWidth
  public func get(range: IntRange) -> Self {
    precondition(range.lowerBound >= 0 && range.upperBound < Self.bitWidth)
    return (self >> range.lowerBound) & mask(range.count)
  }
  
  public func getInt(range: IntRange) -> Int {
    precondition(range.lowerBound >= 0 && range.upperBound < Self.bitWidth)
    precondition(range.count <= Int.bitWidth)
    return Int((self >> range.lowerBound) & mask(range.count))
  }
  
  /// Returns the `n`th bit of the current number where
  /// 0 ≤ `n` < Self.bitWidth
  public func get(bit n: Int) -> Int {
    precondition(n >= 0 && n < Self.bitWidth)
    return ((1 << n) & self) == 0 ? 0 : 1
  }
  
  /// Logically inverts the `n`th bit of the current number where
  /// 0 ≤ `n` < Self.bitWidth
  public mutating func toggle(bit n: Int) {
    precondition(n >= 0 && n < Self.bitWidth)
    self ^= 1 << n
  }
  
  /// Non-mutating version of the `toggle(bit:)` method.
  public func toggling(bit n: Int) -> Self {
    precondition(n >= 0 && n < Self.bitWidth)
    return self ^ (1 << n)
  }
  
  /// Sets to `0` the `n`th bit of the current number where
  /// 0 ≤ `n` < Self.bitWidth
  public mutating func clear(bit n: Int) {
    precondition(n >= 0 && n < Self.bitWidth)
    self &= ~(1 << n)
  }
  
  /// Non-mutating version of the `clear(bit:)` method
  public func clearing(bit n: Int) -> Self {
    precondition(n >= 0 && n < Self.bitWidth)
    return self & ~(1 << n)
  }
  
  /// Sets to `1` the `n`th bit of the current number where
  /// 0 ≤ `n` < Self.bitWidth
  public mutating func set(bit n: Int) {
    precondition(n >= 0 && n < Self.bitWidth)
    self |= 1 << n
  }
  
  /// Non-mutating version of the `set(bit:)` method.
  public func setting(bit n: Int) -> Self {
    precondition(n >= 0 && n < Self.bitWidth)
    return self | (1 << n)
  }
  
  /// Replaces the `n`th bit of the current number with `value` where
  /// 0 ≤ `n` < Self.bitWidth
  public mutating func set(bit n: Int, with value: Int) {
    value.isMultiple(of: 2) ? self.clear(bit: n) : self.set(bit: n)
  }
  
  /// Non-mutating version of the `set(bit:value:)` method.
  public func setting(bit n: Int, with value: Int) -> Self {
    value.isMultiple(of: 2) ? self.clearing(bit: n) : self.setting(bit: n)
  }
  
  /// Sets to `0` the bits in the `range` of the current number where
  /// `range.lowerBound` ≥ 0 and the `range.upperBound` < Self.bitWidth
  public mutating func clear(range: IntRange) {
    precondition(range.lowerBound >= 0 && range.upperBound < Self.bitWidth)
    self &= ~(mask(range.count) << range.lowerBound)
  }
  
  /// Nonmutating version of the `clear(range:)` method.
  public func clearing(range: IntRange) -> Self {
    precondition(range.lowerBound >= 0 && range.upperBound < Self.bitWidth)
    return self & ~(mask(range.count) << range.lowerBound)
  }
  
  /// Replaces the bits in the `range` of the current number where
  /// `range.lowerBound` ≥ 0 and the `range.upperBound` < Self.bitWidth
  public mutating func set<T:FixedWidthInteger>(range:IntRange, with value:T) {
    self.clear(range: range)
    self |= (Self(value) & mask(range.count)) << range.lowerBound
  }
  
  /// Nonmutating version of the `set(range:)` method.
  public func setting<T:FixedWidthInteger>(range:IntRange,with value:T)->Self {
    let x = self.clearing(range: range)
    return x | (Self(value) & mask(range.count)) << range.lowerBound
  }
}
