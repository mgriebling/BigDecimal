//
//  BigDecimalMath.swift
//
//  Created by Mike Griebling on 25.06.2023 from an original Java
//  implementation.
//

import BigInt
import Foundation

public extension BigDecimal {
    
    static private let expectedInitialPrecision = 15
    static private let oneHalf = BigDecimal(0.5)
    static private let doubleMax = BigDecimal(Double.greatestFiniteMagnitude)
    
    /// Creates a BigDecimal for the integer _n_ where the
    /// integer can be any type conforming to the _BinaryInteger_ protocols.
    init<T:BinaryInteger>(_ int: T) {
        var x = Self.zero, m = Self.one
        var n = int.magnitude, r = T.Magnitude.zero
        let base = 1_000_000_000, rd = Self(base), id = T(base)
        while n != 0 {
            (n, r) = n.quotientAndRemainder(dividingBy: id.magnitude)
            if r != 0 { x.addProduct(m, Self(r)) }
            m *= rd
        }
        self = int.signum() < 0 ? -x : x
    }
    
    func asInt<I:FixedWidthInteger>() -> I? {
        let n = self
        if n.abs < 1 { return nil }  // check for fractions, magnitude >= 0
        if n >= Self(I.max) { return nil }
        if n <= Self(I.min) { return nil }
        
        /// value must be in range of the return integer type
        let digits = n.abs.round(Rounding(.towardZero, 0)) // truncate any fractions
        let coeff = digits.digits
        let power : BInt = BInt(10) ** digits.exponent
        if let int = (coeff * power).asInt() {
            return n.isNegative ? (0-I(int)) : I(int)
        }
        return nil
    }
    
    /**
     * Returns whether the specified `BigDecimal` value can be represented as <code>int</code>.
     *
     * If this returns <code>true</code> you can call {@link BigDecimal#intValueExact()} without fear of an {@link ArithmeticException}.</p>
     *
     * @param value the `BigDecimal` to check
     * @return <code>true</code> if the value can be represented as <code>int</code> value
     */
    static func isIntValue(_ value:Self) -> Bool {
        if value > BigDecimal(Int.max) {
            return false
        }
        if value < BigDecimal(Int.min) {
            return false
        }
        return true
    }
    
    /**
     * Returns whether the specified `BigDecimal` value can be represented as <code>double</code>.
     *
     * If this returns <code>true</code> you can call {@link BigDecimal#doubleValue()}
     * without fear of getting {@link Double#POSITIVE_INFINITY} or {@link Double#NEGATIVE_INFINITY} as result.</p>
     *
     * Example: <code>BigDecimalMath.isDoubleValue(new BigDecimal("1E309"))</code> returns <code>false</code>,
     * because <code>new BigDecimal("1E309").doubleValue()</code> returns <code>Infinity</code>.</p>
     *
     * Note: This method does <strong>not</strong> check for possible loss of precision.</p>
     *
     * For example <code>BigDecimalMath.isDoubleValue(new BigDecimal("1.23400000000000000000000000000000001"))</code> will return <code>true</code>,
     * because <code>new BigDecimal("1.23400000000000000000000000000000001").doubleValue()</code> returns a valid double value,
     * although it loses precision and returns <code>1.234</code>.</p>
     *
     * <code>BigDecimalMath.isDoubleValue(new BigDecimal("1E-325"))</code> will return <code>true</code>
     * although this value is smaller than {@link Double#MIN_VALUE} (and therefore outside the range of values that can be represented as <code>double</code>)
     * because <code>new BigDecimal("1E-325").doubleValue()</code> returns <code>0</code> which is a legal value with loss of precision.</p>
     *
     * @param value the `BigDecimal` to check
     * @return <code>true</code> if the value can be represented as <code>double</code> value
     */
    static func isDoubleValue(_ value:Self) -> Bool {
        if value > doubleMax {
            return false
        }
        if value < -doubleMax {
            return false
        }
        return true
    }
    
    /**
     * Returns the integral part of the specified `BigDecimal` (left of the decimal point).
     *
     * @param value the `BigDecimal`
     * @return the integral part
     * @see #fractionalPart(BigDecimal)
     */
    static func integralPart(_ value:Self) -> Self {
        return value.withExponent(0, .down) //  setScale(0, Rou ROUND_DOWN);
    }
    
