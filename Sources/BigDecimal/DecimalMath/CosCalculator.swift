
//
//  CosCalculator.swift
//
//
//  Created by Mike Griebling on 07.07.2023.
//

import BigInt

/**
 * Calculates cosine using the Maclaurin/Taylor series.
 *
 * See Wikipedia: [Taylor Series][tser].
 *
 * [tser]: https://en.wikipedia.org/wiki/Taylor_series
 *
 * No argument checking or optimizations are done.
 * This implementation is **not** intended to be called directly.
 */
public struct CosCalculator : SeriesCalculator, Sendable {
    public var calculateInPairs: Bool
    public var factors: [BigInt.BFraction]
    
    static var instance = CosCalculator()
    
    private var n = 0
    private var negative = false
    private var factorial2n = BigRational.ONE
    
    public init() {
        self.factors = []
        self.calculateInPairs = true
    }
    
    public func getCurrentFactor() -> BigRational {
        var factor = factorial2n.invert() // reciprocal
        if negative {
            factor = -factor
        }
        return factor
    }
    
    public mutating func calculateNextFactor() {
        n+=1
        factorial2n = factorial2n * (2 * n - 1) * (2 * n)
        negative = !negative
    }
    
    public func createPowerIterator(_ x:BigDecimal, _ mc:Rounding) -> PowerIterator {
        PowerTwoNIterator(x, mc)
    }
}
