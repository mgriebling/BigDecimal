//
//  BigDecimalMath.swift
//
//  Created by Mike Griebling on 25.06.2023 from an original Java
//  implementation.
//

import BigInt
import Foundation

extension BigDecimal {
    
    typealias BigRational = BigInt.BFraction
    
    static private let expectedInitialPrecision = 15
    static private let oneHalf = BigDecimal(0.5)
    static private let oneHundredEighty = BigDecimal(180)
    static private let doubleMax = BigDecimal(Double.greatestFiniteMagnitude)
    static private let roughly2Pi = BigDecimal(Double.pi * 2)
    
    /// Creates a BigDecimal for the integer _n_ where the
    /// integer can be any type conforming to the _BinaryInteger_ protocols.
    public init<T:BinaryInteger>(_ int: T) {
        var x = Self.zero, m = Self.one
        var n = BInt(int.magnitude), r = BInt.zero
        let base = 1_000_000_000, rd = Self(base), id = BInt(base)
        while n != 0 {
            (n, r) = n.quotientAndRemainder(dividingBy: id)
            if r != 0 { x = x.addingProduct(m, Self(r)) }
            m *= rd
        }
        self = int.signum() < 0 ? -x : x
    }
    
    public func asInt<I:FixedWidthInteger>() -> I? {
        let n = self
        if n.abs < 1 { return nil }  // check for fractions, magnitude >= 0
        if n >= Self(I.max) { return nil }
        if n <= Self(I.min) { return nil }
        
        /// value must be in range of the return integer type
        //incorrect value, example BigDecimal("512").abs().round(Rounding(.towardZero, 0)) return 5E+2
        //let digits = n.abs.round(Rounding(.towardZero, 0)) // truncate any fractions
        let digits = BigDecimal.integralPart(n.abs)
        let coeff = digits.digits
        let power : BInt = BInt(10) ** digits.exponent
        if let int = (coeff * power).asInt() {
            return n.isNegative ? (0-I(int)) : I(int)
        }
        return nil
    }
    
    /**
     * Returns whether the specified ``BigDecimal`` value can be represented as
     * an `Int`.
     *
     * If this returns `true` you can call ``asInt()`` without fear of an exception.
     *
     * - Parameter value: The ``BigDecimal`` to check
     * - Returns: `true` if the value can be represented as `Int` value
     */
    public static func isIntValue(_ value:Self) -> Bool {
        if !fractionalPart(value).isZero { return false }
        if value > BigDecimal(Int.max) {
            return false
        }
        if value < BigDecimal(Int.min) {
            return false
        }
        return true
    }
    
    /**
     * Returns whether the specified ``BigDecimal`` value can be represented
     * as `Double`.
     *
     * If this returns `true` you can call ``asDouble()``
     * without fear of getting ``infinity`` or -``infinity`` as result.
     *
     * Example: `BigDecimal.isDoubleValue(BigDecimal("1E309"))` returns `false`,
     * because `BigDecimal("1E309").asDouble()` returns ``infinity``.
     *
     * Note: This method does **not** check for possible loss of precision.
     *
     * For example `BigDecimalMath.isDoubleValue(BigDecimal("1.23400000000000000000000000000000001"))` will return `true`,
     * because `BigDecimal("1.23400000000000000000000000000000001").asDouble()` returns a valid double value,
     * although it loses precision and returns `1.234`.
     *
     * `BigDecimalMath.isDoubleValue(BigDecimal("1E-325"))` will return `true`
     * although this value is smaller than -`Double.greatestFiniteMagnitude`
     * (and therefore outside the range of values that can be represented as `Double`)
     * because `BigDecimal("1E-325").asDouble()` returns `0` which is a legal
     * value with loss of precision.
     *
     * - Parameter value: ``BigDecimal`` number to check
     * - Returns: `true` if the `value` can be represented as `Double` value
     */
    public static func isDoubleValue(_ value:Self) -> Bool {
        if value > doubleMax {
            return false
        }
        if value < -doubleMax {
            return false
        }
        return true
    }
    
