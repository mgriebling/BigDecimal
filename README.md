<h2><b>BigDecimal</b></h2>
<h3><b>Contents:</b></h3>
<ul>
<li><a href="#use">Usage</a></li>
<li><a href="#basic">Basics</a>
<ul>
	<li><a href="#basic1">Creating BigDecimal's</a></li>
	<li><a href="#basic2">Converting BigDecimal's</a></li>
	<li><a href="#basic6">Comparing BigDecimal's</a></li>
	<li><a href="#basic3">Exact Arithmetic</a></li>
	<li><a href="#basic5">Rounded Arithmetic</a></li>
	<li><a href="#basic4">Precise division</a></li>
</ul></li>
<li><a href="#data">Data Encoding</a></li>
<li><a href="#fmt">Decimal Formats</a></li>
<li><a href="#inf">About Infinities</a></li>
<li><a href="#nan">About NaN's</a></li>
<li><a href="#ref">References</a></li>
<li><a href="#ack">Acknowledgement</a></li>
</ul>

The BigDecimal package provides arbitrary-precision decimal arithmetic in Swift.
Its functionality falls in the following categories:
<ul>
<li>Arithmetic: addition, subtraction, multiplication, division, remainder and exponentiation</li>
<li>Rounding and scaling according to one of the rounding modes
<ul>
	<li>CEILING</li>
	<li>FLOOR</li>
	<li>UP</li>
	<li>DOWN</li>
	<li>HALF_EVEN</li>
	<li>HALF_DOWN</li>
	<li>HALF_UP
</ul>
<li>Comparison: the six standard operators == != < <= > >=</li>
<li>Conversion: to String, to Double, to Decimal (the Swift Foundation type), to Decimal32 / 64 / 128</li>
</li>
<li>Support for Decimal32, Decimal64 and Decimal128 values stored as UInt32, UInt64 and UInt128 values respectively,
using Densely Packed Decimal (DPD) encoding or Binary Integer Decimal (BID) encoding</li>
<li>Supports the IEEE 754 concepts of Infinity and NaN (Not a Number)</li>
</ul>

BigDecimal requires Swift 5. It also requires that the Int type be a 64 bit type.
The BigDecimal package depends on the BigInt package

	dependencies: [
		.package(url: "https://github.com/leif-ibsen/BigInt", from: "1.11.0"),
	],

<h2 id="use"><b>Usage</b></h2>
In your project's Package.swift file add a dependency like<br/>

	dependencies: [
		.package(url: "https://github.com/leif-ibsen/BigDecimal", from: "1.1.0"),
	]

<h2 id="basic"><b>Basics</b></h2>
<h3 id="basic1"><b>Creating BigDecimal's</b></h3>
	  
	// From an integer
	let x1 = BigDecimal(270) // = 270
	let x2 = BigDecimal(270, -2)  // = 2.70
	let x3 = BigDecimal(314159265, -8) // = 3.14159265
  
	// From a BInt
	let x4 = BigDecimal(BInt(314159265), -8) // = 3.14159265
	let x5 = BigDecimal(BInt(100), -3) // = 0.100
  
	// From a string literal
	let rnd1 = Rounding(.HALF_EVEN, 2)
	let x6 = BigDecimal("0.123").round(rnd1) // = 0.12
	let x7 = BigDecimal("3.14159265") // = 3.14159265
  
	// From a double
	let rnd2 = Rounding(.HALF_EVEN, 9)
	let x8 = BigDecimal(0.1).round(rnd2)  // = 0.100000000
	let x9 = BigDecimal(0.1) // = 0.1000000000000000055511151231257827021181583404541015625
	let x10 = BigDecimal(3.14159265) // = 3.141592650000000208621031561051495373249053955078125
	let x11 = BigDecimal(3.14159265).round(rnd2) // = 3.14159265

	// From Decimal32 / 64 / 128 encoded values
	let x32 = BigDecimal(UInt32(0x223000f0), .DPD) // = 1.70
	let x64 = BigDecimal(UInt64(0x22300000000000f0), .DPD) // = 1.70
	let x128 = BigDecimal(UInt128(0x2207800000000000, 0x00000000000000f0), .DPD) // = 1.70

Because Double values cannot represent all decimal values exactly,
one sees that BigDecimal(0.1) is not exactly equal to 1 / 10 as one might expect.
On the other hand, BigDecimal("0.1") is in fact exactly equal to 1 / 10.
<h3 id="basic2"><b>Converting BigDecimal's</b></h3>
BigDecimal values can be converted to String values, Double values, Decimal (the Swift Foundation type) values, and Decimal32 / 64 / 128 values.
<h4><b>To String</b></h4>
	let x1 = BigDecimal("2.1").pow(3)
	print(x1.asString()) // = 9.261

