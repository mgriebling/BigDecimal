//
//  Decimal128.swift
//  BigDecimal
//
//  Created by Leif Ibsen on 31/08/2021.
//

import BigInt
import UInt128

struct Decimal128 {
    
    static let nan = UInt128(high: 0x7c00000000000000, low: 0x0000000000000000)
    static let plusInf = UInt128(high: 0x7800000000000000, low: 0x0000000000000000)
    static let minusInf = UInt128(high: 0xf800000000000000, low: 0x000000000000000)
    static let maxSignificand = UInt128(high: 0x1ed09bead87c0, low: 0x378d8e63ffffffff)
    
    init(_ value: UInt128, _ encoding: BigDecimal.Encoding = .dpd) {
        let value = value.components
        self.sign = value.high & 0x8000000000000000 != 0
        let x = value.high >> 58 & 0x1f
        if x == 0x1f {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = UInt128(high: 0, low: 0)
        } else if x == 0x1e {
            self.isNan = false
            self.isInfinite = true
            self.exponent = 0
            self.significand = UInt128(high: 0, low: 0)
        } else {
            self.isNan = false
            self.isInfinite = false
            var exp = UInt64(0)
            var sig = UInt128(high: 0, low: 0)
            let bb = (value.high >> 61) & 0x3
            switch encoding {
                case .bid:
                    if bb == 3 {
                        exp = (value.high >> 47) & 0x3fff
                        sig.components.high = 0x2000000000000 | (value.high & 0x7fffffffffff)
                    } else {
                        exp = (value.high >> 49) & 0x3fff
                        sig.components.high = value.high & 0x1ffffffffffff
                    }
                    sig.components.low = value.low
                case .dpd:
                    if bb == 3 {
                        exp = ((value.high >> 46) & 0xfff) | (((value.high >> 59) & 0x3) << 12)
                        sig.components.low = 8 + (value.high >> 58) & 0x1
                    } else {
                        exp = ((value.high >> 46) & 0xfff) | ((value.high >> 61) & 0x3) << 12
                        sig.components.low = (value.high >> 58) & 0x7
                    }
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.high >> 36) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.high >> 26) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.high >> 16) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.high >> 6) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[((value.high & 0x3f) << 4) | ((value.low >> 60) & 0xf)])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.low >> 50) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.low >> 40) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.low >> 30) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.low >> 20) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[(value.low >> 10) & 0x3ff])
                    sig *= 1000
                    sig += UInt128(BigDecimal.decodeDPD[value.low & 0x3ff])
            }
            if sig > Decimal128.maxSignificand {
                sig = UInt128.zero
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
            self.significand = UInt128.zero
        } else if value.isInfinite {
            self.isNan = false
            self.isInfinite = true
            self.exponent = 0
            self.significand = UInt128.zero
        } else if value.abs > BigDecimal.MAX128 {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = UInt128.zero
        } else {
            self.isNan = false
            self.isInfinite = false
            let w = Rounding.decimal128.round(value).abs
            var exp = 6176 + w.exponent
            var sig = UInt128(high: 0, low: w.significand.limbs[0])
            if w.significand.limbs.count > 1 {
                sig.components.high = w.significand.limbs[1]
            }
            while exp > 12287 {
                exp -= 1
                sig *= 10
            }
            while exp < 0 {
                exp += 1
                sig /= 10
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
            let sig = BInt([self.significand.components.low,
                            self.significand.components.high])
            return BigDecimal(self.sign ? -sig : sig, Int(self.exponent) - 6176)
        }
    }
    
    func asUInt128(_ encoding: BigDecimal.Encoding = .dpd) -> UInt128 {
        func divMod(_ c: UInt128) -> (UInt128, UInt64) {
            let x = c.quotientAndRemainder(dividingBy: 1000)
            return (x.quotient, x.remainder.components.low)
        }
        if self.isNan {
            return Decimal128.nan
        } else if self.isInfinite {
            return self.sign ? Decimal128.minusInf : Decimal128.plusInf
        }
        assert(self.exponent <= 0x2fff)
        assert(self.significand <= Decimal128.maxSignificand)
        var value = UInt128(high: self.sign ? UInt64(0x8000000000000000) : UInt64(0x0000000000000000),
                            low: UInt64(0x0000000000000000))
        switch encoding {
            case .bid:
                if self.significand.components.high < 0x2000000000000 {
                    value.components.high |= self.exponent << 49
                } else {
                    value.components.high |= ((0x3 << 14) | self.exponent) << 47
                }
                value.components.low = self.significand.components.low
                value.components.high |= self.significand.components.high
            case.dpd:
                var sig = self.significand
                let d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12:UInt64
                (sig, d1) = divMod(sig)
                (sig, d2) = divMod(sig)
                (sig, d3) = divMod(sig)
                (sig, d4) = divMod(sig)
                (sig, d5) = divMod(sig)
                (sig, d6) = divMod(sig)
                (sig, d7) = divMod(sig)
                (sig, d8) = divMod(sig)
                (sig, d9) = divMod(sig)
                (sig, d10) = divMod(sig)
                (sig, d11) = divMod(sig)
                (sig, d12) = divMod(sig)
                if d12 < 8 {
                    value.components.high |= (self.exponent & 0x3000) << 49
                    value.components.high |= UInt64(d12) << 58
                    value.components.high |= (self.exponent & 0xfff) << 46
                } else {
                    value.components.high |= 0x3 << 61
                    value.components.high |= (self.exponent & 0x3000) << 47
                    value.components.high |= UInt64(d12 & 0x1) << 58
                    value.components.high |= (self.exponent & 0xfff) << 46
                }
                value.components.high |= UInt64(BigDecimal.encodeDPD[d11] << 36)
                value.components.high |= UInt64(BigDecimal.encodeDPD[d10] << 26)
                value.components.high |= UInt64(BigDecimal.encodeDPD[d9] << 16)
                value.components.high |= UInt64(BigDecimal.encodeDPD[d8] << 6)
                value.components.high |= UInt64(BigDecimal.encodeDPD[d7] >> 4)
                value.components.low |= UInt64((BigDecimal.encodeDPD[d7] & 0xf) << 60)
                value.components.low |= UInt64(BigDecimal.encodeDPD[d6] << 50)
                value.components.low |= UInt64(BigDecimal.encodeDPD[d5] << 40)
                value.components.low |= UInt64(BigDecimal.encodeDPD[d4] << 30)
                value.components.low |= UInt64(BigDecimal.encodeDPD[d3] << 20)
                value.components.low |= UInt64(BigDecimal.encodeDPD[d2] << 10)
                value.components.low |= UInt64(BigDecimal.encodeDPD[d1])
        }
        return value
    }
    
}
