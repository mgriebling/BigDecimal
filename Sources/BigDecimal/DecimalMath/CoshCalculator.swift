
//
//  CoshCalculator.swift
//
//
//  Created by Mike Griebling on 07.07.2023.
//

import BigInt

/**
 * Calculates hyperbolic cosine using the Maclaurin/Taylor series.
 *
 * See Wikipedia: [Taylor Series][tser].
 *
 * [tser]: https://en.wikipedia.org/wiki/Taylor_series
 *
 * No argument checking or optimizations are done.
 * This implementation is **not** intended to be called directly.
 */
public struct CoshCalculator : SeriesCalculator, Sendable {
    public var calculateInPairs: Bool
    public var factors: [BigRational]
    
    static var instance = CoshCalculator()
    
    private var n = 0
    private var factorial2n = BigRational.ONE
    
    public init() {
        self.factors = []
        self.calculateInPairs = true
    }
    
    public func getCurrentFactor() -> BigRational {
        factorial2n.invert() // reciprocal
    }
    
    public mutating func calculateNextFactor() {
        n+=1
        factorial2n = factorial2n * BInt(2 * n - 1) * (2 * n)
    }
    
    public func createPowerIterator(_ x:BigDecimal, _ mc:Rounding) -> PowerIterator {
        PowerTwoNIterator(x, mc)
    }
}
