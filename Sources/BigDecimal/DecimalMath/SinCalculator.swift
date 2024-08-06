//
//  SinCalculator.swift
//  
//
//  Created by Mike Griebling on 06.07.2023.
//

import BigInt

/**
 * Calculates sine using the Maclaurin/Taylor series.
 *
 * See Wikipedia: [Taylor Series][tser].
 *
 * [tser]: https://en.wikipedia.org/wiki/Taylor_series
 *
 * No argument checking or optimizations are done.
 * This implementation is **not** intended to be called directly.
 */
public struct SinCalculator : SeriesCalculator, Sendable {
    public var calculateInPairs: Bool
    public var factors: [BigRational]
    
    static var instance = SinCalculator()
    
    private var n = 0
    private var negative = false
    private var factorial2nPlus1 = BigRational.ONE
    
    public init() {
        self.factors = []
        self.calculateInPairs = true
    }
    
    public func getCurrentFactor() -> BigRational {
        var factor = factorial2nPlus1.invert() // reciprocal?
        if negative {
            factor = -factor
        }
        return factor
    }
    
    public mutating func calculateNextFactor() {
        n+=1
        factorial2nPlus1 = factorial2nPlus1 * BInt(2 * n)
        factorial2nPlus1 = factorial2nPlus1 * BInt(2 * n + 1)
        negative = !negative
    }
    
    public func createPowerIterator(_ x:BigDecimal, _ mc:Rounding) -> PowerIterator {
        PowerTwoNPlusOneIterator(x, mc)
    }
}
