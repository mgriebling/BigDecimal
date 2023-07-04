# BigDecimal: Arbitrary-Precision Decimal Numbers

The BigDecimal package provides arbitrary-precision decimal arithmetic in Swift.

Its functionality falls in the following categories:
- Arithmetic: addition, subtraction, multiplication, division, remainder and exponentiation
- Rounding and scaling according to one of the rounding modes
    - awayFromZero - Round towards +infinity
    - down - Round towards 0
    - towardZero - Round towards -infinity
    - toNearestOrEven - Round to nearest, tie to even
    - toNearestOrAwayFromZero - Round to nearest, ties away from 0
    - up - Round away from 0

- Comparison: the six standard operators == != < <= > >=
- Conversion: to String, to Double, to Decimal (the Swift Foundation type), to Decimal32 / 64 / 128
- Support for Decimal32, Decimal64 and Decimal128 values stored as UInt32, UInt64 and UInt128 values respectively,
using Densely Packed Decimal (DPD) encoding or Binary Integer Decimal (BID) encoding
- Supports the IEEE 754 concepts of Infinity and NaN (Not a Number)

## Dependencies
BigDecimal requires Swift 5. It also requires that the Int type be a 64 bit type.
The BigDecimal package depends on the BigInt and UInt128 packages.

    ```
    dependencies: [
        .package(url: "https://github.com/mgriebling/BigInt.git", from: "2.0.0"),
        .package(url: "https://github.com/mgriebling/UInt128.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")
    ]
    ```

## Usage
In your project's Package.swift file add a dependency like

    ```
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigDecimal", from: "1.1.0"),
    ]
    ```   

## Basics
### Creating BigDecimal's
	  
```swift
	// From an integer
	let x1 = BigDecimal(270) // = 270
	let x2 = BigDecimal(270, -2)  // = 2.70
	let x3 = BigDecimal(314159265, -8) // = 3.14159265
  
	// From a BInt
	let x4 = BigDecimal(BInt(314159265), -8) // = 3.14159265
	let x5 = BigDecimal(BInt(100), -3) // = 0.100
  
	// From a string literal
	let rnd1 = Rounding(.halfEven, 2)
	let x6 = BigDecimal("0.123").round(rnd1) // = 0.12
	let x7 = BigDecimal("3.14159265") // = 3.14159265
  
	// From a double
	let rnd2 = Rounding(.halfEven, 9)
	let x8 = BigDecimal(0.1).round(rnd2)  // = 0.100000000
	let x9 = BigDecimal(0.1) // = 0.1000000000000000055511151231257827021181583404541015625
	let x10 = BigDecimal(3.14159265) // = 3.141592650000000208621031561051495373249053955078125
	let x11 = BigDecimal(3.14159265).round(rnd2) // = 3.14159265

	// From Decimal32 / 64 / 128 encoded values
	let x32 = BigDecimal(UInt32(0x223000f0), .dpd) // = 1.70
	let x64 = BigDecimal(UInt64(0x22300000000000f0), .dpd) // = 1.70
	let x128 = BigDecimal(UInt128(0x2207800000000000, 0x00000000000000f0), .dpd) // = 1.70
```

Because Double values cannot represent all decimal values exactly,
one sees that BigDecimal(0.1) is not exactly equal to 1 / 10 as one might expect.
On the other hand, BigDecimal("0.1") is in fact exactly equal to 1 / 10.

### Converting BigDecimal's
BigDecimal values can be converted to String values, Double values, Decimal (the Swift Foundation type) values, and Decimal32 / 64 / 128 values.

#### To String
	let x1 = BigDecimal("2.1").pow(3)
	print(x1.asString()) // = 9.261

#### To Double
	let x2 = BigDecimal("2.1").pow(3)
	print(x2.asDouble()) // = 9.261

#### To Decimal (the Swift Foundation type)
	let x3 = BigDecimal("1.70")
	let xd: Decimal = x3.asDecimal()
	print(xd) // = 1.70

#### To Decimal32 / 64 / 128
	let x4 = BigDecimal("1.70")
	let x32: UInt32 = x4.asDecimal32(.dpd)
	let x64: UInt64 = x4.asDecimal64(.dpd)
	let x128: UInt128 = x4.asDecimal128(.dpd)
	print(String(x32, radix: 16))  // = 223000f0
	print(String(x64, radix: 16))  // = 22300000000000f0
	print(String(x128, radix: 16)) // = 220780000000000000000000000000f0

### Comparing BigDecimal's

