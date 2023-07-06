/**
 * Calculates cosinus using the Maclaurin series.
 *
 * <p>See <a href="https://de.wikipedia.org/wiki/Taylorreihe">Wikipedia: Taylorreihe</a></p>
 *
 * <p>No argument checking or optimizations are done.
 * This implementation is <strong>not</strong> intended to be called directly.</p>
 */
import BigInt

public struct CosCalculator : SeriesCalculator {
    public var calculateInPairs: Bool
    public var factors: [BigInt.BFraction]
    
    static var instance = CosCalculator()
    
    private var n = 0
    private var negative = false
    private var factorial2n = BigRational.ONE
    
    public init(_ calculateInPairs: Bool) {
        self.init()
        self.calculateInPairs = calculateInPairs
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
