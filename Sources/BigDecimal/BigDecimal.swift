//
//  Original created by Leif Ibsen on 10/11/2022.
//  Compliance to Codable, Strideable, ExpressibleByIntegerLiteral,
//  SignedNumeric, AdditiveArithmetic, FloatingPoint added by
//  Mike Griebling on 28 June 2023.
//

import Foundation   // For Data/Decimal data types
import BigInt       // Basis for digit storage and conversions
// import UInt128      // For UInt128 data type

public typealias Sign = FloatingPointSign

/// A signed decimal value of unbounded precision (actually there is a
/// practical limit defined by ``maxDigits`` of 200 that the user can change).
/// A ``BigDecimal`` value is represented as a signed `BInt` significand
/// and a signed `Int` exponent that is limited to ten digits.
/// The value of a Self is ``digits`` \* 10^``exponent``.
/// 
/// There are three special ``BigDecimal`` values: ``nan`` designating
/// Not a Number, ``infinity`` designating Infinity, ``signalingNaN``
/// designating a Signaling Not a Number.
public struct BigDecimal : Comparable, Equatable, Hashable, Codable, Sendable {
    
    // MARK: - Constants
    
    public static let maxExp = 9_999_999_999
    public static let maxDigits = 200       // can be changed by recompiling
    
    /// BigDecimal(0)
    public static let zero = Self(0)
    
    /// BigDecimal(1)
    public static let one = Self(1)
    
    /// BigDecimal(10)
    public static let ten = Self(10)
    
    /// BigDecimal('NaN')
    public static let nan = Self(.nanPos)
    
    /// BigDecimal('Infinity')
    public static let infinity = Self(.infPos)
    
    /// BigDecimal('sNaN')
    public static let signalingNaN = Self(.snanPos)
    
    // MARK: - Special encodings for infinite, NaN, sNaN, and negative zero.
    
    /// Encodings for infinite, NaN, sNaN, and negative zero.
    enum Special : Codable {
        case none, nanPos, nanNeg, snanPos, snanNeg, infPos, infNeg, zeroNeg
        
        static let negs = [Self.nanNeg, .snanNeg, .infNeg, .zeroNeg]
        var isNegative: Bool { Self.negs.contains(self) }
        var isPositive: Bool { [.nanPos,.snanPos,.infPos].contains(self) }
        var isInfinity: Bool { [.infPos,.infNeg].contains(self) }
        var isNan: Bool { [.nanPos,.nanNeg,.snanPos,.snanNeg].contains(self) }
        var isSignalingNan: Bool { [.snanPos,.snanNeg].contains(self) }
        var isZero: Bool { self == .zeroNeg }
    }
    
    // MARK: - Initializers
    
    /// Constructs a special BigDecimal based on the ``Special`` type.
    ///
    /// - Parameters:
    ///   - type: Kind of special number (includes sign)
    ///   - payload: Digits added as a payload to a NaN
    init(_ type: Special, _ payload: Int = 0) {
        self.special = type
        self.digits = BInt(payload)
        self.exponent = 0
        self.precision = 1
    }
    
    /// Constructs a BigDecimal from its digits and exponent
    ///
    /// - Parameters:
    ///   - significand: The digits
    ///   - exponent: The exponent, default is 0
    public init(_ significand: Int, _ exponent: Int = 0) {
        self.init(BInt(significand), exponent)
    }
    
    /// Constructs a BigDecimal from its digits and exponent
    ///
    /// - Parameters:
    ///   - significand: The digits
    ///   - exponent: The exponent, default is 0
    public init(_ significand: BInt, _ exponent: Int = 0) {
        self.special = .none
        self.digits = significand
        self.exponent = exponent
        self.precision = significand.abs.asString().count
    }
    
    /// Constructs a BigDecimal from its String encoding - NaN if the string
    /// does not designate a decimal number
    ///
    /// - Parameters:
    ///   - s: The String encoding
    public init(_ s: String) {
        self = Self.parseString(s)
    }
    
    /// Constructs a BigDecimal from its Data encoding - NaN if the encoding
    /// is wrong
    ///
    /// - Parameters:
    ///   - d: The Data encoding
    public init(_ d: Data) {
        switch d.count {
            case 1:
                if d[0] == 1 {
                    self = Self.infinity
                } else if d[0] == 2 {
                    self = -Self.infinity
                } else if d[0] == 3 {
                    self = Self(.zeroNeg)
                } else {
                    self = Self.flagNaN()
                }
            case 0, 2 ..< 9:
                self = Self.flagNaN()
            default:
                var exp = Int(d[0])
                for i in 1...7 { exp <<= 8; exp += Int(d[i]) }
                let sig = BInt(signed: Bytes(d[8 ..< d.count]))
                self.init(sig, exp)
        }
    }
    
    /// Constructs a BigDecimal from a Double value
    ///
    /// - Parameters:
    ///   - d: The Double value
    public init(_ d: Double) {
        if d.isNaN {
            self = Self.flagNaN(d.isSignalingNaN)
        } else if d.isInfinite {
            self = d > 0.0 ? Self.infinity : -Self.infinity
        } else {
            let bits = d.bitPattern
            var exponent = Int((bits >> 52) & 0x7ff)
            var significand = exponent == 0
                            ? Int((bits & 0xfffffffffffff) << 1)
                            : Int((bits & 0xfffffffffffff) | 0x10000000000000)
            exponent -= 1075
            if significand == 0 {
                self.init(BInt.zero)
            } else {
                while significand & 1 == 0 {
                    significand >>= 1
                    exponent += 1
                }
                let s = BInt(d.sign == .minus ? -significand : significand)
                if exponent < 0 {
                    self.init(BInt.FIVE ** (-exponent) * s, exponent)
                } else if exponent > 0 {
                    self.init(BInt.TWO ** exponent * s, 0)
                } else {
                    self.init(s, 0)
                }
            }
        }
    }
    
