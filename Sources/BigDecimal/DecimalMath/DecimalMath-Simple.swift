//
//  SimpleDecimalMath.swift
//  
//
//  Created by Mike Griebling on 10.07.2023.
//

// import RealModule - temporarily removed due to playground incompatibility

/// `Real` number protocol compliance using a simplified interface with
/// a fixed precision given by a global rounding context: `BigDecimal.mc`.
//extension BigDecimal { // : Real {
//    
//    @inlinable
//    public static func atan2(y: BigDecimal, x: BigDecimal) -> BigDecimal {
//        Self.atan2(x, y, Self.mc)
//    }
//    
//    @inlinable
//    public static func erf(_ x: BigDecimal) -> BigDecimal {
//        assertionFailure(#function + " not currently defined!")
//        return 0 // FIXME: - Not currently defined
//    }
//    
//    @inlinable
//    public static func erfc(_ x: BigDecimal) -> BigDecimal {
//        assertionFailure(#function + " not currently defined!")
//        return 0 // FIXME: - Not currently defined
//    }
//    
//    @inlinable
//    public static func exp2(_ x: BigDecimal) -> BigDecimal {
//        Self.pow(2, x, Self.mc)
//    }
//    
//    @inlinable
//    public static func hypot(_ x: BigDecimal, _ y: BigDecimal) -> BigDecimal {
//        Self.sqrt(x * x + y * y, Self.mc)
//    }
//    
//    @inlinable
//    public static func gamma(_ x: BigDecimal) -> BigDecimal {
//        Self.gamma(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func log2(_ x: BigDecimal) -> BigDecimal {
//        Self.log2(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func log10(_ x: BigDecimal) -> BigDecimal {
//        Self.log10(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func logGamma(_ x: BigDecimal) -> BigDecimal {
//        assertionFailure(#function + " not currently defined!")
//        return 0 // FIXME: - Not currently defined
//    }
//    
//    @inlinable
//    public static func exp(_ x: BigDecimal) -> BigDecimal {
//        Self.exp(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func expMinusOne(_ x: BigDecimal) -> BigDecimal {
//        let mc2 = Rounding(Self.mc.mode, Self.mc.precision << 1) // double precision
//        return Self.exp(x, mc2).subtract(one, Self.mc)
//    }
//    
//    @inlinable
//    public static func cosh(_ x: BigDecimal) -> BigDecimal {
//        Self.cosh(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func sinh(_ x: BigDecimal) -> BigDecimal {
//        Self.sinh(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func tanh(_ x: BigDecimal) -> BigDecimal {
//        Self.tanh(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func cos(_ x: BigDecimal) -> BigDecimal {
//        Self.cos(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func sin(_ x: BigDecimal) -> BigDecimal {
//        Self.sin(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func tan(_ x: BigDecimal) -> BigDecimal {
//        Self.tan(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func log(_ x: BigDecimal) -> BigDecimal {
//        Self.log(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func log(onePlus x: BigDecimal) -> BigDecimal {
//        // FIXME: - Not sure if this is the best approach
//        let xPOne = x.add(one, Rounding(Self.mc.mode, Self.mc.precision << 1))
//        return Self.log(xPOne, Self.mc)
//    }
//    
//    @inlinable
//    public static func acosh(_ x: BigDecimal) -> BigDecimal {
//        Self.acosh(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func asinh(_ x: BigDecimal) -> BigDecimal {
//        Self.asinh(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func atanh(_ x: BigDecimal) -> BigDecimal {
//        Self.atanh(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func acos(_ x: BigDecimal) -> BigDecimal {
//        Self.acos(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func asin(_ x: BigDecimal) -> BigDecimal {
//        Self.asin(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func atan(_ x: BigDecimal) -> BigDecimal {
//        Self.atan(x, Self.mc)
//    }
//    
//    @inlinable
//    public static func root(_ x: BigDecimal, _ n: Int) -> BigDecimal {
//        Self.root(x, BigDecimal(n), Self.mc)
//    }
//}