The six standard operators == != < <= > >= are available to compare values. The two operands may either be two
BigDecimal's or a BigDecimal and an integer. If neither of the operands is NaN, the operators perform as expected.
For example is *BigDecimal.infinityN* less than any finite number which in turn is less than *BigDecimal.infinity*.

Please see the section *About NaN's* for the rules governing comparison involving NaN's.

The static function *BigDecimal.maximum(x, y)* returns NaN if either x or y is NaN, else it returns the larger of x and y.

The static function *BigDecimal.minimum(x, y)* returns NaN if either x or y is NaN, else it returns the smaller of x and y.

### Exact Arithmetic

The '+', '-', and '\*' operators always produce exact results. The '/' operator truncates the exact result to an integer.

```swift
	let a = BigDecimal("25.1")
	let b = BigDecimal("12.0041")

	print(a + b) // = 37.1041
	print(a - b) // = 13.0959
	print(a * b) // = 301.30291
	print(a / b) // = 2
```

The *quotientAndRemainder* function produces an integer quotient and exact remainder

```swift
	print(a.quotientAndRemainder(b)) // = (quotient: 2, remainder: 1.0918)
 ```   

### Rounded Arithmetic

Rounding is controlled by Rounding objects that contain a rounding mode and a precision, which is the number of digits in the rounded result.

The rounding modes are:

- ceiling - round towards +infinity
- floor - round towards -infinity
- up - round away from 0
- down - round towards 0
- halfDown - round to nearest, tie towards 0
- halfUp - round to nearest, tie away from 0
- halfEven - round to nearest, tie to even

The *add*, *subtract* and *multiply* methods have a Rounding parameter that controls how the result is rounded.

#### Examples

```swift
	let a = BigDecimal("25.1E-2")
	let b = BigDecimal("12.0041E-3")
	let rnd = Rounding(.ceiling, 3)
	
	print(a + b) // = 0.2630041
	print(a.add(b, rnd)) // = 0.264
	print(a - b) // = 0.2389959
	print(a.subtract(b, rnd)) // = 0.239
	print(a * b) // = 0.0030130291
	print(a.multiply(b, rnd)) // = 0.00302
 ```   

### Precise division

The *divide* method, that has an optional rounding parameter, performs division.
If the quotient has finite decimal expansion, the rounding parameter may or may not be present, it is used if it is there.
If the quotient has infinite decimal expansion, the rounding parameter must be present and is used to round the result.

#### Examples
```swift
	let x1 = BigDecimal(3)
	let x2 = BigDecimal(48)
	print(x1.divide(x2))  // = 0.0625
	let rnd = Rounding(.ceiling, 2)
	print(x1.divide(x2, rnd))  // = 0.063
	
	let x3 = BigDecimal(3)
	let x4 = BigDecimal(49)
	print(x3.divide(x4))       // = NaN because the quotient has infinite decimal expansion 0.06122448...
	print(x3.divide(x4, rnd))  // = 0.062
 ```   

## Data Encoding
BigDecimal's can be encoded as Data objects (perhaps for long term storage) using the *asData* method,
and they can be regenerated from their Data encoding using the appropriate initializer.
The encoding rules are:

	- The encoding contains nine or more bytes. The first eight bytes is a Big Endian encoding of the signed exponent.
		The remaining bytes is a Big Endian encoding of the signed significand.
	- NaN's are encoded as a single byte = 0
	- infinity is encoded as a single byte = 1
	- infinityN is encoded as a single byte = 2

### Examples
```swift
	let x1 = BigDecimal(1000, 3) // = 1000000
	print(Bytes(x1.asData()))   // = [0, 0, 0, 0, 0, 0, 0, 3, 3, 232]

	let x2 = BigDecimal(1000, -3) // = 1.000
	print(Bytes(x2.asData()))   // = [255, 255, 255, 255, 255, 255, 255, 253, 3, 232]

	let x3 = BigDecimal(-1000, 3) // = -1000000
	print(Bytes(x3.asData()))   // = [0, 0, 0, 0, 0, 0, 0, 3, 252, 24]

	let x4 = BigDecimal(-1000, -3) // = -1.000
	print(Bytes(x4.asData()))   // = [255, 255, 255, 255, 255, 255, 255, 253, 252, 24]
 ```   

## Decimal Formats
Decimal values can be represented not only as BigDecimal's but also as Double values,
Decimal (the Swift Foundation type) values, and Decimal32 / 64 / 128 values.
The strategy for working with other than BigDecimal values can be summarized as follows:


- convert the input values to BigDecimal's using the appropriate initializer
- compute the results
- convert the results back to the desired output format using the appropriate conversion function