    /**
     * Returns the integral part of the specified ``BigDecimal`` (left of
     * the decimal point). See ``fractionalPart(_:)``.
     *
     * - Parameter value: The ``BigDecimal``
     * - Returns: The integral part
     */
    public static func integralPart(_ value:Self) -> Self {
        return value.withExponent(0, .down)
    }
    
    /**
     * Returns the fractional part of the specified `BigDecimal` (right of
     * the decimal point). See ``integralPart(_:)``.
     *
     * - Parameter value: The ``BigDecimal``
     * - Returns: The fractional part
     */
    public static func fractionalPart(_ value:Self) -> Self {
        return value - integralPart(value)
    }
    
    private static var factorialCache: [BigDecimal] = {
        let initialSize = 100
        var cache = [BigDecimal](); cache.reserveCapacity(initialSize)
        var result = one
        cache.append(result)
        for i in 1..<initialSize {
            result = result * BigDecimal(i)
            cache.append(result)
        }
        return cache
    }()
    
    public static func factorial(_ n: Int) -> BigDecimal {
        precondition(n >= 0, "Illegal factorial(n) for n < 0: n = \(n)")
        
        if n < factorialCache.count { return factorialCache[n] }
        
        // fill up cache with more values
        let result = factorialCache[factorialCache.count - 1]
        return result * factorialRecursion(factorialCache.count, n)
    }
    
    private static func factorialLoop(_ n1: Int, _ n2: Int) -> BigDecimal  {
        let limit = Int.max / n2
        var n1 = n1
        var accu = 1
        var result = BigDecimal.one
        while n1 <= n2 {
            if accu <= limit {
                accu *= n1
            } else {
                result = result * BigDecimal(accu)
                accu = n1
            }
            n1 += 1
        }
        return result * BigDecimal(accu)
    }
    
    private static func factorialRecursion(_ n1: Int, _ n2: Int) -> BigDecimal {
        let threshold = n1 > 200 ? 80 : 150
        if n2 - n1 < threshold {
            return factorialLoop(n1, n2)
        }
        let mid = (n1 + n2) >> 1
        return factorialRecursion(mid + 1, n2) * factorialRecursion(n1, mid)
    }
    
    /**
     * Calculates the factorial of the specified ``BigDecimal``.
     *
     * This implementation uses [Spouge's approximation][spge]
     * to calculate the factorial for non-integer values.
     *
     * This involves calculating a series of constants that depend on the desired precision.
     * Since this constant calculation is quite expensive (especially for higher precisions),
     * the constants for a specific precision will be cached
     * and subsequent calls to this method with the same precision will be much faster.
     *
     * It is therefore recommended to do one call to this method with the
     * standard precision of your application during the startup phase
     * and to avoid calling it with many different precisions.
     *
     * See: [Wikipedia: Factorial][fact] - Extension of factorial to non-integer values of argument
     *
     * [fact]: https://en.wikipedia.org/wiki/Factorial#Extension_of_factorial_to_non-integer_values_of_argument
     * [spge]: https://en.wikipedia.org/wiki/Spouge%27s_approximation
     *
     * - Parameters:
     *    - x: The ``BigDecimal``
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The factorial ``BigDecimal``
     * - Precondition: Requires x is not a negative integer value (-1, -2, -3, ...)
     *
     * See ``factorial(_:)``, ``gamma(_:_:)``
     */
    public static func factorial(_ x: Self, _ mc: Rounding) -> Self  {
        if isIntValue(x) {
            return factorial(x.asInt()!).round(mc)
        }

        let mc2 = Rounding(mc.mode, mc.precision << 1)

        let a = mc.precision * 13 / 10
        let constants = getSpougeFactorialConstants(a)

        let bigA = BigDecimal(a)

        var negative = false
        var factor = constants[0]
        for k in 1..<a {
            let bigK = BigDecimal(k)
            factor = factor + constants[k].divide(x + bigK, mc2)
            negative = !negative
        }

        var result = pow(x + bigA, x + oneHalf, mc2);
        result = result * exp((-x) - bigA, mc2)
        result = result * factor

        return result.round(mc)
    }
    