    /// Constructs a BigDecimal from a Decimal (the Swift Foundation type)
    ///
    /// - Parameters:
    ///   - value: The Decimal value
    public init(_ value: Foundation.Decimal) {
        
        var m = BInt(0)
        
        func addValue(_ x:UInt16, _ shift:Int) { m += BInt(Int(x)) << shift }
        
        if value.isNaN {
            self = Self.flagNaN()
        } else {
            let length = value._length
            for i in 0...length {
                switch i {
                    case 1: addValue(value._mantissa.0, 0)
                    case 2: addValue(value._mantissa.1, 16)
                    case 3: addValue(value._mantissa.2, 32)
                    case 4: addValue(value._mantissa.3, 48)
                    case 5: addValue(value._mantissa.4, 64)
                    case 6: addValue(value._mantissa.5, 80)
                    case 7: addValue(value._mantissa.6, 96)
                    case 8: addValue(value._mantissa.7, 112)
                    default: break
                }
            }
            self = Self(value < 0 ? -m : m, Int(value._exponent))
        }
    }
    
    /// Constructs a BigDecimal from an encoded Decimal32 value
    ///
    /// - Parameters:
    ///   - value: The encoded value
    ///   - encoding: The encoding, default is .dpd
    public init(_ value: UInt32, _ encoding: Encoding = .dpd) {
        self = Decimal32(value, encoding).asBigDecimal()
    }
    
    /// Constructs a BigDecimal from an encoded Decimal64 value
    ///
    /// - Parameters:
    ///   - value: The encoded value
    ///   - encoding: The encoding, default is .dpd
    public init(_ value: UInt64, _ encoding: Encoding = .dpd) {
        self = Decimal64(value, encoding).asBigDecimal()
    }
    
    /// Constructs a BigDecimal from an encoded Decimal128 value
    ///
    /// - Parameters:
    ///   - value: The encoded value
    ///   - encoding: The encoding, default is .dpd
    public init(_ value: UInt128, _ encoding: Encoding = .dpd) {
        self = Decimal128(value, encoding).asBigDecimal()
    }
    
    
    // MARK: Stored properties
    
    /// The signed BInt significand
    public internal(set) var digits: BInt
    
    /// The signed exponent - the value of *self* is *self.significand* *
    /// 10^*self.exponent*
    public internal(set) var exponent: Int
    
    /// The number of decimal digits in *significand*
    public internal(set) var precision: Int
    
    /// Special encodings are defined here (e.g., NaN, Infinity)
    var special: Special
}

extension BigDecimal : LosslessStringConvertible { }

extension BigDecimal : Strideable {
    public func distance(to other: Self) -> Self { other - self }
    public func advanced(by n: Self) -> Self { self + n }
}

extension BigDecimal : ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: StaticBigInt) {
        self = Self(BInt(integerLiteral: value))
    }
    
    public typealias IntegerLiteralType = StaticBigInt
}

extension BigDecimal : SignedNumeric {
    
    /// Apple's preferred `abs` getter
    public var magnitude: Self { self.abs }
    
    public init?<T : BinaryInteger>(exactly source: T) {
        let bint = BInt(source)
        self = Self(bint)
    }
    
    /// Prefix minus
    ///
    /// - Parameter x: Self value
    /// - Returns: -x
    public prefix static func - (x: Self) -> Self {
        if x.isNaN {
            return Self.flagNaN()
        } else if x.isInfinite {
            return x.isNegative ? Self.infinity : Self(.infNeg)
        } else if x.isZero {
            return x.isNegative ? Self.zero : Self(.zeroNeg)
        } else {
            return Self(-x.digits, x.exponent)
        }
    }
}

extension BigDecimal : AdditiveArithmetic {
    // MARK: Addition functions

    /// Addition
    ///
    /// - Parameters:
    ///   - x: First addend
    ///   - y: Second addend
    /// - Returns: x + y
    public static func + (x: Self, y: Self) -> Self {
        if x.isNaN || y.isNaN {
            return Self.flagNaN()
        } else if x.isInfinite {
            if x.signum == y.signum {
                return x
            } else {
                return y.isFinite ? x : Self.flagNaN()
            }
        } else if y.isInfinite {
            return y
        }
        if x.exponent > y.exponent {
            return Self(x.digits * Rounding.pow10(x.exponent - y.exponent)
                        + y.digits, y.exponent)
        } else if x.exponent < y.exponent {
            return Self(x.digits + y.digits *
                        Rounding.pow10(y.exponent - x.exponent), x.exponent)
        } else {
            return Self(x.digits + y.digits, x.exponent)
        }
    }

    // MARK: Subtraction functions

    /// Subtraction
    ///
    /// - Parameters:
    ///   - x: Minuend
    ///   - y: Subtrahend
    /// - Returns: x - y
    public static func - (x: Self, y: Self) -> Self {
        if x.isNaN || y.isNaN {
            return Self.flagNaN()
        } else if x.isInfinite {
            if x.signum != y.signum {
                return x
            } else {
                return y.isFinite ? x : Self.flagNaN()
            }
        } else if y.isInfinite {
            return -y
        }
        if x.exponent > y.exponent {
            return Self(x.digits * Rounding.pow10(x.exponent - y.exponent)
                        - y.digits, y.exponent)
        } else if x.exponent < y.exponent {
            return Self(x.digits - y.digits *
                        Rounding.pow10(y.exponent - x.exponent), x.exponent)
        } else {
            return Self(x.digits - y.digits, x.exponent)
        }
    }
}

