
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmgriebling%2FBigDecimal%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/mgriebling/BigDecimal)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmgriebling%2FBigDecimal%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/mgriebling/BigDecimal)

# BigDecimal

The BigDecimal package provides arbitrary-precision (with an adjustable upper
limit for performance) and fixed-precision decimal arithmetic in Swift.

Its functionality falls in the following categories:
- Arithmetic: addition, subtraction, multiplication, division, remainder and 
  exponentiation
- Added arbitrary complex decimal number support with the `CBDecimal` type using
  `swift-numerics`.
- Compliant with `DecimalFloatingPoint` and `Real` protocols.
- Constants: `pi`, `zero`, `one`, `ten`
- Functions: exp, log, log10, log2, pow, sqrt, root, factorial, gamma, 
             trig + inverse, hyperbolic + inverse
- Rounding and scaling according to one of the rounding modes:
    - awayFromZero
    - down
    - towardZero
    - toNearestOrEven
    - toNearestOrAwayFromZero
    - up

- Comparison: the six standard operators `==`, `!=`, `<`, `<=`, `>`, and `>=`
- Conversion: to/from String, to/from  Double, to/from  Decimal (the Swift 
  Foundation type), to/from Decimal32 / Decimal64 / Decimal128
- Support for Decimal32, Decimal64 and Decimal128 values stored as UInt32, 
  UInt64 and UInt128 values respectively, using Densely Packed Decimal (DPD) 
  encoding or Binary Integer Decimal (BID) encoding
- Support for Decimal32, Decimal64 and Decimal128 mathematical operations
- Supports the IEEE 754 concepts of Infinity and NaN (Not a Number) with the
  latter having a `signaling` option.

## Dependencies
BigDecimal requires Swift from macOS 13.3+, iOS 16.4+, macCatalyst 13.3+, 
tvOS 16.4+, or watchOS 9.4+. It also requires that the `Int` type be a 64-bit 
type.

The BigDecimal package depends on the BigInt, UInt128, and swift-numerics packages.

```
dependencies: [
  .package(url: "https://github.com/mgriebling/BigInt.git", from: "2.2.0")        
  .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
  .package(url: "https://github.com/mgriebling/UInt128.git", from: "3.1.5")
]
```

## Usage
In your project's Package.swift file add a dependency like

```
dependencies: [
  .package(url: "https://github.com/mgriebling/BigDecimal.git", from: "3.0.2"),
]
```

## Known Issues
Tests for some of the Decimal32 conversions and opeations currently fail.
If you would like to fix the commented-out tests I would encourage you to
do so and feed back your fixes.  I don't think this is a huge deal for
most people who have the Decimal64 and Decimal128 types to use.  Frankly,
I'm only using the BigDecimal arbitrary precision so likely won't address
this as being urgent. The key problems with Decimal32 seem to be in how
it is being rounded after calculations. 

## Documentation
The documentation is built with the DocC plugin and published on GitHub Pages at this location:

https://mgriebling.github.io/BigDecimal/documentation/bigdecimal

The documentation is also available in the *BigDecimal.doccarchive* file.
