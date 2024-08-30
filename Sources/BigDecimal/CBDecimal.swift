//
//  Complex.swift
//  BigDecimal
//
//  Created by Mike Griebling on 28.08.2024.
//

import Foundation
import ComplexModule
import RealModule

public typealias CBDecimal = Complex<BigDecimal>

// Satisfies the Real protocol requirements
extension BigDecimal : Real {
    // operations for this are already defined elsewhere
}

// supports things like "\(x)"
extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: CBDecimal) {
        appendLiteral(value.description)
    }
}

extension Complex where RealType == BigDecimal {
    
    // FIXME: Decimal is not an unlimited-precision number
    public init(stringLiteral s:String) {
        let s = s.replacingOccurrences(of: " ", with: "")
        guard !s.isEmpty else { self = .zero; return }
        
        let scanner = Scanner(string: s)
        var real = BigDecimal.zero
        var imag = BigDecimal.zero
        
        // special case since scanDecimal interprets "-i" as valid
        if s == "-i" { self = -Self.i; return }
        
        if let n = scanner.scanDecimal() {
            if scanner.isAtEnd {
                // we have a rea number
                real = BigDecimal(n)
            } else {
                real = BigDecimal(n)
                if let n = scanner.scanDecimal(), let c = scanner.scanCharacter() {
                    if c == "i" {
                        if n == 0 { imag = BigDecimal.one } // fix Scanner bug
                        else { imag = BigDecimal(n) }
                    }
                }
            }
        } else if let c = scanner.scanCharacter() {
            if c == "i" {
                imag = BigDecimal(1)
            }
        }
        self.init(real, imag)
    }
    
}

// MARK: - Formatting
extension Complex where RealType == BigDecimal {
    
    // Note: does not override default `description` when printing??
    public var description: String {
        guard isFinite else {
            return "inf"
        }
        var r = real.asString(.plain)
        if r.hasSuffix(".0") {
            r.removeLast(2)
        }
        var i = "\(imaginary.abs)"
        if i.hasSuffix(".0") {
            i.removeLast(2)
        }
        if imaginary.isNegative {
            i = "-" + i
        }
        
        if real.isZero {
            if imaginary.isZero {
                return "0"
            } else if imaginary.abs == BigDecimal.one {
                if imaginary.isNegative {
                    return "-i"
                }
                return "i"
            } else {
                return i + "i"
            }
        } else if imaginary.isZero {
            return "\(r)"
        } else if imaginary.abs == BigDecimal.one {
            if imaginary.isNegative {
                return "\(r)-" + "i"
            }
            return "\(r)+" + "i"
        }
        if imaginary.isNegative {
            return "\(r)" + i + "i"
        }
        return "\(r)+" + i + "i"
    }
    
}
