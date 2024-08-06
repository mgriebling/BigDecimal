//
//  SeriesCalculator.swift
//  
//
//  Created by Mike Griebling on 06.07.2023.
//

import BigInt

public protocol SeriesCalculator: Sendable {
    
    typealias BigRational = BigInt.BFraction
    
    var calculateInPairs: Bool { get set }
    var factors: [BigInt.BFraction] { get set }
    
    /**
     * Constructs a ``SeriesCalculator`` with control over whether the sum
     * terms are calculated in pairs.
     *
     * Calculation of pairs is useful for taylor series where the terms alternate the sign.
     * In these cases it is more efficient to calculate two terms at once check then whether the acceptable error has been reached.
     *
     * - Parameter calculateInPairs: Set to `true` to calculate the terms in pairs, `false` to calculate single terms
     */
    init(_ calculateInPairs: Bool)
    init()
    
    /**
     * Calculates the series for the specified value x and the precision
     * defined in the ``Rounding`` context.
     *
     * - Parameters:
     *   - x: The value x
     *   - mc: The ``Rounding`` context
     * - Returns: The calculated result
     */
    mutating func calculate(_ x: BigDecimal, _ mc: Rounding) -> BigDecimal
    
    /**
     * Creates the ``PowerIterator`` used for this series.
     *
     * - Parameters:
     *    - x: the value x
     *    - mc: the ``Rounding`` context
     * - Returns:the ``PowerIterator``
     */
    func createPowerIterator(_ x: BigDecimal, _ mc: Rounding) -> PowerIterator
    
    /**
     * Returns the factor of the term with specified index.
     *
     * All mutable state of this class (and all its subclasses) must be modified in this method.
     * This method is synchronized to allow thread-safe usage of this class.
     *
     * - Parameter index: The index (starting with 0)
     * - Returns: The factor of the specified term
     */
    mutating func getFactor(_ index: Int) -> BigRational

    mutating func addFactor(_ factor: BigRational)

    /**
     * Returns the factor of the highest term already calculated.
     * When called for the first time will return the factor of the first term (index 0).
     * After this call the method ``calculateNextFactor()`` will be called to prepare for the next term.
     *
     * - Returns: The factor of the highest term
     */
    func getCurrentFactor() -> BigRational
    
    /**
     * Calculates the factor of the next term.
     */
    mutating func calculateNextFactor()
}

extension SeriesCalculator {
    
    public init(_ calculateInPairs: Bool) {
        self.init()
        self.calculateInPairs = calculateInPairs
    }
    
    public mutating func calculate(_ x: BigDecimal, _ mc: Rounding) -> BigDecimal {
        let acceptableError = BigDecimal(1, -(mc.precision+1))
        var powerIterator = createPowerIterator(x, mc)
        
        var sum = BigDecimal.zero
        var step: BigDecimal
        var i = 0
        repeat {
            var factor = getFactor(i)
            var xToThePower = powerIterator.getCurrentPower()
            
            powerIterator.calculateNextPower()
            step = (BigDecimal(factor.numerator) * xToThePower).divide(factor.denominator, mc)
            i+=1
            
            if calculateInPairs {
                factor = getFactor(i);
                xToThePower = powerIterator.getCurrentPower();
                powerIterator.calculateNextPower();
                let step2 = (BigDecimal(factor.numerator) * xToThePower).divide(factor.denominator, mc)
                step = step + step2
                i+=1
            }
            
            sum = sum + step
        } while step.abs.compare(acceptableError) > 0
        
        return sum.round(mc)
    }
    
    public mutating func getFactor(_ index: Int) -> BigInt.BFraction {
        while factors.count <= index {
            let factor = getCurrentFactor()
            addFactor(factor)
            calculateNextFactor()
        }
        return factors[index]
    }

    public mutating func addFactor(_ factor: BigInt.BFraction) {
        factors.append(factor)
    }
}

public protocol PowerIterator {
    
    /**
     * Returns the current power.
     *
     * - Returns: the current power.
     */
    func getCurrentPower() -> BigDecimal
    
    /**
     * Calculates the next power.
     */
    mutating func calculateNextPower()
}

public struct PowerNIterator : PowerIterator {
    private var x: BigDecimal
    private var mc: Rounding
    private var powerOfX: BigDecimal
    
    init(_ x: BigDecimal, _ mc: Rounding) {
        self.x = x
        self.mc = mc
        self.powerOfX = BigDecimal.one
    }
    
    public func getCurrentPower() -> BigDecimal { powerOfX }
    
    public mutating func calculateNextPower() {
        powerOfX = powerOfX.multiply(x, mc)
    }
}

/**
 * ``PowerIterator`` to calculate the 2*n+1 term.
 */
public struct PowerTwoNPlusOneIterator : PowerIterator {

    private var xPowerTwo: BigDecimal
    private var mc: Rounding
    private var powerOfX: BigDecimal

    init(_ x: BigDecimal, _ mc: Rounding) {
        self.mc = mc
        xPowerTwo = x.multiply(x, mc)
        powerOfX = x
    }
    
    public func getCurrentPower() -> BigDecimal { powerOfX }

    public mutating func calculateNextPower() {
        powerOfX = powerOfX.multiply(xPowerTwo, mc)
    }
}

/**
 * ``PowerIterator`` to calculate the 2*n term.
 */
public struct PowerTwoNIterator : PowerIterator {

    private var mc: Rounding
    private var xPowerTwo: BigDecimal
    private var powerOfX: BigDecimal

    init(_ x: BigDecimal, _ mc: Rounding) {
        self.mc = mc
        xPowerTwo = x.multiply(x, mc)
        powerOfX = BigDecimal.one
    }
    
    public func getCurrentPower() -> BigDecimal { powerOfX }

    public mutating func calculateNextPower() {
        powerOfX = powerOfX.multiply(xPowerTwo, mc);
    }
}

