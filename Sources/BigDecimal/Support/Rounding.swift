//
//  Rounding.swift
//  BigDecimalTest
//
//  Created by Leif Ibsen on 27/10/2022.
//

import BigInt
import Foundation

/// The rounding modes
public typealias RoundingRule = FloatingPointRoundingRule

extension RoundingRule : Swift.CustomStringConvertible {
    public var description: String {
        switch self {
            case .awayFromZero:
                return "Round away from 0"
            case .down:
                return "Round towards -infinity"
            case .towardZero:
                return "Round towards 0"
            case .toNearestOrEven:
                return "Round to nearest, ties to even"
            case .toNearestOrAwayFromZero:
                return "Round to nearest, ties away from 0"
            case .up:
                return "Round towards +infinity"
            @unknown default:
                assertionFailure("Unknown \(Self.self) rounding mode")
                return ""
        }
    }
}
/// BigDecimal rounding object containing a rounding mode and a precision
/// which is the number of digits in the rounded result
public struct Rounding: Equatable {
    // MARK: Constants

    /// Decimal32 rounding: .toNearestOrEven, 7
    public static let decimal32 = Rounding(.toNearestOrEven,
                                           Decimal32.maxDigits)
    /// Decimal64 rounding: .toNearestOrEven, 16
    public static let decimal64 = Rounding(.toNearestOrEven,
                                           Decimal64.maxDigits)
    /// Decimal128 rounding: .toNearestOrEven, 34
    public static let decimal128 = Rounding(.toNearestOrEven,
                                            Decimal128.maxDigits)


    // MARK: - Initializer

    /// Constructs a Rounding object from mode and precision
    ///
    /// - Parameters:
    ///   - mode: The rounding mode
    ///   - precision: The rounding precision - a positive number
    public init(_ mode: RoundingRule, _ precision: Int) {
        self.mode = mode
        self.precision = Swift.max(precision, 1)
    }
    
    
    // MARK: - Stored properties

    /// The rounding mode
    public internal(set) var mode: RoundingRule
    
    /// The rounding precision - a positive number
    public internal(set) var precision: Int

    
    // MARK: Round function
    
    /// Round
    ///
    /// - Parameters:
    ///   - x: The value to be rounded
    /// - Returns: The value of *x* rounded according to *self*
    public func round(_ x: BigDecimal) -> BigDecimal {
        if x.isNaN { let _ = BigDecimal.flagNaN(); return x }
        else if x.isInfinite { return x }
        let d = x.precision - self.precision
        if d <= 0 {
            return x
        }
        let q = roundBInt(x.digits, d)
        let pr = q.abs.asString().count
        if pr > self.precision {
            // 999.9 => 1000
            return BigDecimal(q / BInt.TEN, x.exponent + d + 1)
        } else {
            return BigDecimal(q, x.exponent + d)
        }
    }

    // Round after dividing x by 10^d
    func roundBInt(_ x: BInt, _ d: Int) -> BInt {
        assert(d > 0)
        let negative = x.isNegative
        let pow10d = Rounding.pow10(d)
        var q = x / pow10d
        if x != q * pow10d {
            let q1 = negative ? q - 1 : q
            let q2 = negative ? q : q + 1
            let qq1 = q1 * pow10d
            let qq2 = q2 * pow10d
            let d1 = x - qq1
            let d2 = qq2 - x
            switch self.mode {
                case .awayFromZero:
                    q = q2
                case .down:
                    q = q.isNegative ? q2 : q1
                case .towardZero:
                    q = q1
                case .toNearestOrEven:
                    if d1 == d2 {
                        q = q1.isEven ? q1 : q2
                    } else {
                        q = d1 < d2 ? q1 : q2
                    }
                case .toNearestOrAwayFromZero:
                    if d1 == d2 {
                        q = negative ? q1 : q2
                    } else {
                        q = d1 < d2 ? q1 : q2
                    }
                case .up:
                    q = q.isNegative ? q1 : q2
                @unknown default:
                    fatalError()
            }
        }
        return q
    }