extension BigDecimal : FloatingPoint {
    // MARK: - FloatingPoint Static Properties
    
    // Default precision and rounding same as Decimal128
    public static var mc = Rounding.decimal128
    
    public static var radix: Int     { 10 }
    public static var pi: Self       { Self.pi(mc) }
    public static var precision: Int { mc.precision }

    public static var greatestFiniteMagnitude: Self {
        Self(sign: .plus, exponent: maxExp-maxDigits+1,
             significand: (Self.ten ** maxDigits)-1)
    }
    public static var leastNormalMagnitude: Self {
        Self(sign: .plus, exponent: -maxExp-maxDigits+1,
             significand: (Self.ten ** maxDigits)-1)
    }
    public static var leastNonzeroMagnitude: Self {
        Self(sign: .plus, exponent: -maxExp, significand: 1)
    }
    
    // MARK: - FloatingPoint Number's Properties
    
    public var sign: FloatingPointSign { self.signum < 0 ? .minus : .plus }
    
    public var significand: Self { Self(digits) }
    
    // MARK: - FloatingPoint Basic Operations
    
    /// Replaces this value with the remainder of itself divided by the given
    /// value.
    ///
    /// For two finite values `x` and `y`, the remainder `r` of dividing `x` by
    /// `y` satisfies `x == y * q + r`, where `q` is the integer nearest to
    /// `x / y`. If `x / y` is exactly halfway between two integers, `q` is
    /// chosen to be even. Note that `q` is *not* `x / y` computed in
    /// floating-point arithmetic, and that `q` may not be representable in any
    /// available integer type.
    ///
    /// The following example calculates the remainder of dividing 8.625 by 0.75:
    ///
    ///     var x = 8.625
    ///     print(x / 0.75)
    ///     // Prints "11.5"
    ///
    ///     let q = (x / 0.75).rounded(.toNearestOrEven)
    ///     // q == 12.0
    ///     x.formRemainder(dividingBy: 0.75)
    ///     // x == -0.375
    ///
    ///     let x1 = 0.75 * q + x
    ///     // x1 == 8.625
    ///
    /// If this value and `other` are finite numbers, the remainder is in the
    /// closed range `-abs(other / 2)...abs(other / 2)`. The
    /// `formRemainder(dividingBy:)` method is always exact.
    ///
    /// - Parameter other: The value to use when dividing this value.
    public mutating func formRemainder(dividingBy other: Self) {
        let q = self.divide(other).rounded(.toNearestOrEven)
        self -= q * other
    }
    
    public mutating func formTruncatingRemainder(dividingBy other: Self) {
        self = self.quotientAndRemainder(other).remainder
    }
    
    public mutating func formSquareRoot() {
        self = Self.sqrt(self, Self.mc)
    }
    
    public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
        self = self.fma(lhs, rhs, Rounding.decimal128)
    }
    
    /// Rounds the value to an integral value using the specified rounding rule.
    ///
    /// The following example rounds a value using four different rounding rules:
    ///
    ///     // Equivalent to the C 'round' function:
    ///     var w = 6.5
    ///     w.round(.toNearestOrAwayFromZero)
    ///     // w == 7.0
    ///
    ///     // Equivalent to the C 'trunc' function:
    ///     var x = 6.5
    ///     x.round(.towardZero)
    ///     // x == 6.0
    ///
    ///     // Equivalent to the C 'ceil' function:
    ///     var y = 6.5
    ///     y.round(.up)
    ///     // y == 7.0
    ///
    ///     // Equivalent to the C 'floor' function:
    ///     var z = 6.5
    ///     z.round(.down)
    ///     // z == 6.0
    ///
    /// For more information about the available rounding rules, see the
    /// `FloatingPointRoundingRule` enumeration. To round a value using the
    /// default "schoolbook rounding", you can use the shorter `round()` method
    /// instead.
    ///
    ///     var w1 = 6.5
    ///     w1.round()
    ///     // w1 == 7.0
    ///
    /// - Parameter rule: The rounding rule to use.
    public mutating func round(_ rule: FloatingPointRoundingRule) {
        self = self.quantize(BigDecimal.one, rule)
    }
    
    public var nextUp: Self {
        if self.isInfinite || self.isNaN { return self }
        var x = self; x.digits += 1
        return x
    }
    
    public func isEqual(to other: Self) -> Bool {
        if self.isNaN || other.isNaN { return false }
        return self == other
    }
    
    public func isLess(than other: Self) -> Bool {
        if self.isNaN || other.isNaN { return false }
        return self < other
    }
    
    public func isLessThanOrEqualTo(_ other: Self) -> Bool {
        if self.isNaN || other.isNaN { return false }
        return self <= other
    }
    
    public var isNormal: Bool {
        if self.isNaN || self.isInfinite { return false }
        return true
    }
    
    public var isSubnormal: Bool {
        if self.isNaN || self.isInfinite { return false }
        return false
    }
    
    public var isCanonical: Bool {
        return true
    }
    
    public init(sign: FloatingPointSign, exponent: Int, significand: Self) {
        var digits = significand.digits
        if sign == .minus { digits.negate() }
        self.init(digits, exponent)
    }
    
    public init(signOf: Self, magnitudeOf: Self) {
        if signOf.sign == .minus {
            self = -magnitudeOf.magnitude
        } else {
            self = magnitudeOf.magnitude
        }
    }
}

extension BigDecimal : DecimalFloatingPoint {
    
    public static var exponentBitCount: Int { Int.bitWidth }
    public static var significandDigitCount: Int { -1 } // unlimited
    