<h4><b>To Double</b></h4>
	let x2 = BigDecimal("2.1").pow(3)
	print(x2.asDouble()) // = 9.261

<h4><b>To Decimal (the Swift Foundation type)</b></h4>
	let x3 = BigDecimal("1.70")
	let xd: Decimal = x3.asDecimal()
	print(xd) // = 1.70

<h4><b>To Decimal32 / 64 / 128</b></h4>
	let x4 = BigDecimal("1.70")
	let x32: UInt32 = x4.asDecimal32(.DPD)
	let x64: UInt64 = x4.asDecimal64(.DPD)
	let x128: UInt128 = x4.asDecimal128(.DPD)
	print(String(x32, radix: 16))  // = 223000f0
	print(String(x64, radix: 16))  // = 22300000000000f0
	print(String(x128, radix: 16)) // = 220780000000000000000000000000f0

<h3 id="basic6"><b>Comparing BigDecimal's</b></h3>

The six standard operators == != < <= > >= are available to compare values. The two operands may either be two
BigDecimal's or a BigDecimal and an integer. If neither of the operands is NaN, the operators perform as expected.
For example is *BigDecimal.InfinityN* less than any finite number which in turn is less than *BigDecimal.InfinityP*.

Please see the section *About NaN's* for the rules governing comparison involving NaN's.

The static function *BigDecimal.maximum(x, y)* returns NaN if either x or y is NaN, else it returns the larger of x and y.

The static function *BigDecimal.minimum(x, y)* returns NaN if either x or y is NaN, else it returns the smaller of x and y.
<h3 id="basic3"><b>Exact Arithmetic</b></h3>

The '+', '-', and '\*' operators always produce exact results. The '/' operator truncates the exact result to an integer.

	let a = BigDecimal("25.1")
	let b = BigDecimal("12.0041")

	print(a + b) // = 37.1041
	print(a - b) // = 13.0959
	print(a * b) // = 301.30291
	print(a / b) // = 2


The *quotientAndRemainder* function produces an integer quotient and exact remainder

	print(a.quotientAndRemainder(b)) // = (quotient: 2, remainder: 1.0918)

<h3 id="basic5"><b>Rounded Arithmetic</b></h3>

Rounding is controlled by Rounding objects that contain a rounding mode and a precision, which is the number of digits in the rounded result.

The rounding modes are
<ul>
<li>CEILING - round towards +infinity</li>
<li>FLOOR - round towards -infinity</li>
<li>UP - round away from 0</li>
<li>DOWN - round towards 0</li>
<li>HALF_DOWN - round to nearest, tie towards 0</li>
<li>HALF_UP - round to nearest, tie away from 0</li>
<li>HALF_EVEN - round to nearest, tie to even</li>
</ul>
The *add*, *subtract* and *multiply* methods have a Rounding parameter that controls how the result is rounded.
<h4><b>Examples</b></h4>

	let a = BigDecimal("25.1E-2")
	let b = BigDecimal("12.0041E-3")
	let rnd = Rounding(.CEILING, 3)
	
	print(a + b) // = 0.2630041
	print(a.add(b, rnd)) // = 0.264
	print(a - b) // = 0.2389959
	print(a.subtract(b, rnd)) // = 0.239
	print(a * b) // = 0.0030130291
	print(a.multiply(b, rnd)) // = 0.00302

<h3 id="basic4"><b>Precise division</b></h3>

The *divide* method, that has an optional rounding parameter, performs division.
If the quotient has finite decimal expansion, the rounding parameter may or may not be present, it is used if it is there.
If the quotient has infinite decimal expansion, the rounding parameter must be present and is used to round the result.

<h4><b>Examples</b></h4>

	let x1 = BigDecimal(3)
	let x2 = BigDecimal(48)
	print(x1.divide(x2))  // = 0.0625
	let rnd = Rounding(.CEILING, 2)
	print(x1.divide(x2, rnd))  // = 0.063
	
	let x3 = BigDecimal(3)
	let x4 = BigDecimal(49)
	print(x3.divide(x4))       // = NaN because the quotient has infinite decimal expansion 0.06122448...
	print(x3.divide(x4, rnd))  // = 0.062

<h2 id="data"><b>Data Encoding</b></h2>
BigDecimal's can be encoded as Data objects (perhaps for long term storage) using the *asData* method,
and they can be regenerated from their Data encoding using the appropriate initializer.
The encoding rules are:
<ul>
	<li>The encoding contains nine or more bytes. The first eight bytes is a Big Endian encoding of the signed exponent.
		The remaining bytes is a Big Endian encoding of the signed significand.</li>
	<li>NaN's are encoded as a single byte = 0</li>
	<li>InfinityP is encoded as a single byte = 1</li>
	<li>InfinityN is encoded as a single byte = 2</li>