As an example, suppose you must compute the average value of three values a, b and c which are encoded as Decimal32 values using Densely Packed Decimal (DPD) encoding.
The result x must likewise be a Decimal32 value encoded using DPD.

```swift
	// Input values
	let a = UInt32(0x223e1117)  // = 7042.17 DPD encoded
	let b = UInt32(0x22300901)  // =   22.01 DPD encoded
	let c = UInt32(0xa230cc00)  // = -330.00 DPD encoded
	
	// Convert to BigDecimal's
	let A = BigDecimal(a, .dpd)
	let B = BigDecimal(b, .dpd)
	let C = BigDecimal(c, .dpd)
	
	// Compute result
	let X = (A + B + C).divide(3, Rounding.decimal32)
	print(X)                    // = 2244.727
	
	// Convert result back to Decimal32
	let x = X.asDecimal32(.dpd)
	print(String(x, radix: 16)) // = 2a2513a7 (= 2244.727 DPD encoded)
 ```   
	
## About Infinities
The constants `BigDecimal.infinity* and *BigDecimal.infinity* represent +Infinity and -Infinity respectively. 
infinityN compares less than every finite number,
and every finite number compares less than infinity. Arithmetic operations involving infinite values is illustrated by the examples below:

```swift
	let InfP = BigDecimal.infinity // Just to save some writing
	let InfN = BigDecimal.infinityN
	
	print(InfP + 3)     // +Infinity
	print(InfN + 3)     // -Infinity
	print(InfP + InfP)  // +Infinity
	print(InfP - InfP)  // NaN
	print(InfP * 3)     // +Infinity
	print(InfP * InfP)  // +Infinity
	print(InfP * InfN)  // -Infinity
	print(InfP * 0)     // NaN
	print(InfP / 3)     // +Infinity
	print(InfP / 0)     // +Infinity
	print(1 / InfP)     // 0
	print(1 / InfN)     // 0
	print(InfP / InfP)  // NaN
	print(InfP < InfP)  // false
	print(InfP == InfP) // true
	print(InfP != InfP) // false
	print(InfP > InfP)  // false
	print(Rounding.decimal32.round(InfP))    // +Infinity
	print(InfP.scale(4))    // +Infinity
	print(InfP.scale(-4))   // +Infinity
	print(InfP.withExponent(10, .ceiling))   // NaN
 ```   

## About NaN's
The IEEE 754 standard specifies two NaN's, a quiet NaN (qNaN) and a signaling NaN (sNaN).
The constant *BigDecimal.NaN* corresponds to the quiet NaN. There is no corresponding signaling NaN.

Arithmetic operations where one or more input is NaN, return NaN as result.
Comparing NaN values is illustrated by the example below:
	
 ```swift   
	let NaN = BigDecimal.NaN // Just to save some writing
	
	print(3 < NaN)      // false
	print(NaN < 3)      // false
	print(NaN < NaN)    // false
	print(3 <= NaN)     // false
	print(NaN <= 3)     // false
	print(NaN <= NaN)   // false
	print(3 > NaN)      // false
	print(NaN > 3)      // false
	print(NaN > NaN)    // false
	print(3 >= NaN)     // false
	print(NaN >= 3)     // false
	print(NaN >= NaN)   // false
	print(3 == NaN)     // false
	print(NaN == 3)     // false
	print(NaN == NaN)   // false
	print(3 != NaN)     // true
	print(NaN != 3)     // true
	print(NaN != NaN)   // true !!!
 ```   

Because NaN != NaN is true, sorting a collection of BigDecimal's doesn't work if the collection contains one or more NaN's.
This is so, even if BigDecimal conforms to the Comparable protocol.

There is a static boolean variable *BigDecimal.NaNFlag* which is set to *true* whenever a NaN value is generated.
It can be set to *false* by application code. Therefore, to check if a sequence of code generates NaN,
set NaNFlag to *false* before the code and check it after the code. Since a BigDecimal has a stored property *isNaN*,
it is of course also possible to check for a NaN value at any time.
  
## References

Algorithms from the following books and papers have been used in the implementation.
There are references in the source code where appropriate.


- [GRANLUND] - Moller and Granlund: Improved Division by Invariant Integers, 2011
- [IEEE] - IEEE Standard for Floating-Point Arithmetic, 2019
- [KNUTH] - Donald E. Knuth: Seminumerical Algorithms, Addison-Wesley 1971


## Acknowledgement

Most of the unit test cases come from General Decimal Arithmetic - http://speleotrove.com/decimal