    public var exponentBitPattern: Int     { self.exponent } // no encoding
    public var significandBitPattern: BInt { self.digits }
    public var significandDigitCount: Int  { self.precision }
    public var decade: Self                { Self(1, self.exponent) }
    
    public init(sign: Sign, exponentBitPattern: Int,
                significandBitPattern: BigInt.BInt) {
        var sig = significandBitPattern.magnitude
        if sign == .minus { sig.negate() }
        self.init(sig, exponentBitPattern)
    }
}

extension BigDecimal {
    
    // MARK: Computed properties

    /// The absolute value of *self*
    public var abs: Self {
        isNaN ? Self.flagNaN()
              : (isInfinite ? Self.infinity : Self(digits.abs, exponent))
    }

    /// String encoding of *self*
    public var description: String { self.asString() }

    /// Is *true* if *self* is a finite number
    public var isFinite: Bool { !self.isNaN && !self.isInfinite }
    
    /// Is *true* if *self* is either a NaN or SNaN number
    public var isNaN: Bool { special.isNan }
    
    /// Is *true* if *self* is a signaling NaN number
    public var isSignalingNaN: Bool { special.isSignalingNan }
    
    /// Is *true* if *self* is an infinite number
    public var isInfinite: Bool { special.isInfinity }
    
    /// Is *true* if *self* < 0, *false* otherwise
    public var isNegative: Bool { self.signum < 0 }

    /// Is *true* if *self* > 0, *false* otherwise
    public var isPositive: Bool { self.signum > 0 }

    /// Is *true* if *self* = 0, *false* otherwise
    public var isZero: Bool { self.signum == 0 || special == .zeroNeg }

    /// Is 0 if *self* = 0 or *self* is NaN, 1 if *self* > 0, and -1
    /// if *self* < 0
    public var signum: Int {
        special == .none ? self.digits.signum : special.isNegative ? -1 : 1
    }
    
    /// The same value as *self* with any trailing zeros removed from its
    /// significand
    public var trim: Self {
        if self.isNaN {
            return Self.flagNaN()
        } else if self.isInfinite {
            return self
        } else if self.digits.isZero {
            return Self(0)
        }
        var q = self.digits
        var n = 0
        while true {
            let (q1, r) = q.quotientAndRemainder(dividingBy: BInt.TEN)
            if !r.isZero {
                break
            }
            q = q1
            n += 1
        }
        return Self(q, self.exponent + n)
    }
    
    /// Unit in last place = Self(1, self.exponent)
    public var ulp: Self {
        self.isFinite ? Self(BInt.ONE, self.exponent) : Self.flagNaN()
    }

    
    // MARK: Static variables

    /// NaN flag - set to *true* whenever a NaN value is generated
    /// Can be set to *false* by application code
    public static var nanFlag = false

    // MARK: Conversion functions
    
    /// *self* as a string
    ///
    /// - Parameters:
    ///   - mode: The display mode - *scientific* is default
    /// - Returns: *self* encoded as a string in accordance with the display
    ///   `mode`.
    public func asString(_ mode: DisplayMode = .scientific) -> String {
        let expSymbol = "E"
        let dp = "."
        
        func pad(_ len:Int) -> String {
            "".padding(toLength: len, withPad: "0", startingAt: 0)
        }
        
        if self.isNaN {
            var flag = "NaN"
            if let ext = self.digits.asInt() {
                if !self.digits.isZero { flag += String(ext) }
            }
            if self.isSignalingNaN { flag = "S" + flag }
            if self.isNegative { return "-" + flag }
            return flag
        } else if self.isInfinite {
            return self.isNegative ? "-Infinity" : "+Infinity"
        }
        var exp = self.precision + self.exponent - 1
        var s = self.digits.abs.asString()
        if mode == .plain || (self.exponent <= 0 && exp >= -6) {
            if self.exponent > 0 {
                if !self.digits.isZero {
                    s += pad(self.exponent)
                }
            } else if self.exponent < 0 {
                let offset = self.precision + self.exponent
                if offset > 0 {
                    s.insert(contentsOf:dp,
                             at: s.index(s.startIndex, offsetBy: offset))
                } else {
                    s = "0" + dp + pad(-offset) + s
                }
            }
        } else if mode == .scientific {
            // Scientific notation
            if s.count > 1 {
                s.insert(contentsOf:dp, at: s.index(s.startIndex, offsetBy: 1))
            }
            s += expSymbol
            if exp > 0 { s += "+" }
            s += exp.description
        } else {
            // Engineering notation
            switch exp % 3 {
                case 1, -2:
                    if self.isZero {
                        s += dp + "00"
                        exp += 2
                    } else {
                        let sc = s.count
                        if sc > 2 {
                            s.insert(contentsOf: dp,
                                     at: s.index(s.startIndex, offsetBy:2))
                        } else {
                            s += pad(2-sc)
                        }
                        exp -= 1
                    }
                case -1, 2:
                    if self.isZero {
                        s += dp + "0"
                        exp += 1
                    } else {
                        let sc = s.count
                        if sc > 3 {
                            s.insert(contentsOf: dp,
                                     at: s.index(s.startIndex, offsetBy:3))
                        } else {
                            s += pad(3-sc)
                        }
                        exp -= 2
                    }
                default:
                    if !self.isZero && s.count > 1 {
                        s.insert(contentsOf: dp, at: s.index(s.startIndex, offsetBy: 1))
                    }
            }
            if exp > 0 {
                s += expSymbol + "+"
                s += exp.description
            } else if exp < 0 {
                s += expSymbol
                s += exp.description
            }
        }
        if self.isNegative {
            return "-" + s
        }
        return s
    }
    