    /**
     * Returns the fractional part of the specified `BigDecimal` (right of the decimal point).
     *
     * @param value the `BigDecimal`
     * @return the fractional part
     * @see #integralPart(BigDecimal)
     */
    static func fractionalPart(_ value:Self) -> Self {
        return value - integralPart(value) // subtract(integralPart(value), Rounding(.HALF_EVEN, 0))
    }
    
    /**
     * Calculates the square root of ``BigDecimal`` `x`.
     *
     * See Wikipedia: Square root. http://en.wikipedia.org/wiki/Square_root.
     * - Parameters:
     *   - x: The ``BigDecimal`` value to calculate the square root
     *   - mc: The ``Rounding`` used for the result
     * - Returns: The calculated square root of `x` with the precision specified
     *            in the `mc`
     * */
    static func sqrt(_ x: BigDecimal, _ mc: Rounding) -> BigDecimal {
        guard x.signum >= 0 else { return BigDecimal.nan }
        if x.isZero { return zero }
        
        let maxPrecision = mc.precision + 6
        let acceptableError = BigDecimal(1, -(mc.precision+1))
        
        // get an initial estimate using Double
        var adaptivePrecision: Int
        var result: BigDecimal
        let d = x.asDouble()
        if d.isFinite {
            result = BigDecimal(d.squareRoot())
            adaptivePrecision = expectedInitialPrecision
        } else {
            result = x.multiply(oneHalf, mc)
            adaptivePrecision = 1
        }
        
        // get an iterative solution
        var last: BigDecimal
        if adaptivePrecision < maxPrecision {
            if result.multiply(result, mc) == x {
                return result.round(mc)
            }
            repeat {
                last = result
                adaptivePrecision <<= 1
                if adaptivePrecision > maxPrecision {
                    adaptivePrecision = maxPrecision
                }
                let mc = Rounding(mc.mode, adaptivePrecision)
                result = x.divide(result,mc).add(last,mc).multiply(oneHalf,mc)
                // print(result)
            } while adaptivePrecision < maxPrecision ||
                    result.subtract(last, mc).abs > acceptableError
        }
        
        return result.round(mc)
    }
    
    /**
     * Calculates the n'th root of ``BigDecimal`` `x`.
     *
     * See Wikipedia: Nth root -> https://en.wikipedia.org/wiki/Nth_root
     * - Parameters:
     *  - x: the `BigDecimal` value to calculate the n'th root
     *  - n: the `BigDecimal` defining the root
     *  - mc: the {@link MathContext} used for the result
     * - Returns: The calculated n'th root of x with the precision specified in the mathContext
     **/
    static func root(_ x:Self, _ n:Self, _ mc:Rounding) -> Self {
        precondition(n.signum > 0, "Illegal root(x, n) for n <= 0: n = \(n)")
        precondition(x.signum >= 0, "Illegal root(x, n) for x < 0: x = \(x)")
        if x.isZero { return zero }

        if x.isFinite && n.isFinite {
            let xd = x.asDouble(), nd = n.asDouble()
            let initialResult = Foundation.pow(xd, 1.0 / nd)
            if initialResult.isFinite {
                return rootUsingNewtonRaphson(x, n, Self(initialResult), mc)
            }
        }

        let mc2 = Rounding(mc.mode, mc.precision+6)
        return pow(x, one.divide(n, mc2), mc)
    }
    
    private static func rootUsingNewtonRaphson(_ x:Self, _ n:Self,
                                _ initialResult:Self, _ mc:Rounding) -> Self {
        if n <= one {
            let mc2 = Rounding(mc.mode, mc.precision+6)
            return pow(x, one.divide(n, mc2), mc)
        }

        let maxPrecision = mc.precision * 2;
        let acceptableError = BigDecimal(1, -(mc.precision+1))

        let nMinus1 = n.subtract(one, mc)
        var result = initialResult
        var adaptivePrecision = 12

        if adaptivePrecision < maxPrecision {
            var step:BigDecimal
            repeat {
                adaptivePrecision *= 3
                if adaptivePrecision > maxPrecision {
                    adaptivePrecision = maxPrecision
                }
                let mc = Rounding(mc.mode, adaptivePrecision)
                step = x.divide(pow(result, nMinus1, mc), mc)
                    .subtract(result, mc).divide(n, mc);
                result = result.add(step, mc)
            } while adaptivePrecision < maxPrecision ||
                    step.abs > acceptableError
        }

        return result.round(mc)
    }
    
