//
//  DecimalLogic.swift
//  
//
//  Created by Mike Griebling on 18.07.2023.
//

import BigInt

extension BigDecimal {

    static func doLogic (_ lhs: Self, _ op: (BInt, BInt) -> BInt,
                         _ rhs: Self) -> Self {
        guard lhs.isFinite else { return lhs }
        guard rhs.isFinite else { return rhs }
        let x = integralPart(lhs).digits
        let y = integralPart(rhs).digits
        return Self(op(x,y))
    }
    
    /// Implementation of a logical AND.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number. For example:
    /// ```swift
    ///  BigDecimal("56.7") & BigDecimal("89.13") = 24
    /// ```
    public static func & (lhs:Self, rhs:Self) -> Self { doLogic(lhs, &, rhs) }
    
    /// Implementation of a logical OR.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number
    /// For example:
    /// ```swift
    /// BigDecimal("56.7") | BigDecimal("89.13") = 121
    /// ```
    public static func | (lhs:Self, rhs:Self) -> Self { doLogic(lhs, |, rhs) }
    
    /// Implementation of a logical XOR.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number
    /// For example:
    /// ```swift
    /// BigDecimal("56.7") ^ BigDecimal("89.13") = 97
    /// ```
    public static func ^ (lhs:Self, rhs:Self) -> Self { doLogic(lhs, ^, rhs) }
    
    /// Implementation of a logical NOT.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number
    /// For example:
    ///```swift
    /// ~BigDecimal("56.7") = -57
    /// ```
    public static prefix func ~ (lhs:Self) -> Self {
        guard lhs.isFinite else { return lhs }
        let x = integralPart(lhs).digits
        return Self(~x)
    }
    
    /// Implementation of a logical NAND.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number
    /// For example:
    ///```swift
    /// nand(BigDecimal("56.7"), BigDecimal("89.13")) = 7
    /// ```
    public static func nand (_ lhs:Self, _ rhs:Self) -> Self { ~(lhs & rhs) }
    
    /// Implementation of a logical NOR.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number
    /// For example:
    ///```swift
    /// nor(BigDecimal("56.7"), BigDecimal("89.13")) = 902
    /// ```
    public static func nor (_ lhs:Self, _ rhs:Self) -> Self { ~(lhs | rhs) }
    
    /// Implementation of a logical XNOR.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number
    /// For example:
    ///```swift
    /// xnor(BigDecimal("56.7"), BigDecimal("89.13")) = 926
    /// ```
    public static func xnor (_ lhs:Self, _ rhs:Self) -> Self { ~(lhs ^ rhs) }
    
    /// Set the `n`th bit of the number and return the value where `n` ≥ 0.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number.
    /// For example:
    /// ```swift
    /// Self.setBit(20, of: Self.zero) = 1048576
    /// ```
    public static func setBit (_ n:Int, of x: Self) -> Self {
        var a = x
        a.digits.setBit(n)
        return Self(a)
    }
    
    /// Clears the `n`th bit of the number and return the value where `n` ≥ 0.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number.
    /// For example:
    ///```swift
    /// clearBit(20, of: 1_000_000_000) = 998951424
    /// ```
    public static func clearBit (_ n:Int, of x: Self) -> Self {
        var a = x
        a.digits.clearBit(n)
        return Self(a)
    }
    
    /// Toggles the `n`th bit of the number and return the value where `n` ≥ 0.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number.
    /// For example:
    /// ```swift
    /// toggleBit(20, of: 1_000) = 1049576
    /// ```
    public static func toggleBit (_ n:Int, of x: Self) -> Self {
        var a = x
        a.digits.flipBit(n)
        return Self(a)
    }
    
    /// Tests the `n`th bit of `x` and returns`true` if the bit is set
    /// and `false` if `n` < 0 or the bit is not set.
    ///
    /// Arguments will be converted to integral numbers using truncation
    /// and the result will also be an integral number.
    /// For example:
    /// ```swift
    /// testBit(20, of: 1_000_000_000) = true
    /// ```
    public static func testBit (_ n:Int, of x: Self) -> Bool {
        x.digits.testBit(n)
    }
}