    /// *self* as Data
    ///
    /// - Returns: *self* encoded as Data
    public func asData() -> Data {
        if self.isNaN {
            return Data([0])
        } else if self.isInfinite {
            return self.isPositive ? Data([1]) : Data([2])
        } else if self.isZero && self.isNegative {
            return Data([3])
        }
        var expBytes = [UInt8](repeating: 0, count: 8)
        var exp = self.exponent
        for index in (0...7).reversed() {
            expBytes[index] = UInt8(exp & 0xff); exp >>= 8
        }
        return Data(expBytes + self.digits.asSignedBytes())
    }

    /// *self* as a Double
    ///
    /// - Returns: *self* encoded as a Double, possibly *Infinity* or NaN
    public func asDouble() -> Double { Double(self.asString())! }
    
    /// *self* as a Float
    ///
    /// - Returns: *self* encoded as a Float, possibly *Infinity* or NaN
    public func asFloat() -> Float { Float(self.asString())! }

    /// *self* as a Decimal (the Swift Foundation type)
    ///
    /// - Returns: *self* as a Decimal value
    public func asDecimal() -> Foundation.Decimal {
        let maxExp = 127
        let minExp = -128
        let maxDec = Self(BInt("ffffffffffffffffffffffffffffffff", radix:16)!, maxExp)
        
        if self.isNaN || self.abs > maxDec {
            return Foundation.Decimal.nan
        }
        var exp = self.exponent
        var sig = self.digits.abs
        while sig.words.count > 2 {
            sig /= 10
            exp += 1
        }
        if exp > maxExp {
            sig *= Rounding.pow10(exp - maxExp)
            exp = maxExp
        }
        if exp < minExp {
            sig /= Rounding.pow10(minExp - exp)
            exp = minExp
        }
        if sig == 0 {
            return Foundation.Decimal(0)
        }
        assert(sig.words.count < 3)
        assert(minExp <= exp && exp <= maxExp)
        
        func decode() -> UInt16 {
            (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
            return UInt16(r)
        }
        
        var s0 = UInt16(0), s1 = UInt16(0), s2 = UInt16(0), s3 = UInt16(0)
        var s4 = UInt16(0), s5 = UInt16(0), s6 = UInt16(0), s7 = UInt16(0)
        var length = UInt32(1)
        var r: Int = 0
        
        s0 = decode()
        while sig > 0 {
            switch length {
                case 1: s1 = decode()
                case 2: s2 = decode()
                case 3: s3 = decode()
                case 4: s4 = decode()
                case 5: s5 = decode()
                case 6: s6 = decode()
                case 7: s7 = decode()
                default: break
            }
            length += 1
        }
        assert(sig < 0x10000)
        return Foundation.Decimal(_exponent: Int32(exp), _length: length,
                       _isNegative: self < 0 ? 1 : 0, _isCompact: 0,
                       _reserved: 0, _mantissa: (s0,s1,s2,s3,s4,s5,s6,s7))
    }
    
    /// *self* as a Decimal32 value
    ///
    /// - Parameters:
    ///   - encoding: The encoding of the result - dpd is the default
    /// - Returns: *self* encoded as a Decimal32 value
    public func asDecimal32(_ encoding: Encoding = .dpd) -> UInt32 {
        Decimal32(self).asUInt32(encoding)
    }
    
    /// *self* as a Decimal64 value
    ///
    /// - Parameters:
    ///   - encoding: The encoding of the result - dpd is the default
    /// - Returns: *self* encoded as a Decimal64 value
    public func asDecimal64(_ encoding: Encoding = .dpd) -> UInt64 {
        Decimal64(self).asUInt64(encoding)
    }
    
    /// *self* as a Decimal128 value
    ///
    /// - Parameters:
    ///   - encoding: The encoding of the result - dpd is the default
    /// - Returns: *self* encoded as a Decimal128 value
    public func asDecimal128(_ encoding: Encoding = .dpd) -> UInt128 {
        Decimal128(self).asUInt128(encoding)
    }


    // MARK: Rounded arithmetic
    
    /// Addition and rounding
    ///
    /// - Parameters:
    ///   - x: Addend
    ///   - rnd: Rounding object
    /// - Returns: *self* + x rounded according to *rnd*
    public func add(_ x: Self, _ rnd: Rounding) -> Self {
        return rnd.round(self + x)
    }
    
    public func add<T:BinaryInteger>(_ d:T, _ rnd:Rounding) -> Self {
        self.add(Self(d), rnd)
    }

    /// Subtraction and rounding
    ///
    /// - Parameters:
    ///   - x: Subtrahend
    ///   - rnd: Rounding object
    /// - Returns: *self* - x rounded according to *rnd*
    public func subtract(_ x: Self, _ rnd: Rounding) -> Self {
        return rnd.round(self - x)
    }
    
    public func subtract<T:BinaryInteger>(_ d:T, _ rnd:Rounding) -> Self {
        self.subtract(Self(d), rnd)
    }

    /// Multiplication and rounding
    ///
    /// - Parameters:
    ///   - x: Multiplicand
    ///   - rnd: Rounding object
    /// - Returns: *self* \* x rounded according to *rnd*
    public func multiply(_ x: Self, _ rnd: Rounding) -> Self {
        return rnd.round(self * x)
    }
    
    public func multiply<T:BinaryInteger>(_ d:T, _ rnd:Rounding) -> Self {
        self.multiply(Self(d), rnd)
    }

    /// Division and rounding
    ///
    /// - Parameters:
    ///   - d: Divisor
    ///   - rnd: Optional rounding object
    /// - Returns: *self* / *d* optionally rounded according to *rnd*, NaN
    /// if *rnd* = *nil* and the quotient has infinite decimal expansion
    public func divide(_ d: Self, _ rnd: Rounding? = nil) -> Self {
        let (error, quotient, _) = self.checkDivision(d)
        if error {
            return quotient
        }
        let gcd = self.digits.gcd(d.digits)
        var d1 = d.digits.quotientExact(dividingBy: gcd)
        let count2 = d1.trailingZeroBitCount
        d1 >>= count2
        var count5 = 0
        while true {
            let (q, r) = d1.quotientAndRemainder(dividingBy: BInt.FIVE)
            if !r.isZero {
                break
            }
            d1 = q
            count5 += 1
        }
        if d1.abs.isOne {
            // Quotient has finite decimal expansion
            let m = max(count2, count5)
            let x = Self((self.digits * Rounding.pow10(m)) /
                               d.digits, self.exponent - d.exponent - m)
            return rnd == nil ? x : rnd!.round(x)
        }
        guard let ctx = rnd else {
            return Self.flagNaN()
        }

        // Quotient has infinite decimal expansion

        var m = max(ctx.precision - self.precision + d.precision + 1, 0)
        var q = (self.digits * Rounding.pow10(m)) / d.digits
        let z = Rounding.pow10(ctx.precision)
        var r = BInt.zero
        while q.abs >= z {
            (q, r) = q.quotientAndRemainder(dividingBy: BInt.TEN)
            m -= 1
        }
        switch ctx.mode {
            case .awayFromZero:
                q = q.isNegative ? q : q + 1
            case .down:
                break
            case .towardZero:
                q = q.isNegative ? q - 1 : q
            case .toNearestOrEven, .toNearestOrAwayFromZero:
                if r >= 5 || r <= -5 {
                    q = q.isNegative ? q - 1 : q + 1
                }
            case .up:
                q = q.isNegative ? q - 1 : q + 1
            @unknown default:
                fatalError()
        }
        return Self(q, self.exponent - d.exponent - m)
    }
    
    public func divide<T:BinaryInteger>(_ d:T, _ rnd:Rounding? = nil) -> Self {
        self.divide(Self(d), rnd)
    }

    /// Fused multiply / add
    ///
    /// - Parameters:
    ///   - x: Multiplier
    ///   - y: Multiplicand
    ///   - rnd: Rounding object
    /// - Returns: *self* + x \* y rounded according to *rnd*
    public func fma(_ x: Self, _ y: Self, _ rnd: Rounding) -> Self {
        return rnd.round(self + x * y)
    }

    /// Exponentiation and rounding
    ///
    /// - Parameters:
    ///   - n: Exponent
    ///   - rnd: Optional rounding object
    /// - Returns: *self*^*n* if *n* >= 0, 1 / *self*^(-*n*) if *n* < 0,
    /// optionally rounded according to *rnd*, NaN if *rnd* = *nil* and the
    /// result has infinite decimal expansion
    public func pow(_ n: Int, _ rnd: Rounding? = nil) -> Self {
        if self.isNaN {
            return Self.flagNaN(self.isSignalingNaN)
        } else if self.isInfinite {
            if n < 0 {
                return Self.zero
            } else {
                return n == 0 ? Self.one :
                   (isPositive || n & 1 == 0 ? Self.infinity : -Self.infinity)
            }
        }
        if n < 0 {
            return isZero ? Self.infinity
                 : Self.one.divide(Self(digits ** (-n), exponent * (-n)), rnd)
        } else {
            let x = Self(digits ** n, exponent * n)
            return rnd == nil ? x : rnd!.round(x)
        }
    }
    
    public static func ** (_ lhs: Self, _ rhs: Int) -> Self { lhs.pow(rhs) }

    // MARK: Multiplication functions

    /// Multiplication
    ///
    /// - Parameters:
    ///   - x: Multiplier
    ///   - y: Multiplicand
    /// - Returns: x \* y
    public static func * (x: Self, y: Self) -> Self {
        if x.isNaN || y.isNaN {
            return Self.flagNaN(x.isSignalingNaN || y.isSignalingNaN)
        } else if x.isInfinite || y.isInfinite {
            if x.isZero || y.isZero {
                return Self.flagNaN()
            } else {
                return x.signum == y.signum ? infinity : -infinity
            }
        }
        return Self(x.digits * y.digits, x.exponent + y.exponent)
    }

    /// Multiplication
    ///
    /// x = x \* y
    ///
    /// - Parameters:
    ///   - x: Left hand multiplier
    ///   - y: Right hand multiplicand
    public static func *= (x: inout Self, y: Self) { x = x * y }


    // MARK: Division functions

    /// Division
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x / y truncated to an integer
    public static func / (x: Self, y: Self) -> Self {
        x.quotientAndRemainder(y).quotient
    }

    /// x = x / y
    ///
    /// - Parameters:
    ///   - x: Left hand dividend
    ///   - y: Right hand divisor
    public static func /= (x: inout Self, y: Self) {
        x = x.quotientAndRemainder(y).quotient
    }

    func checkDivision(_ d: Self) -> (failure: Bool, q: Self, r: Self) {
        if self.isNaN || d.isNaN {
            let signaling = self.isSignalingNaN || d.isSignalingNaN
            return (true, Self.flagNaN(signaling), Self.flagNaN(signaling))
        } else if self.isInfinite {
            if d.isInfinite {
                return (true, Self.flagNaN(), Self.flagNaN())
            } else if d.isNegative {
                return (true, (self.isPositive ? -Self.infinity
                               : Self.infinity), Self.flagNaN())
            } else {
                return (true, (self.isNegative ? -Self.infinity
                               : Self.infinity), Self.flagNaN())
            }
        } else if d.isInfinite {
            return (true, Self.zero, self)
        } else if d.isZero {
            return self.isZero ? (true, Self.flagNaN(), Self.flagNaN())
            : (self.isPositive ? (true, Self.infinity, Self.flagNaN())
               : (true, -Self.infinity, Self.flagNaN()))
        } else {
            return (false, Self.zero, Self.zero)
        }
    }

    /// Quotient and remainder
    ///
    /// - Parameters:
    ///   - d: Divisor
    /// - Returns: Quotient and remainder of the division *self* / d
    public func quotientAndRemainder(_ d: Self) ->
                                        (quotient: Self, remainder: Self) {
        let (error, q, r) = self.checkDivision(d)
        if error {
            return (q, r)
        }
        if self.exponent > d.exponent {
            let q = Self((self.digits * Rounding.pow10(self.exponent -
                                                d.exponent)) / d.digits, 0)
            return (q, self - q * d)
        } else {
            let q = Self(self.digits / (d.digits * Rounding.pow10(d.exponent -
                                                        self.exponent)), 0)
            return (q, self - q * d)
        }
    }

    /// Quotient and remainder
    ///
    /// - Parameters:
    ///   - d: Divisor
    /// - Returns: Quotient and remainder of the division *self* / d
    public func quotientAndRemainder(_ d: Int) ->
                                        (quotient: Self, remainder: Self) {
        return self.quotientAndRemainder(Self(d))
    }


    // MARK: Remainder functions

    /// Remainder
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x % y
    public static func % (x: Self, y: Self) -> Self {
        return x.quotientAndRemainder(y).remainder
    }

    /// x = x % y
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    public static func %= (x: inout Self, y: Self) {
        x = x.quotientAndRemainder(y).remainder
    }

    
    // MARK: Comparison functions

    // Returns -1 if self < x, 1 if self > x and 0 if self = x
    func compare(_ x: Self) -> Int {
        assert(!self.isNaN && !x.isNaN)
        if self.isInfinite {
            if self.isPositive {
                return x.isInfinite && x.isPositive ? 0 : 1
            } else {
                return x.isInfinite && x.isNegative ? 0 : -1
            }
        } else if x.isInfinite {
            return x.isPositive ? -1 : 1
        }
        let ssignum = self.signum
        let xsignum = x.signum
        if ssignum != xsignum {
            return ssignum > xsignum ? 1 : -1
        } else if ssignum == 0 {
            return 0
        } else if self.exponent == x.exponent {
            return self.digits.comparedTo(x.digits)
        } else {
            var cmp: Int
            let sae = self.precision + self.exponent
            let xae = x.precision + x.exponent
            if sae < xae {
                cmp = -1
            } else if sae > xae {
                cmp = 1
            } else if self.exponent > x.exponent {
                cmp = (self.digits.abs * Rounding.pow10(self.exponent -
                                        x.exponent)).comparedTo(x.digits.abs)
            } else {
                cmp = self.digits.abs.comparedTo(x.digits.abs *
                                Rounding.pow10(x.exponent - self.exponent))
            }
            return ssignum > 0 ? cmp : -cmp
        }
    }

    /// Maximum
    ///
    /// - Parameters:
    ///    - x: First operand
    ///    - y: Second operand
    /// - Returns: The larger of *x* and *y*, or whichever is a number if the
    ///   other is NaN.
    public static func maximum(_ x: Self, _ y: Self) -> Self {
        if x.isSignalingNaN || y.isSignalingNaN { return Self.flagNaN() }
        if x.isNaN { return y.isNaN ? Self.flagNaN() : y }
        if y.isNaN { return x }
        return (x > y ? x : y)
    }

    /// Minimum
    ///
    /// - Parameters:
    ///    - x: First operand
    ///    - y: Second operand
    /// - Returns: The minimum of `x` and `y`, or whichever is a number if the
    ///   other is NaN.
    public static func minimum(_ x: Self, _ y: Self) -> Self {
        if x.isSignalingNaN || y.isSignalingNaN { return Self.flagNaN() }
        if x.isNaN { return y.isNaN ? Self.flagNaN() : y }
        if y.isNaN { return x }
        return (x < y ? x : y)
    }

    /// Equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x = y, *false* otherwise
    public static func == (x: Self, y: Self) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) == 0
    }

    /// Not equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x != y, *false* otherwise
    public static func != (x: Self, y: Self) -> Bool {
        return x.isNaN || y.isNaN ? true : x.compare(y) != 0
    }

    /// Less than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x < y, *false* otherwise
    public static func < (x: Self, y: Self) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) < 0
    }

    /// Greater than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x > y, *false* otherwise
    public static func > (x: Self, y: Self) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) > 0
    }

    /// Less than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x <= y, *false* otherwise
    public static func <= (x: Self, y: Self) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) <= 0
    }

    /// Greater than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x >= y, *false* otherwise
    public static func >= (x: Self, y: Self) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) >= 0
    }

    // MARK: Rounding and scaling functions

    /// Round
    ///
    /// - Parameters:
    ///   - rnd: Rounding object
    /// - Returns: The value of *self* rounded according to *rnd*
    public func round(_ rnd: Rounding) -> Self { rnd.round(self) }

    /// Scale by power of ten
    ///
    /// - Parameters:
    ///   - n: Power of ten exponent
    /// - Returns: *self* \* 10^n
    public func scale(_ n: Int) -> Self {
        if self.isNaN {
            return Self.flagNaN(self.isSignalingNaN)
        } else if self.isInfinite {
            return self
        } else {
            return Self(self.digits, self.exponent + n)
        }
    }

    /// With Exponent
    ///
    /// - Parameters:
    ///    - exp: The required exponent
    ///    - mode: Rounding mode
    /// - Returns: Same value as *self* possibly rounded, with exponent = exp
    public func withExponent(_ exp: Int, _ mode: RoundingRule) -> Self {
        if self.isNaN || self.isInfinite {
            return Self.flagNaN(self.isSignalingNaN)
        } else if self.exponent > exp {
            return Self(self.digits * Rounding.pow10(self.exponent - exp), exp)
        } else if self.exponent < exp {
            let (q, r) = self.digits.quotientAndRemainder(dividingBy:
                                        Rounding.pow10(exp - self.exponent))
            if r.isZero {
                return Self(q, exp)
            }
            return Self(Rounding(mode, self.precision - self.exponent + exp)
                .roundBInt(self.digits, exp - self.exponent), exp)
        } else {
            return self
        }
    }
    
    /// Quantize
    ///
    /// - Parameters:
    ///   - other: a BigDecimal number
    ///   - mode: Rounding mode
    /// - Returns: Same value as *self* possibly rounded, with same exponent
    ///            as *other*
    public func quantize(_ other: Self, _ mode: RoundingRule) -> Self {
        if self.isInfinite && other.isInfinite {
            return self.isPositive ? Self.infinity : -Self.infinity
        } else if other.isInfinite {
            return Self.flagNaN()
        } else {
            return self.withExponent(other.exponent, mode)
        }
    }

}

