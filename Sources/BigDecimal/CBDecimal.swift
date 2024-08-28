//
//  Complex.swift
//  BigDecimal
//
//  Created by Mike Griebling on 28.08.2024.
//

import ComplexModule

//extension CBDecimal {
//    
//    // Some nicer convenience initializers
//    
//    public init(_ real: StaticBigInt, i: StaticBigInt = 0) {
//        self.init(BigDecimal(integerLiteral: real), BigDecimal(integerLiteral: i))
//    }
//
//}

// MARK: - Formatting
extension Complex where RealType == BigDecimal {
    
    public var description: String {
        guard isFinite else {
            return "inf"
        }
        var r = "\(real)"
        if r.hasSuffix(".0") {
            r.removeLast(2)
        }
        var i = "\(imaginary.abs)"
        if i.hasSuffix(".0") {
            i.removeLast(2)
        }
        if imaginary.isNegative {
            i += "-" + i
        }
        
        if real.isZero {
            if imaginary.isZero {
                return "0"
            } else if imaginary.abs == BigDecimal.one {
                return i
            } else {
                return i + "i"
            }
        } else if imaginary.isZero {
            return "\(r)"
        } else if imaginary.abs == BigDecimal.one {
            return "\(r)" + i
        }
        if imaginary.isNegative {
            return "\(r)" + i + "i"
        }
        return "\(r)+" + i + "i"
    }
    
}
