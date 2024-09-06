//
//  ExponentCalculator.swift
//  
//
//  Created by Mike Griebling on 06.07.2023.
//

import BigInt

/**
 * Calculates exp using the Maclaurin/Taylor series.
 *
 * See Wikipedia: [Taylor Series][tser].
 *
 * [tser]: https://en.wikipedia.org/wiki/Taylor_series
 *
 * No argument checking or optimizations are done.
 * This implementation is **not** intended to be called directly.
 */
public struct ExpCalculator : SeriesCalculator, Sendable {    
    public static var instance = ExpCalculator()
    
    public var calculateInPairs: Bool
    public var factors = [BigInt.BFraction]()
    
    private var n = 0
    private var oneOverFactorialOfN = BigRational.ONE
    
    public init() {
        self.factors = []
        self.calculateInPairs = false
    }
    
    public func createPowerIterator(_ x: BigDecimal, _ mc: Rounding) -> PowerIterator {
        PowerNIterator(x, mc)
    }
    
    public func getCurrentFactor() -> BigRational {
        oneOverFactorialOfN
    }
    
    public mutating func calculateNextFactor() {
        n += 1
        oneOverFactorialOfN = oneOverFactorialOfN / n
    }
}