    /**
     * Calculates `BigDecimal` x to the power of `BigDecimal` y (x<sup>y</sup>).
     *
     * @param x the `BigDecimal` value to take to the power
     * @param y the `BigDecimal` value to serve as exponent
     * @param mathContext the {@link MathContext} used for the result
     * @return the calculated x to the power of y with the precision specified in the <code>mathContext</code>
     * @throws UnsupportedOperationException if the {@link MathContext} has unlimited precision
     * @see #pow(BigDecimal, long, MathContext)
     */
    static func pow(_ x:Self, _ y:Self, _ mc:Rounding) -> Self {
        // checkMathContext(mathContext);
        if x.isZero {
            if y.isZero { return one }
            return zero
        }

        // TODO optimize y=0, y=1, y=10^k, y=-1, y=-10^k

        // try integral powers of y
        if let longValue : Int = y.asInt() {
            return x.pow(longValue)
        } else if fractionalPart(y) == 0 {
            return powInteger(x, y, mc)
        }

        // x^y = exp(y*log(x))
        let mc2 = Rounding(mc.mode, mc.precision+6)
        let result = exp(y.multiply(log(x, mc2), mc2), mc2)

        return result.round(mc)
    }
    
    /**
     * Calculates `BigDecimal` x to the power of the integer value y (x<sup>y</sup>).
     *
     * The value y MUST be an integer value.</p>
     *
     * @param x the `BigDecimal` value to take to the power
     * @param integerY the `BigDecimal` <strong>integer</strong> value to serve as exponent
     * @param mathContext the {@link MathContext} used for the result
     * @return the calculated x to the power of y with the precision specified in the <code>mathContext</code>
     * @see #pow(BigDecimal, long, MathContext)
     */
    private static func powInteger(_ x:Self, _ integerY:Self, _ mc:Rounding) -> Self {
        var integerY = integerY
        var x = x
        let trunc = Rounding(.towardZero, 0)
        if integerY != integerY.round(trunc) {
            assertionFailure("Not integer value: \(integerY)")
        }
        
        if integerY.signum < 0 {
            return one.divide(powInteger(x, -integerY, mc), mc)
        }

        let mc2 = Rounding(mc.mode, max(mc.precision, -integerY.exponent) + 30)

        var result = one
        let TWO = BigDecimal(2)
        while integerY.signum > 0 {
            var halfY = integerY.divide(TWO, mc2)

            if halfY != halfY.round(trunc) {
                // odd exponent -> multiply result with x
                result = result.multiply(x, mc2)
                integerY = integerY.subtract(one, mc2)
                halfY = integerY.divide(TWO, mc2)
            }
            
            if halfY.signum > 0 {
                // even exponent -> square x
                x = x.multiply(x, mc2)
            }
            
            integerY = halfY
        }

        return result.round(mc)
    }
    
    /**
     * Returns the number pi.
     *
     * See <a href="https://en.wikipedia.org/wiki/Pi">Wikipedia: Pi</a></p>
     *
     * @param mathContext the {@link MathContext} used for the result
     * @return the number pi with the precision specified in the <code>mathContext</code>
     * @throws UnsupportedOperationException if the {@link MathContext} has unlimited precision
     **/
    static func pi(_ mc: Rounding) -> Self {
        //checkMathContext(mathContext);
        let result: Self?
        
        if let pi = piCache, mc.precision <= pi.precision {
            result = pi
        } else {
            piCache = piChudnovski(mc)
            return piCache!
        }
        
        return mc.round(result!)
    }
    
    private static var piCache: BigDecimal?
    
    private static func piChudnovski(_ mc: Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 10)

        let value24 = Self(24)
        let value640320 = Self(640320)
        let value13591409 = Self(13591409)
        let value545140134 = Self(545140134)
        let valueDivisor = value640320.pow(3).divide(value24, mc2)

