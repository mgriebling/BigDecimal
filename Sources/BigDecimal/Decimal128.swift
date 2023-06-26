//
//  Decimal128.swift
//  BigDecimal
//
//  Created by Leif Ibsen on 31/08/2021.
//

import BigInt

struct Decimal128 {

    static let nan = UInt128(0x7c00000000000000, 0x0000000000000000)
    static let plusInf = UInt128(0x7800000000000000, 0x0000000000000000)
    static let minusInf = UInt128(0xf800000000000000, 0x000000000000000)
    static let maxSignificand = UInt128(0x1ed09bead87c0, 0x378d8e63ffffffff)
    
    init(_ value: UInt128, _ encoding: BigDecimal.Encoding = .dpd) {
        self.sign = value.hi & 0x8000000000000000 != 0
        let x = value.hi >> 58 & 0x1f
        if x == 0x1f {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = UInt128(0, 0)
        } else if x == 0x1e {
            self.isNan = false
            self.isInfinite = true
            self.exponent = 0
            self.significand = UInt128(0, 0)
        } else {
            self.isNan = false
            self.isInfinite = false
            var exp = UInt64(0)
            var sig = UInt128(0, 0)
            let bb = (value.hi >> 61) & 0x3
            switch encoding {
            case .bid:
                if bb == 3 {
                    exp = (value.hi >> 47) & 0x3fff
                    sig.hi = 0x2000000000000 | (value.hi & 0x7fffffffffff)
                } else {
                    exp = (value.hi >> 49) & 0x3fff
                    sig.hi = value.hi & 0x1ffffffffffff
                }
                sig.lo = value.lo
            case .dpd:
                if bb == 3 {
                    exp = ((value.hi >> 46) & 0xfff) | (((value.hi >> 59) & 0x3) << 12)
                    sig.lo = 8 + (value.hi >> 58) & 0x1
                } else {
                    exp = ((value.hi >> 46) & 0xfff) | ((value.hi >> 61) & 0x3) << 12
                    sig.lo = (value.hi >> 58) & 0x7
                }
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.hi >> 36) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.hi >> 26) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.hi >> 16) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.hi >> 6) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[((value.hi & 0x3f) << 4) | ((value.lo >> 60) & 0xf)])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.lo >> 50) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.lo >> 40) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.lo >> 30) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.lo >> 20) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[(value.lo >> 10) & 0x3ff])
                sig.mul1000()
                sig.add(BigDecimal.decodeDPD[value.lo & 0x3ff])
            }
            if sig.gt(Decimal128.maxSignificand) {
                sig = UInt128(0, 0)
            }
            self.exponent = exp
            self.significand = sig
        }
    }

    init(_ value: BigDecimal) {
        self.sign = value.isNegative
        if value.isNaN {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = UInt128(0, 0)
        } else if value.isInfinite {
            self.isNan = false
            self.isInfinite = true
            self.exponent = 0
            self.significand = UInt128(0, 0)
        } else if value.abs > BigDecimal.MAX128 {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = UInt128(0, 0)
        } else {
            self.isNan = false
            self.isInfinite = false
            let w = Rounding.decimal128.round(value).abs
            var exp = 6176 + w.exponent
            var sig = UInt128(0, w.significand.limbs[0])
            if w.significand.limbs.count > 1 {
                sig.hi = w.significand.limbs[1]
            }
            while exp > 12287 {
                exp -= 1
                sig.mul10()
            }
            while exp < 0 {
                exp += 1
                sig.div10()
            }
            self.exponent = UInt64(exp)
            self.significand = sig
        }
    }

    let sign: Bool
    let exponent: UInt64
    let significand: UInt128
    let isNan: Bool
    let isInfinite: Bool

    func asBigDecimal() -> BigDecimal {
        if self.isNan {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            return self.sign ? BigDecimal.infinityN : BigDecimal.infinity
        } else {
            let sig = BInt([self.significand.lo, self.significand.hi])
            return BigDecimal(self.sign ? -sig : sig, Int(self.exponent) - 6176)
        }
    }

    func asUInt128(_ encoding: BigDecimal.Encoding = .dpd) -> UInt128 {
        if self.isNan {
            return Decimal128.nan
        } else if self.isInfinite {
            return self.sign ? Decimal128.minusInf : Decimal128.plusInf
        }
        assert(self.exponent <= 0x2fff)
        assert(!self.significand.gt(Decimal128.maxSignificand))
        var value = UInt128(self.sign ? UInt64(0x8000000000000000) : UInt64(0x0000000000000000), UInt64(0x0000000000000000))
        switch encoding {
        case .bid:
            if self.significand.hi < 0x2000000000000 {
                value.hi |= self.exponent << 49
            } else {
                value.hi |= ((0x3 << 14) | self.exponent) << 47
            }
            value.lo = self.significand.lo
            value.hi |= self.significand.hi
        case.dpd:
            var sig = self.significand
            let d1 = sig.div1000()
            let d2 = sig.div1000()
            let d3 = sig.div1000()
            let d4 = sig.div1000()
            let d5 = sig.div1000()
            let d6 = sig.div1000()
            let d7 = sig.div1000()
            let d8 = sig.div1000()
            let d9 = sig.div1000()
            let d10 = sig.div1000()
            let d11 = sig.div1000()
            let d12 = sig.div1000()
            if d12 < 8 {
                value.hi |= (self.exponent & 0x3000) << 49
                value.hi |= UInt64(d12) << 58
                value.hi |= (self.exponent & 0xfff) << 46
            } else {
                value.hi |= 0x3 << 61
                value.hi |= (self.exponent & 0x3000) << 47
                value.hi |= UInt64(d12 & 0x1) << 58
                value.hi |= (self.exponent & 0xfff) << 46
            }
            value.hi |= BigDecimal.encodeDPD[d11] << 36
            value.hi |= BigDecimal.encodeDPD[d10] << 26
            value.hi |= BigDecimal.encodeDPD[d9] << 16
            value.hi |= BigDecimal.encodeDPD[d8] << 6
            value.hi |= BigDecimal.encodeDPD[d7] >> 4
            value.lo |= (BigDecimal.encodeDPD[d7] & 0xf) << 60
            value.lo |= BigDecimal.encodeDPD[d6] << 50
            value.lo |= BigDecimal.encodeDPD[d5] << 40
            value.lo |= BigDecimal.encodeDPD[d4] << 30
            value.lo |= BigDecimal.encodeDPD[d3] << 20
            value.lo |= BigDecimal.encodeDPD[d2] << 10
            value.lo |= BigDecimal.encodeDPD[d1]
        }
        return value
    }

}
