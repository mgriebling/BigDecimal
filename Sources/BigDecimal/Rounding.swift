//
//  Rounding.swift
//  BigDecimalTest
//
//  Created by Leif Ibsen on 27/10/2022.
//

import BigInt

/// The rounding modes
public typealias Mode = FloatingPointRoundingRule

extension Mode : CustomStringConvertible {
    public var description: String {
        switch self {
            case .awayFromZero:
                return "Round towards +infinity"
            case .down:
                return "Round towards 0"
            case .towardZero:
                return "Round towards -infinity"
            case .toNearestOrEven:
                return "Round to nearest, tie to even"
            case .toNearestOrAwayFromZero:
                return "Round to nearest, tie away from 0"
            case .up:
                return "Round away from 0"
            @unknown default:
                assertionFailure("Unknown \(Self.self) rounding mode")
                return ""
        }
    }
}

/// BigDecimal rounding object containing a rounding mode and a precision
/// which is the number of digits in the rounded result
public struct Rounding: Equatable {
//    public enum Mode: CustomStringConvertible {
//
//        /// Round towards +infinity
//        case awayFromZero
//
//        /// Round towards 0
//        case down
//
//        /// Round towards -infinity
//        case towardZero
//
////        /// Round to nearest, tie towards 0
////        case towardZero
//
//        /// Round to nearest, tie to even
//        case toNearestOrEven
//
//        /// Round to nearest, tie away from 0
//        case toNearestOrAwayFromZero
//
//        /// Round away from 0
//        case up


    
    
    // MARK: Constants

    /// Decimal32 rounding: HALF_EVEN, 7
    public static let decimal32 = Rounding(.toNearestOrEven, 7)
    /// Decimal64 rounding: HALF_EVEN, 16
    public static let decimal64 = Rounding(.toNearestOrEven, 16)
    /// Decimal128 rounding: HALF_EVEN, 34
    public static let decimal128 = Rounding(.toNearestOrEven, 34)


    // MARK: - Initializer

    /// Constructs a Rounding object from mode and precision
    ///
    /// - Parameters:
    ///   - mode: The rounding mode
    ///   - precision: The rounding precision - a positive number
    public init(_ mode: Mode, _ precision: Int) {
        self.mode = mode
        self.precision = Swift.max(precision, 1)
    }
    
    
    // MARK: - Stored properties

    /// The rounding mode
    public internal(set) var mode: Mode
    
    /// The rounding precision - a positive number
    public internal(set) var precision: Int

    
    // MARK: Round function
    
    /// Round
    ///
    /// - Parameters:
    ///   - x: The value to be rounded
    /// - Returns: The value of *x* rounded according to *self*
    public func round(_ x: BigDecimal) -> BigDecimal {
        if x.isNaN  {
            return BigDecimal.flagNaN()
        } else if x.isInfinite {
            return x
        }
        let d = x.precision - self.precision
        if d <= 0 {
            return x
        }
        let q = roundBInt(x.digits, d)
        let pr = q.abs.asString().count
        if pr > self.precision {
            // 999.9 => 1000
            return BigDecimal(q / BInt.ten, x.exponent + d + 1)
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
                    //            case .towardZero:
                    //                if d1 == d2 {
                    //                    q = negative ? q2 : q1
                    //                } else {
                    //                    q = d1 < d2 ? q1 : q2
                    //                }
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
        BInt(1000),
        BInt(10000),
        BInt(100000),
        BInt(1000000),
        BInt(10000000),
        BInt(100000000),
        BInt(1000000000),
        BInt(10000000000),
        BInt(100000000000),
        BInt(1000000000000),
        BInt(10000000000000),
        BInt(100000000000000),
        BInt(1000000000000000),
        BInt(10000000000000000),
        BInt(100000000000000000),
        BInt(1000000000000000000),
    ]
    
    static func pow10(_ n: Int) -> BInt {
        assert(n >= 0)
        return n < pow10table.count ? pow10table[n] : BInt.ten ** n
    }

}