    private static var spougeFactorialConstantsCache = [Int: [BigDecimal]]()

    public static func getSpougeFactorialConstants(_ a: Int) -> [BigDecimal] {
        if let constants = spougeFactorialConstantsCache[a] {
            return constants
        } else {
            var constants = [BigDecimal](); constants.reserveCapacity(a)
            let mc = Rounding(RoundingRule.toNearestOrEven, a * 15 / 10)
            
            let c0 = sqrt(pi(mc).multiply(2, mc), mc)
            constants.append(c0)
            
            var negative = false
            for k in 1..<a {
                let bigK = BigDecimal(k)
                let deltaAK = a - k
                var ck = pow(BigDecimal(deltaAK), bigK - oneHalf, mc)
                ck = ck.multiply(exp(BigDecimal(deltaAK), mc), mc)
                ck = ck.divide(factorial(k - 1), mc)
                if negative { ck.negate() }
                constants.append(ck)
                negative = !negative
            }
            spougeFactorialConstantsCache[a] = constants
            return constants
        }
    }
    
    /**
     * Calculates the gamma function of the specified ``BigDecimal``.
     *
     * This implementation uses ``factorial(_:_:)`` internally,
     * therefore the performance implications described there apply also
     * for this method.
     *
     * See: [Wikipedia: Gamma function][gamma]
     *
     * [gamma]: https://en.wikipedia.org/wiki/Gamma_function
     *
     * - Parameters:
     *    - x: The ``BigDecimal``
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The gamma ``BigDecimal``
     * - Precondition: Requires x-1 is not a negative integer value
     *                 (-1, -2, -3, ...)
     */
    public static func gamma(_ x: Self, _ mc: Rounding) -> Self {
        factorial(x - one, mc)
    }
    
    /**
     * Calculates the Bernoulli number for the specified index.
     *
     * This function calculates the **first Bernoulli numbers** and therefore
     * `bernoulli(1)` returns -0.5. Note that `bernoulli(x)` for all odd n > 1
     * returns 0.
     *
     * See: [Wikipedia: Bernoulli number][bern]
     *
     * [bern]: https://en.wikipedia.org/wiki/Bernoulli_number
     *
     * - Parameters:
     *    - n: the index of the Bernoulli number to be calculated (starting at 0)
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The Bernoulli number for the specified index
     * - Precondition: Requires n ≥ 0
     */
    public static func bernoulli(_ n:Int, _ mc: Rounding) -> Self {
        precondition(n >= 0, "Illegal bernoulli(n) for n < 0: n = \(n)")
        let b = BigRational.bernoulli(n)
        return BigDecimal(b.numerator).divide(b.denominator, mc)
    }
    