    static let pow10table = [
        BInt(1),
        BInt(10),
        BInt(100),
        BInt(1_000),
        BInt(10_000),
        BInt(100_000),
        BInt(1_000_000),
        BInt(10_000_000),
        BInt(100_000_000),
        BInt(1_000_000_000),
        BInt(10_000_000_000),
        BInt(100_000_000_000),
        BInt(1_000_000_000_000),
        BInt(10_000_000_000_000),
        BInt(100_000_000_000_000),
        BInt(1_000_000_000_000_000),
        BInt(10_000_000_000_000_000),
        BInt(100_000_000_000_000_000),
        BInt(1_000_000_000_000_000_000),
    ]
    
    static func pow10(_ n: Int) -> BInt {
        assert(n >= 0)
        return n < pow10table.count ? pow10table[n] : BInt.TEN ** n
    }
}

public struct Status: OptionSet, CustomStringConvertible {
  
  public let rawValue: Int
  
  /* IEEE extended flags only */
  private static let DConversion_syntax    = 0x00000001
  private static let DDivision_by_zero     = 0x00000002
  private static let DDivision_impossible  = 0x00000004
  private static let DDivision_undefined   = 0x00000008
  private static let DInsufficient_storage = 0x00000010 /* malloc fails */
  private static let DInexact              = 0x00000020
  private static let DInvalid_context      = 0x00000040
  private static let DInvalid_operation    = 0x00000080
  private static let DLost_digits          = 0x00000100
  private static let DOverflow             = 0x00000200
  private static let DClamped              = 0x00000400
  private static let DRounded              = 0x00000800
  private static let DSubnormal            = 0x00001000
  private static let DUnderflow            = 0x00002000
  
  public static let conversionSyntax    = Status(rawValue:DConversion_syntax)
  public static let divisionByZero      = Status(rawValue:DDivision_by_zero)
  public static let divisionImpossible  = Status(rawValue:DDivision_impossible)
  public static let divisionUndefined   = Status(rawValue:DDivision_undefined)
  public static let insufficientStorage=Status(rawValue:DInsufficient_storage)
  public static let inexact             = Status(rawValue:DInexact)
  public static let invalidContext      = Status(rawValue:DInvalid_context)
  public static let lostDigits          = Status(rawValue:DLost_digits)
  public static let invalidOperation    = Status(rawValue:DInvalid_operation)
  public static let overflow            = Status(rawValue:DOverflow)
  public static let clamped             = Status(rawValue:DClamped)
  public static let rounded             = Status(rawValue:DRounded)
  public static let subnormal           = Status(rawValue:DSubnormal)
  public static let underflow           = Status(rawValue:DUnderflow)
  public static let clearFlags          = Status([])
  
  public static let errorFlags =
  Status(rawValue: Int(DDivision_by_zero | DOverflow |
                       DUnderflow | DConversion_syntax | DDivision_impossible |
                       DDivision_undefined | DInsufficient_storage |
                       DInvalid_context | DInvalid_operation))
  public static let informationFlags =
  Status(rawValue: Int(DClamped | DRounded | DInexact | DLost_digits))
  
  public init(rawValue: Int) { self.rawValue = rawValue }
  
  public var hasError:Bool {!Status.errorFlags.intersection(self).isEmpty}
  public var hasInfo:Bool {!Status.informationFlags.intersection(self).isEmpty}
  
  public var description: String {
    var str = ""
    if self.contains(.conversionSyntax)   { str += "Conversion syntax, "}
    if self.contains(.divisionByZero)     { str += "Division by zero, " }
    if self.contains(.divisionImpossible) { str += "Division impossible, "}
    if self.contains(.divisionUndefined)  { str += "Division undefined, "}
    if self.contains(.insufficientStorage){ str += "Insufficient storage, "}
    if self.contains(.inexact)            { str += "Inexact number, " }
    if self.contains(.invalidContext)     { str += "Invalid context, " }
    if self.contains(.invalidOperation)   { str += "Invalid operation, " }
    if self.contains(.lostDigits)         { str += "Lost digits, " }
    if self.contains(.overflow)           { str += "Overflow, " }
    if self.contains(.clamped)            { str += "Clamped, " }
    if self.contains(.rounded)            { str += "Rounded, " }
    if self.contains(.subnormal)          { str += "Subnormal, " }
    if self.contains(.underflow)          { str += "Underflow, " }
    if str.hasSuffix(", ")                { str.removeLast(2) }
    return str
  }
}
