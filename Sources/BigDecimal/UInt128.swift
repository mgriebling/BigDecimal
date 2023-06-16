//
//  UInt128.swift
//  BigDecimalTest
//
//  Created by Leif Ibsen on 28/10/2022.
//

import BigInt

/// Helper structure for representing Decimal128 values encoded either as dpd or as bid
public struct UInt128: CustomStringConvertible {
   

    // MARK: - Initializers

    public init(_ hi: UInt64, _ lo: UInt64) {
        self.hi = hi
        self.lo = lo
    }


    // MARK: Stored properties

    /// The high part
    public internal(set) var hi: UInt64
    /// The low part
    public internal(set) var lo: UInt64


    // MARK: Computed properties

    /// String encoding of *self*
    public var description: String {
        return String(self)
    }

    mutating func mul10() {
        var h: UInt64
        (h, self.lo) = self.lo.multipliedFullWidth(by: 10)
        (_, self.hi) = self.hi.multipliedFullWidth(by: 10)
        (self.hi, _) = self.hi.addingReportingOverflow(h)
    }

    mutating func mul1000() {
        var h: UInt64
        (h, self.lo) = self.lo.multipliedFullWidth(by: 1000)
        (_, self.hi) = self.hi.multipliedFullWidth(by: 1000)
        (self.hi, _) = self.hi.addingReportingOverflow(h)
    }

    mutating func add(_ a: UInt64) {
        var ovfl: Bool
        (self.lo, ovfl) = self.lo.addingReportingOverflow(a)
        if ovfl {
            self.hi &+= 1
        }
    }

    // [GRANLUND] - algorithm 4
    // (u1 || u0) / d => (q, r)
    func div128(_ u1: UInt64, _ u0: UInt64, _ d: UInt64, _ dReciprocal: UInt64) -> (q: UInt64, r: UInt64) {
        assert(u1 < d)
        assert(d >= 0x8000000000000000)
        var  ovfl = false
        var (q1, q0) = dReciprocal.multipliedFullWidth(by: u1)
        (q0, ovfl) = q0.addingReportingOverflow(u0)
        (q1, _) = q1.addingReportingOverflow(u1)
        if ovfl {
            q1 &+= 1
        }
        q1 &+= 1
        var r = u0 &- q1 &* d
        if r > q0 {
            q1 &-= 1
            r &+= d
        }
        if r >= d {
            q1 += 1
            r -= d
        }
        return (q1, r)
    }

    // [KNUTH] - chapter 4.3.1, exercise 16
    func divMod(_ v: UInt64) -> (q: UInt128, r: UInt64) {
        let n = v.leadingZeroBitCount
        let d = v << n
        let dRecip = d.dividingFullWidth((0xffffffffffffffff - d, 0xffffffffffffffff)).quotient
        var w0 = self.lo << n
        var w1 = (self.hi << n) | (self.lo >> (64 - n))
        var w2 = self.hi >> (64 - n)
        var r = UInt64(0)
        (w2, r) = div128(r, w2, d, dRecip)
        (w1, r) = div128(r, w1, d, dRecip)
        (w0, r) = div128(r, w0, d, dRecip)
        return (q: UInt128(w1, w0), r: r >> n)
    }

    mutating func div10() {
        (self, _) = self.divMod(10)
    }

    mutating func div1000() -> UInt64 {
        var r: UInt64
        (self, r) = self.divMod(1000)
        return r
    }

    func gt(_ x: UInt128) -> Bool {
        if self.hi > x.hi {
            return true
        } else if self.hi < x.hi {
            return false
        } else if self.lo > x.lo {
            return true
        } else {
            return false
        }
    }

}

public extension String {

    /// Create a String from a UInt128 value
    init(_ x: UInt128, radix: Int = 10) {
        self = BInt([x.lo, x.hi]).asString(radix: radix)
    }
}