extension BigDecimal {
    
    // MARK: - Support methods - String conversion
    
    static func parseString(_ s: String) -> Self {
        guard !s.isEmpty else { return Self.flagNaN() }
        enum State {
            case start, inInteger, inFraction, startExponent, inExponent
        }
        
        var state: State = .start
        var digits = 0, expDigits = 0, scale = 0
        var exp = "", val = ""
        var negExponent = false, sign = Sign.plus
        var sl = s.lowercased()
        
        // check for sign
        let ch = sl.first!
        if ch == "-" || ch == "+" {
            sign = ch == "-" ? .minus : .plus
            sl.removeFirst()
        }
        
        // detect nan, snan, and inf
        if sl.hasPrefix("nan") {
            sl.removeFirst(3)
            Self.nanFlag = true // set flag
            if let payload = Int(sl) {
                return Self(sign == .minus ? .nanNeg : .nanPos, payload)
            }
            return Self(sign == .minus ? .nanNeg : .nanPos)
        } else if sl.hasPrefix("inf") {
            return Self(sign == .minus ? .infNeg : .infPos)
        } else if sl == "snan" {
            return Self(sign == .minus ? .snanNeg : .snanPos)
        }
        for c in sl {
            switch c {
              case "0"..."9":
                if state == .start {
                    state = .inInteger
                    digits += 1
                    val.append(c)
                } else if state == .inInteger {
                    digits += 1
                    val.append(c)
                } else if state == .inFraction {
                    digits += 1
                    scale += 1
                    val.append(c)
                } else if state == .inExponent {
                    expDigits += 1
                    exp.append(c)
                } else if state == .startExponent {
                    state = .inExponent
                    expDigits += 1
                    exp.append(c)
                }
            case ".":
                if state == .start || state == .inInteger {
                    state = .inFraction
                } else {
                    return Self.flagNaN()
                }
            case "e":
                if state == .inInteger || state == .inFraction {
                    state = .startExponent
                } else {
                    return Self.flagNaN()
                }
            case "+":
                if state == .startExponent {
                    state = .inExponent
                } else {
                    return Self.flagNaN()
                }
            case "-":
                if state == .startExponent {
                    state = .inExponent
                    negExponent = true
                } else {
                    return Self.flagNaN()
                }
            default:
                return Self.flagNaN()
            }
        }
        if digits == 0 {
            return Self.flagNaN()
        }
        if (state == .startExponent || state == .inExponent) && expDigits==0 {
            return Self.flagNaN()
        }
        var w = BInt(val)!
        let E = Int(exp)
        if E == nil && expDigits > 0 {
            return Self.flagNaN()
        }
        let e = expDigits == 0 ? 0 : (negExponent ? -E! : E!)
        if sign == .minus {
            if w.isZero {
                var z = BigDecimal(.zeroNeg); z.exponent = e - scale
                return z
            }
            w = -w
        }
        return Self(w, e - scale)
    }
    
