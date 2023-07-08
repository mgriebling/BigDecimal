//
//  SinhCalculator.swift
//  
//
//  Created by Mike Griebling on 07.07.2023.
//

import BigInt

/**
 * Calculates the hyperbolic sine using the Taylor series.
 *
 * <p>See <a href="https://de.wikipedia.org/wiki/Taylorreihe">Wikipedia: Taylorreihe</a></p>
 *
 * <p>No argument checking or optimizations are done.
 * This implementation is <strong>not</strong> intended to be called directly.</p>
 */
public struct SinhCalculator : SeriesCalculator {
    public var calculateInPairs: Bool
    public var factors: [BigRational]
    
    static var instance = SinhCalculator()
    
    private var n = 0
    private var factorial2nPlus1 = BigRational.ONE
    
    public init() {
        self.factors = []
        self.calculateInPairs = true
    }
    
    public func getCurrentFactor() -> BigRational {
        factorial2nPlus1.invert() // reciprocal
    }
    
    public mutating func calculateNextFactor() {
        n+=1
        factorial2nPlus1 = factorial2nPlus1 * BInt(2 * n)
        factorial2nPlus1 = factorial2nPlus1 * BInt(2 * n + 1)
    }
    
    public func createPowerIterator(_ x:BigDecimal, _ mc:Rounding) -> PowerIterator {
        PowerTwoNPlusOneIterator(x, mc)
    }
}