        var sumA = Self.one
        var sumB = Self.zero

        var a = Self.one
        var dividendTerm1 = 5; // -(6*k - 5)
        var dividendTerm2 = -1; // 2*k - 1
        var dividendTerm3 = -1; // 6*k - 1
        var kPower3 = Self.zero
        
        let iterationCount = (mc2.precision+13) / 14
        for k in 1...iterationCount {
            let valueK = Self(k)
            dividendTerm1 += -6
            dividendTerm2 += 2
            dividendTerm3 += 6
            let dividend = Self(dividendTerm1) * Self(dividendTerm2) * Self(dividendTerm3)
            kPower3 = valueK.pow(3)
            let divisor = kPower3.multiply(valueDivisor, mc2)
            a = (a * dividend).divide(divisor, mc2)
            let b = valueK.multiply(a, mc2);
            
            sumA = sumA + a
            sumB = sumB + b
        }
        
        let value426880 = Self(426880)
        let value10005 = Self(10005)
        let factor = value426880 * sqrt(value10005, mc2)
        let pi = factor.divide(value13591409.multiply(sumA, mc2) +
                               (value545140134.multiply(sumB, mc2)), mc2)
        return mc.round(pi)
    }
    
    /**
     * Calculates the natural exponent of `BigDecimal` x (e<sup>x</sup>).
     *
     * See: <a href="http://en.wikipedia.org/wiki/Exponent">Wikipedia: Exponent</a></p>
     *
     * @param x the `BigDecimal` to calculate the exponent for
     * @param mathContext the {@link MathContext} used for the result
     * @return the calculated exponent `BigDecimal` with the precision specified in the <code>mathContext</code>
     * @throws UnsupportedOperationException if the {@link MathContext} has unlimited precision
     */
    static func exp(_ x:Self, _ mc: Rounding) -> Self {
        // checkMathContext(mathContext);
        if x.signum == 0 { return one }

        return expIntegralFractional(x, mc)
    }

    private static func expIntegralFractional(_ x:Self, _ mc:Rounding) -> Self {
        let integralPart = integralPart(x)
        
        if integralPart.signum == 0 {
            return expTaylor(x, mc)
        }
        
        let fractionalPart = x - integralPart

        let mc2 = Rounding(mc.mode, mc.precision + 10)

        let z = one + fractionalPart.divide(integralPart, mc2)
        let t = expTaylor(z, mc2)

        let result: Self
        if let int : Int = integralPart.asInt() {
            result = t.pow(int, mc2)
        } else {
            result = zero
        }

        return result.round(mc)
    }
    
    private static func expTaylor(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)

        let x = x.divide(BigDecimal(256), mc2)
  // FIXME: - Need ExpCalculator
