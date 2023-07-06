//
//  ExponentCalculator.swift
//  
//
//  Created by Mike Griebling on 06.07.2023.
//
import BigInt

public struct ExpCalculator : SeriesCalculator {
    public static var instance = ExpCalculator()
    
    public var calculateInPairs: Bool
    public var factors = [BigInt.BFraction]()
    
    private var n = 0
    private var oneOverFactorialOfN = BigRational.ONE
    
    public init(_ calculateInPairs: Bool) {
        self.calculateInPairs = calculateInPairs
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