</ul>
<h4><b>Examples</b></h4>
	let x1 = BigDecimal(1000, 3) // = 1000000
	print(Bytes(x1.asData()))   // = [0, 0, 0, 0, 0, 0, 0, 3, 3, 232]

	let x2 = BigDecimal(1000, -3) // = 1.000
	print(Bytes(x2.asData()))   // = [255, 255, 255, 255, 255, 255, 255, 253, 3, 232]

	let x3 = BigDecimal(-1000, 3) // = -1000000
	print(Bytes(x3.asData()))   // = [0, 0, 0, 0, 0, 0, 0, 3, 252, 24]

	let x4 = BigDecimal(-1000, -3) // = -1.000
	print(Bytes(x4.asData()))   // = [255, 255, 255, 255, 255, 255, 255, 253, 252, 24]

<h2 id="fmt"><b>Decimal Formats</b></h2>
Decimal values can be represented not only as BigDecimal's but also as Double values,
Decimal (the Swift Foundation type) values, and Decimal32 / 64 / 128 values.
The strategy for working with other than BigDecimal values can be summarized as follows:

<ul>
<li>convert the input values to BigDecimal's using the appropriate initializer</li>
<li>compute the results</li>
<li>convert the results back to the desired output format using the appropriate conversion function</li>
</ul>

As an example, suppose you must compute the average value of three values a, b and c which are encoded as Decimal32 values using Densely Packed Decimal (DPD) encoding.
The result x must likewise be a Decimal32 value encoded using DPD.

	// Input values
	let a = UInt32(0x223e1117)  // = 7042.17 DPD encoded
	let b = UInt32(0x22300901)  // =   22.01 DPD encoded
	let c = UInt32(0xa230cc00)  // = -330.00 DPD encoded
	
	// Convert to BigDecimal's
	let A = BigDecimal(a, .DPD)
	let B = BigDecimal(b, .DPD)
	let C = BigDecimal(c, .DPD)
	
	// Compute result
	let X = (A + B + C).divide(3, Rounding.decimal32)
	print(X)                    // = 2244.727
	
	// Convert result back to Decimal32
	let x = X.asDecimal32(.DPD)
	print(String(x, radix: 16)) // = 2a2513a7 (= 2244.727 DPD encoded)
	
<h2 id="inf"><b>About Infinities</b></h2>
The two constants *BigDecimal.InfinityP* and *BigDecimal.InfinityN* represent +Infinity and -Infinity respectively. InfinityN compares less than every finite number,
and every finite number compares less than InfinityP. Arithmetic operations involving infinite values is illustrated by the examples below:

	let InfP = BigDecimal.InfinityP // Just to save some writing
	let InfN = BigDecimal.InfinityN
	
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
	print(InfP.withExponent(10, .CEILING))   // NaN


<h2 id="nan"><b>About NaN's</b></h2>
The IEEE 754 standard specifies two NaN's, a quiet NaN (qNaN) and a signaling NaN (sNaN).
The constant *BigDecimal.NaN* corresponds to the quiet NaN. There is no corresponding signaling NaN.

Arithmetic operations where one or more input is NaN, return NaN as result.
Comparing NaN values is illustrated by the example below:
	
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

Because NaN != NaN is true, sorting a collection of BigDecimal's doesn't work if the collection contains one or more NaN's.
This is so, even if BigDecimal conforms to the Comparable protocol.

There is a static boolean variable *BigDecimal.NaNFlag* which is set to *true* whenever a NaN value is generated.
It can be set to *false* by application code. Therefore, to check if a sequence of code generates NaN,
set NaNFlag to *false* before the code and check it after the code. Since a BigDecimal has a stored property *isNaN*,
it is of course also possible to check for a NaN value at any time.
  
<h2 id="ref"><b>References</b></h2>

Algorithms from the following books and papers have been used in the implementation.
There are references in the source code where appropriate.

<ul>
<li>[GRANLUND] - Moller and Granlund: Improved Division by Invariant Integers, 2011</li>
<li>[IEEE] - IEEE Standard for Floating-Point Arithmetic, 2019</li>
<li>[KNUTH] - Donald E. Knuth: Seminumerical Algorithms, Addison-Wesley 1971</li>
</ul>

<h2 id="ack"><b>Acknowledgement</b></h2>

Most of the unit test cases come from General Decimal Arithmetic - http://speleotrove.com/decimal