    static func flagNaN(_ signaling:Bool=false) -> Self {
        if signaling { return Self.signalingNaN }
        Self.nanFlag = true
        return Self.nan
    }
}

precedencegroup ExponentiationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
}

infix operator ** : ExponentiationPrecedence

extension BigDecimal {
    
    // MARK: - Support Enumerations
    
    /// Decimal32, Decimal64, and Decimal128 encodings
    public enum Encoding: CustomStringConvertible {
        /// Binary Integer Decimal encoding
        case bid
        
        /// Densely Packed Decimal encoding
        case dpd
        
        public var description: String {
            switch self {
                case .bid: return "Binary Integer Decimal encoding"
                case .dpd: return "Densely Packed Decimal encoding"
            }
        }
    }

    /// The Self display modes
    public enum DisplayMode: CustomStringConvertible {
        /// Display possibly using scientific notation
        case scientific
        
        /// Display possibly using engineering notation (i.e., exponents
        /// divisible by 3)
        case engineering
        
        /// Display value without scientific notation
        case plain
        
        public var description: String {
            switch self {
            case .scientific:
                return "Display possibly using scientific notation"
            case .engineering:
                return "Display possibly using engineering notation (i.e., " +
                    "exponents divisible by 3)"
            case .plain:
                return "Plain display without scientific notation"
            }
        }
    }
}
