//
//  SinCalculator.swift
//  
//
//  Created by Mike Griebling on 06.07.2023.
//

import BigInt

/**
 * Calculates sine using the Maclaurin series.
 *
 * <p>See <a href="https://de.wikipedia.org/wiki/Taylorreihe">Wikipedia: Taylorreihe</a></p>
 *
 * <p>No argument checking or optimizations are done.
 * This implementation is <strong>not</strong> intended to be called directly.</p>
 */
public struct SinCalculator : SeriesCalculator {
    public var calculateInPairs: Bool
    public var factors: [BigRational]
    
    static var instance = SinCalculator()
    
    private var n = 0
    private var negative = false
    private var factorial2nPlus1 = BigRational.ONE
    
    public init(_ calculateInPairs: Bool) {
        self.init()
        self.calculateInPairs = calculateInPairs
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
