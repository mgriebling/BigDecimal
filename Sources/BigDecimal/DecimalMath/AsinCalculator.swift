///
//  AsinCalculator.swift
//
//
//  Created by Mike Griebling on 06.07.2023.
//

import BigInt

/**
 * Calculates arcsine using the Maclaurin/Taylor series.
 *
 * See Wikipedia: [Taylor Series][tser].
 *
 * [tser]: https://en.wikipedia.org/wiki/Taylor_series
 *
 * No argument checking or optimizations are done.
 * This implementation is **not** intended to be called directly.
 */
public struct AsinCalculator : SeriesCalculator, Sendable {
    public var calculateInPairs: Bool
    public var factors: [BigRational]
    
    static var instance = AsinCalculator()
    
    private var n = 0
    private var factorial2n = BigRational.ONE
    private var factorialN = BigRational.ONE
    private var fourPowerN = BigRational.ONE
    
    public init() {
        self.factors = []
        self.calculateInPairs = false
    }
    
    public func getCurrentFactor() -> BigRational {
        let factor = factorial2n / (fourPowerN * factorialN * factorialN * (2 * n + 1))
        return factor
    }
    
    public mutating func calculateNextFactor() {
        n+=1
        factorial2n = factorial2n * (2 * n - 1) * (2 * n)
        factorialN = factorialN * n
        fourPowerN = fourPowerN * 4
    }
    
    public func createPowerIterator(_ x:BigDecimal, _ mc:Rounding) -> PowerIterator {
        PowerTwoNPlusOneIterator(x, mc)
    }
}