    /**
     * Calculates the square root of ``BigDecimal`` `x`.
     *
     * See Wikipedia: [Square root][lsqrt]
     *
     * [lsqrt]: https://en.wikipedia.org/wiki/Square_root
     *
     * - Parameters:
     *   - x: The ``BigDecimal`` value to calculate the square root
     *   - mc: The ``Rounding`` used for the result
     * - Returns: The calculated square root of `x` with the precision specified
     *            in the `mc`
     */
    public static func sqrt(_ x: Self, _ mc: Rounding) -> Self {
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
     * See Wikipedia: [Nth root][nsqrt].
     *
     * [nsqrt]: https://en.wikipedia.org/wiki/Nth_root
     *
     * - Parameters:
     *   - x: The `BigDecimal` value to calculate the n'th root
     *   - n: The `BigDecimal` defining the root
     *   - mc: The `Rounding` context used for the result
     * - Returns: The calculated n'th root of x with the precision
     *      specified in the mathContext
     *
     */
    public static func root(_ x:Self, _ n:Self, _ mc:Rounding) -> Self {
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
     * Calculates ``BigDecimal`` x to the power of ``BigDecimal`` y (x^y).
     *
     * - Parameters:
     *   - x: The `BigDecimal` value to take to the power
     *   - y: The `BigDecimal` value to serve as exponent
     *   - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated x to the power of y with the precision
     *            specified in the `mc` ``Rounding`` context.
     */
    public static func pow(_ x:Self, _ y:Self, _ mc:Rounding) -> Self {
        if x.isZero {
            if y.isZero { return one }
            return zero
        }

        // TODO optimize y=0, y=1, y=10^k, y=-1, y=-10^k

        // try integral powers of y
        if fractionalPart(y) == 0 {
            if let longValue : Int = y.asInt() {
                return x.pow(longValue, mc)
            } else {
                return powInteger(x, y, mc)
            }
        }

        // x^y = exp(y*log(x))
        let mc2 = Rounding(mc.mode, mc.precision+6)
        let result = exp(y * log(x, mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates ``BigDecimal`` x to the power of the integer value y (xʸ).
     *
     * See ``pow(_:_:_:)``.
     *
     * The value y **MUST** be an integer value.
     *
     * - Parameters:
     *   - x: The ``BigDecimal`` value to take to the power
     *   - integerY: The ``BigDecimal`` **integer** value to serve as exponent
     *   - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated x to the power of y with the precision
     *            specified in the `mc`.
     */
    private static func powInteger(_ x:Self, _ integerY:Self, _ mc:Rounding) -> Self {
        guard !integerY.isNaN else {
            return integerY
        }
        
        guard !x.isNaN else {
            return x
        }
        
        var integerY = integerY
        var x = x
        if integerY != integralPart(integerY) {
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

            if halfY != integralPart(halfY) {
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
     * Returns the number pi (π).
     *
     * See [Wikipedia: Pi][piref].
     *
     * [piref]: https://en.wikipedia.org/wiki/Pi
     *
     * - Parameter mc: The ``Rounding`` context used for the result.
     * - Returns: The number π with the precision specified in the `mc`.
     */
    public static func pi(_ mc: Rounding) -> Self {
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
     * Calculates the natural exponent of ``BigDecimal`` x (eˣ).
     *
     * See: [Wikipedia: Exponential Function][exp].
     *
     * [exp]: https://en.wikipedia.org/wiki/Exponential_function
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the exponent for
     *    - mc: The ``Rounding`` ontextt used for the result
     * - Returns: The calculated exponent ``BigDecimal`` with the precision
     *        specified in the `mc`.
     */
    public static func exp(_ x:Self, _ mc: Rounding) -> Self {
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

        let result = powInteger(t, integralPart, mc2)
        return result.round(mc)
    }
    
    private static func expTaylor(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)

        let x = x.divide(256, mc2)
        var result = ExpCalculator.instance.calculate(x, mc2)
        result = powInteger(result, 256, mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the sine of ``BigDecimal`` x.
     *
     * See [Wikipedia: Sine][sin]
     *
     * [sin]: https://en.wikipedia.org/wiki/Sine_and_cosine
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the sine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated sine ``BigDecimal`` with the precision
     *     specified in the `mc`
     */
    public static func sin(_ x:Self, _ mc:Rounding) -> Self {
        guard !x.isNaN else {
            return x
        }
        
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        var x = x

        if x.abs.compare(roughly2Pi) > 0 {
            let mc3 = Rounding(mc.mode, mc2.precision + 4)
            let twoPi = pi(mc3) * 2
            x = x.quotientAndRemainder(twoPi).remainder
        }

        let result = SinCalculator.instance.calculate(x, mc2);
        return result.round(mc)
    }
    
    /**
     * Calculates the arc sine (inverted sine) of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Arcsine][asine]
     *
     * [asine]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc sine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc sine ``BigDecimal`` with the precision
     *      specified in the `mc`
     * - Precondition: Requires x > 1 or x \< -1
     */
    public static func asin(_ x:Self, _ mc:Rounding) -> Self {
        precondition(x.compare(one) <= 0, "Illegal asin(x) for x > 1: x = \(x)")
        precondition(x.compare(-1) >= 0, "Illegal asin(x) for x < -1: x = \(x)")
        
        if x.signum == -1 {
            return -asin(-x, mc)
        }
        
        let mc2 = Rounding(mc.mode, mc.precision + 6)

        if x.compare(BigDecimal(0.707107)) >= 0 {
            let xTransformed = sqrt(one - x * x, mc2)
            return acos(xTransformed, mc)
        }

        let result = AsinCalculator.instance.calculate(x, mc)
        return result.round(mc)
    }
    
    /**
     * Calculates the cosine of ``BigDecimal`` x.
     *
     * See [Wikipedia: Cosine][cos]
     *
     * [cos]: https://en.wikipedia.org/wiki/Sine_and_cosine
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the cosine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated cosine ``BigDecimal`` with the precision
     *      specified in the `mc`
     */
    public static func cos(_ x:Self, _ mc:Rounding) -> Self {
        guard !x.isNaN else {
            return x
        }
        
        let mc2 = Rounding(mc.mode, mc.precision + 6)
    
        var x = x
        if x.abs.compare(roughly2Pi) > 0 {
            let mc3 = Rounding(mc.mode, mc2.precision + 4)
            let twoPi = pi(mc3) * 2
            x = x.quotientAndRemainder(twoPi).remainder
        }
        
        let result = CosCalculator.instance.calculate(x, mc2)
        return result.round(mc)
    }

    /**
     * Calculates the arccosine (inverted cosine) of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Arccosine][acos]
     *
     * [acos]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc cosine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc sine ``BigDecimal`` with the precision
     *          specified in the `mc`
     * - Precondition: Requires x ≤ 1 or x ≥ -1
     */
    public static func acos(_ x:Self, _ mc:Rounding) -> Self {
        precondition(x.compare(one) <= 0, "Illegal acos(x) for x > 1: x = \(x)")
        precondition(x.compare(-1) >= 0, "Illegal acos(x) for x < -1: x = \(x)")

        let mc2 = Rounding(mc.mode, mc.precision + 6)

        let result = pi(mc2).divide(2, mc2) - asin(x, mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the tangent of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Tangent][tan]
     *
     * [tan]: http://en.wikipedia.org/wiki/Tangent
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the tangens for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated tangens ``BigDecimal`` with the precision
     *      specified in the `mc`
     */
    public static func tan(_ x:Self, _ mc:Rounding) -> Self {
        if x.signum == 0 { return zero }

        let mc2 = Rounding(mc.mode, mc.precision + 4)
        let result = sin(x, mc2).divide(cos(x, mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the arc tangent (inverted tangent) of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Arc tangent][atan]
     *
     * [atan]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc tangens for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc tangens ``BigDecimal`` with the precision
     *      specified in the `mc`
     */
    public static func atan(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)

        var x = x
        x = x.divide(sqrt(one + x.multiply(x, mc2), mc2), mc2)

        let result = asin(x, mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the arc tangent (inverted tangent) of ``BigDecimal`` y / x
     * in the range -π to π.
     *
     * This is useful to calculate the angle *theta* from the conversion of
     * rectangular coordinates (`x`,`y`) to polar coordinates (r, *theta*).
     *
     * See: [Wikipedia: Atan2][atan2]
     *
     * [atan2]: http://en.wikipedia.org/wiki/Atan2
     *
     * - Parameters:
     *    - y: The ``BigDecimal``
     *    - x: The ``BigDecimal``
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc tangens ``BigDecimal`` with the
     *       precision specified in the `mc`
     */
    public static func atan2(_ x:Self, _ y:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 3)

        if x.signum > 0 { // x > 0
            return atan(y.divide(x, mc2), mc)
        } else if x.signum < 0 {
            if y.signum > 0 {  // x < 0 && y > 0
                return atan(y.divide(x, mc2), mc2).add(pi(mc2), mc)
            } else if y.signum < 0 { // x < 0 && y < 0
                return atan(y.divide(x, mc2), mc2).subtract(pi(mc2), mc)
            } else { // x < 0 && y = 0
                return pi(mc)
            }
        } else {
            if y.signum > 0 { // x == 0 && y > 0
                return pi(mc2).divide(2, mc)
            } else if (y.signum < 0) {  // x == 0 && y < 0
                return -pi(mc2).divide(2, mc)
            } else {
                assertionFailure("Illegal atan2(y, x) for x = 0; y = 0")
                return 0
            }
        }
    }
    
    /**
     * Calculates the cotangent of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Cotangent][cot]
     *
     * [cot]: https://en.wikipedia.org/wiki/Trigonometric_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the cotangens for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated cotanges ``BigDecimal`` with the precision specified in the `mc`
     * - Precondition: Requires x ≠ 0
     */
    public static func cot(_ x:Self, _ mc:Rounding) -> Self {
        precondition(x.signum != 0, "Illegal cot(x) for x = 0")

        let mc2 = Rounding(mc.mode, mc.precision + 4)
        let result = cos(x, mc2).divide(sin(x, mc2), mc2)
        return result.round(mc)
    }

    /**
     * Calculates the inverse cotangent (arc cotangent) of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Arccotangent][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc cotangent for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc cotangens ``BigDecimal`` with the
     *          precision specified in the `mc`
     */
    public static func acot(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 4)
        let result = pi(mc2).divide(2, mc2) - atan(x, mc2)
        return result.round(mc)
    }

    /**
     * Calculates the hyperbolic sine of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the hyperbolic sine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated hyperbolic sine ``BigDecimal`` with the
     *      precision specified in the `mc`
     */
    public static func sinh(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 4)
        let result = SinhCalculator.instance.calculate(x, mc2);
        return result.round(mc)
    }

    /**
     * Calculates the hyperbolic cosine of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the hyperbolic cosine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated hyperbolic cosine ``BigDecimal`` with the
     *      precision specified in the `mc`
     */
    public static func cosh(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 4)
        let result = CoshCalculator.instance.calculate(x, mc2)
        return result.round(mc)
    }

    /**
     * Calculates the hyperbolic tangent of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the hyperbolic tangent for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated hyperbolic tangens ``BigDecimal`` with the
     *      precision specified in the `mc`
     */
    public static func tanh(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = sinh(x, mc).divide(cosh(x, mc2), mc2)
        return result.round(mc)
    }

    /**
     * Calculates the hyperbolic cotangent of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the hyperbolic cotangens for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated hyperbolic cotangens ``BigDecimal`` with the
     *       precision specified in the `mc`
     */
    public static func coth(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = cosh(x, mc2).divide(sinh(x, mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the arc hyperbolic sine (inverse hyperbolic sine) of
     * ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc hyperbolic sine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc hyperbolic sine ``BigDecimal`` with the
     *      precision specified in the `mc`
     */
    public static func asinh(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 10)
        let result = log(x + sqrt(x.multiply(x, mc2).add(one, mc2), mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the arc hyperbolic cosine (inverse hyperbolic cosine) of
     * ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc hyperbolic cosine for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc hyperbolic cosine ``BigDecimal`` with
     *      the precision specified in the `mc`
     */
    public static func acosh(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = log(x + sqrt(x * x - one, mc2), mc2)
        return result.round(mc)
    }

    /**
     * Calculates the arc hyperbolic tangent (inverse hyperbolic tangent) of
     * ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc hyperbolic tangens for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc hyperbolic tangens ``BigDecimal`` with
     *      the precision specified in the `mc`
     */
    public static func atanh(_ x:Self, _ mc:Rounding) -> Self {
        precondition(x.compare(one) < 0, "Illegal atanh(x) for x >= 1: x = \(x)")
        precondition(x.compare(-one) > 0, "Illegal atanh(x) for x <= -1: x = \(x)")

        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = log((one + x).divide(one - x, mc2), mc2) * oneHalf
        return result.round(mc)
    }

    /**
     * Calculates the arc hyperbolic cotangent (inverse hyperbolic cotangent)
     * of ``BigDecimal`` x.
     *
     * See: [Wikipedia: Hyperbolic function][hyp]
     *
     * [hyp]: https://en.wikipedia.org/wiki/Hyperbolic_functions
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the arc hyperbolic cotangens for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated arc hyperbolic cotangens ``BigDecimal`` with
     *       the precision specified in the `mc`
     */
    public static func acoth(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = log((x + one).divide(x - one, mc2), mc2) * oneHalf
        return result.round(mc)
    }
    
    /**
     * Converts an angle measured in radians to an approximately equivalent
     * angle measured in degrees. The conversion from radians to degrees is
     * generally inexact, it uses the number π with the precision specified
     * in the `mc` rounding context.
     *
     * - Parameters:
     *    - x: An angle in radians.
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The angle in degrees.
     */
    public static func toDegrees(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = x.multiply(oneHundredEighty.divide(pi(mc2), mc2),  mc2)
        return result.round(mc)
    }

    /**
     * Converts an angle measured in degrees to an approximately equivalent
     * angle measured in radians. The conversion from degrees to radians is
     * generally inexact, it uses the number PI with the precision specified
     * in the `mc` rounding context.
     *
     * - Parameters:
     *    - x: An angle in degrees.
     *    - mc: The ``Rounding`` context used for the result
     * - Returns:  The angle in radians.
     */
    public static func toRadians(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 6)
        let result = x.multiply(pi(mc2).divide(oneHundredEighty, mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the natural logarithm of ``BigDecimal`` `x`.
     *
     * See: [Wikipedia: Natural logarithm][REF].
     *
     * [REF]: http://en.wikipedia.org/wiki/Natural_logarithm
     *
     * - Parameters:
     *    - x: The ``BigDecimal`` to calculate the natural logarithm for
     *    - mc: The ``Rounding`` context used for the result
     * - Returns: The calculated natural logarithm ``BigDecimal`` with the
     *              precision specified in the `mc`.
     */
    public static func log(_ x:Self, _ mc:Rounding) -> Self {
        precondition(x.signum > 0, "Illegal log(x) for x <= 0: x = \(x)")
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
     * Calculates the logarithm of ``BigDecimal`` x to the base 2.
     *
     * - Parameters:
     *   - x: The ``BigDecimal`` to calculate the logarithm base 2 for.
     *   - mc: The ``Rounding`` context used for the result.
     * - Returns: The calculated natural logarithm ``BigDecimal`` to the
     *            base 2 with the precision specified in the `mc`.
     */
    public static func log2(_ x:Self, _ mc:Rounding) -> Self {
        let mc2 = Rounding(mc.mode, mc.precision + 4)

        let  result = log(x, mc2).divide(logTwo(mc2), mc2)
        return result.round(mc)
    }
    
    /**
     * Calculates the logarithm of ``BigDecimal`` x to the base 10.
     *
     * - Parameters:
     *   - x: The ``BigDecimal`` to calculate the logarithm base 10 for.
     *   - mc: The ``Rounding`` context used for the result.
     * - Returns: The calculated natural logarithm ``BigDecimal`` to the
     *          base 10 with the precision specified in the `mc`.
     */
    public static func log10(_ x:Self, _ mc:Rounding) -> Self {
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

        let exponent = x.precision + x.exponent - 1
        let mantissa = x.significand.scale(-x.precision+1)

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