//        var result = ExpCalculator.INSTANCE.calculate(x, mc2);
//        result = BigDecimalMath.pow(result, 256, mc2);
        let result = x
        return result.round(mc)
    }
    
    /**
     * Calculates the natural logarithm of `BigDecimal` `x`.
     *
     * See: [Wikipedia: Natural logarithm][REF]
     * [REF]: http://en.wikipedia.org/wiki/Natural_logarithm
     *
     * @param x the `BigDecimal` to calculate the natural logarithm for
     * @param mathContext the {@link MathContext} used for the result
     * @return the calculated natural logarithm `BigDecimal` with the precision specified in the <code>mathContext</code>
     */
    static func log(_ x:Self, _ mc:Rounding) -> Self {
        // checkMathContext(mathContext);
        precondition(x.signum <= 0, "Illegal log(x) for x <= 0: x = \(x)")
        if x == one {
            return zero
        }
        
        let result: Self
        if      x == 10 { result = logTen(mc) }
        else if x > 10  { result = logUsingExponent(x, mc) }
        else            { result = logUsingTwoThree(x, mc) }
        return result.round(mc)
    }
    
    /**
     * Calculates the logarithm of `BigDecimal` x to the base 2.
     *
     * @param x the `BigDecimal` to calculate the logarithm base 2 for
     * @param mathContext the {@link MathContext} used for the result
     * @return the calculated natural logarithm `BigDecimal` to the base 2 with the precision specified in the <code>mathContext</code>
     * @throws ArithmeticException if x &lt;= 0
     * @throws UnsupportedOperationException if the {@link MathContext} has unlimited precision
     */
    static func log2(_ x:Self, _ mc:Rounding) -> Self {
        //checkMathContext(mathContext);
        let mc2 = Rounding(mc.mode, mc.precision + 4)

        let  result = log(x, mc2).divide(logTwo(mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the logarithm of `BigDecimal` x to the base 10.
     *
     * @param x the `BigDecimal` to calculate the logarithm base 10 for
     * @param mathContext the {@link MathContext} used for the result
     * @return the calculated natural logarithm `BigDecimal` to the base 10 with the precision specified in the <code>mathContext</code>
     * @throws ArithmeticException if x &lt;= 0
     * @throws UnsupportedOperationException if the {@link MathContext} has unlimited precision
     */
    static func log10(_ x:Self, _ mc:Rounding) -> Self {
        //heckMathContext(mathContext);
        let mc2 = Rounding(mc.mode, mc.precision + 2)

        let result = log(x, mc2).divide(logTen(mc2), mc2)
        return result.round(mc)
    }
    
    private static func logUsingNewton(_ x:Self, _ mc:Rounding) -> Self {
        // https://en.wikipedia.org/wiki/Natural_logarithm in chapter 'High Precision'
        // y = y + 2 * (x-exp(y)) / (x+exp(y))

        let maxPrecision = mc.precision + 20
        let acceptableError = BigDecimal(1, -(mc.precision+1))
        //System.out.println("logUsingNewton(" + x + " " + mathContext + ") precision " + maxPrecision);

        var result: Self
        var adaptivePrecision: Int
        let doubleX = x.asDouble()
        if doubleX > 0.0 && isDoubleValue(x) {
            result = BigDecimal(Foundation.log(doubleX))
            adaptivePrecision = expectedInitialPrecision
        } else {
            result = x.divide(2, mc)
            adaptivePrecision = 1
        }

        var step: Self
        repeat {
            adaptivePrecision *= 3;
            if (adaptivePrecision > maxPrecision) {
                adaptivePrecision = maxPrecision;
            }
            let mc2 = Rounding(mc.mode, adaptivePrecision)
            
            let expY = Self.exp(result, mc2)
            step = 2 * (x - expY).divide(x + expY, mc)
            //System.out.println("  step " + step + " adaptivePrecision=" + adaptivePrecision);
            result = result + step
        } while adaptivePrecision < maxPrecision || step.abs > acceptableError

        return result
    }

    private static func logUsingExponent(_ x:Self, _ mc:Rounding) -> Self {
        let mcDouble = Rounding(mc.mode, mc.precision<<1)
        let mc2 = Rounding(mc.mode, mc.precision+4)
        //System.out.println("logUsingExponent(" + x + " " + mathContext + ") precision " + mc);

        let exponent = x.exponent
        let mantissa = x.significand

        var result = logUsingTwoThree(mantissa, mc2)
        if exponent != 0 {
            result = result + BigDecimal(exponent).multiply(logTen(mcDouble), mc2)
        }
        return result
    }

    private static func logUsingTwoThree(_ x:Self, _ mc:Rounding) -> Self  {
        let mcDouble = Rounding(mc.mode, mc.precision<<1)
        let mc2 = Rounding(mc.mode, mc.precision+4);
        //System.out.println("logUsingTwoThree(" + x + " " + mathContext + ") precision " + mc);

        var factorOfTwo = 0
        var powerOfTwo = 1
        var factorOfThree = 0
        var powerOfThree = 1

        var value = x.asDouble()
        switch value {
            case ..<0.01: // never happens when called by logUsingExponent()
                break // nothing to do
            case ..<0.1: // (0.1 - 0.11111 - 0.115) -> (0.9 - 1.0 - 1.035)
                while value < 0.6 {
                    value *= 2; factorOfTwo -= 1; powerOfTwo <<= 1
                }
            case ..<0.115: // (0.1 - 0.11111 - 0.115) -> (0.9 - 1.0 - 1.035)
                factorOfThree = -2; powerOfThree = 9
            case ..<0.14: // (0.115 - 0.125 - 0.14) -> (0.92 - 1.0 - 1.12)
                factorOfTwo = -3; powerOfTwo = 8
            case ..<0.2: // (0.14 - 0.16667 - 0.2) - (0.84 - 1.0 - 1.2)
                factorOfTwo = -1; powerOfTwo = 2
                factorOfThree = -1; powerOfThree = 3
            case ..<0.3: // (0.2 - 0.25 - 0.3) -> (0.8 - 1.0 - 1.2)
                factorOfTwo = -2; powerOfTwo = 4
            case ..<0.42: // (0.3 - 0.33333 - 0.42) -> (0.9 - 1.0 - 1.26)
                factorOfThree = -1; powerOfThree = 3
            case ..<0.7: // (0.42 - 0.5 - 0.7) -> (0.84 - 1.0 - 1.4)
                factorOfTwo = -1; powerOfTwo = 2
            case ..<1.4: // (0.7 - 1.0 - 1.4) -> (0.7 - 1.0 - 1.4)
                break
            case ..<2.5: // (1.4 - 2.0 - 2.5) -> (0.7 - 1.0 - 1.25)
                factorOfTwo = 1; powerOfTwo = 2
            case ..<3.5: // (2.5 - 3.0 - 3.5) -> (0.833333 - 1.0 - 1.166667)
                factorOfThree = 1; powerOfThree = 3
            case ..<5.0: // (3.5 - 4.0 - 5.0) -> (0.875 - 1.0 - 1.25)
                factorOfTwo = 2; powerOfTwo = 4
            case ..<7.0: // (3.5 - 4.0 - 5.0) -> (0.875 - 1.0 - 1.25)
                factorOfThree = 1; powerOfThree = 3
                factorOfTwo = 1; powerOfTwo = 2
            case ..<8.5: // (7.0 - 8.0 - 8.5) -> (0.875 - 1.0 - 1.0625)
                factorOfTwo = 3; powerOfTwo = 8
            case ..<10.0: // (8.5 - 9.0 - 10.0) -> (0.94444 - 1.0 - 1.11111)
                factorOfThree = 2; powerOfThree = 9
            default: // never happens when called by logUsingExponent()
                while value > 1.4 {
                    value /= 2; factorOfTwo += 1; powerOfTwo <<= 1
                }
        }

        var correctedX = x
        var result = zero

        if factorOfTwo > 0 {
            correctedX = correctedX.divide(powerOfTwo, mc2)
            result = result + logTwo(mcDouble).multiply(factorOfTwo, mc2)
        } else if factorOfTwo < 0 {
            correctedX = correctedX.multiply(powerOfTwo, mc2);
            result = result - logTwo(mcDouble).multiply(-factorOfTwo, mc2)
        }

        if factorOfThree > 0 {
            correctedX = correctedX.divide(powerOfThree, mc2);
            result = result + logThree(mcDouble).multiply(factorOfThree, mc2)
        } else if factorOfThree < 0 {
            correctedX = correctedX.multiply(powerOfThree, mc2);
            result = result - logThree(mcDouble).multiply(-factorOfThree, mc2)
        }

        if x == correctedX && result == zero {
            return logUsingNewton(x, mc2)
        }

        result = result.add(logUsingNewton(correctedX, mc2), mc2)

        return result
    }
    
    private static var log2Cache: BigDecimal?
    private static func logTwo(_ mc: Rounding) -> Self {
        if let result = log2Cache, mc.precision <= result.precision {
            return result.round(mc)
        } else {
            log2Cache = logUsingNewton(BigDecimal(2), mc)
            return log2Cache!
        }
    }
    
    private static var log3Cache: BigDecimal?
    private static func logThree(_ mc: Rounding) -> Self {
        if let result = log3Cache, mc.precision <= result.precision {
            return result.round(mc)
        } else {
            log3Cache = logUsingNewton(BigDecimal(3), mc)
            return log3Cache!
        }
    }
    
    private static var log10Cache: BigDecimal?
    private static func logTen(_ mc: Rounding) -> Self {
        if let result = log10Cache, mc.precision <= result.precision {
            return result.round(mc)
        } else {
            log10Cache = logUsingNewton(BigDecimal(10), mc)
            return log10Cache!
        }
    }
}
