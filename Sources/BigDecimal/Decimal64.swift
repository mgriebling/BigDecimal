//
//  Decimal64.swift
//  BigDecimal
//
//  Created by Leif Ibsen on 31/08/2021.
//

import BigInt

struct Decimal64 {

    static let nan = UInt64(0x7c00000000000000)
    static let plusInf = UInt64(0x7800000000000000)
    static let minusInf = UInt64(0xf800000000000000)
    static let maxSignificand = 9999999999999999

    init(_ value: UInt64, _ enc: BigDecimal.Encoding = .dpd) {
        self.sign = value & 0x8000000000000000 != 0
        let x = value >> 58 & 0x1f
        if x == 0x1f {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = 0
        } else if x == 0x1e {
            self.isNan = false
            self.isInfinite = true
            self.exponent = 0
            self.significand = 0
        } else {
            self.isNan = false
            self.isInfinite = false
            var exp = UInt64(0)
            var sig = UInt64(0)
            let bb = (value >> 61) & 0x3
            switch enc {
            case .bid:
                if bb == 3 {
                    exp = (value >> 51) & 0x3ff
                    sig = 0x20000000000000 | (value & 0x7ffffffffffff)
                } else {
                    exp = (value >> 53) & 0x3ff
                    sig = value & 0x1fffffffffffff
                }
            case .dpd:
                if bb == 3 {
                    exp = ((value >> 50) & 0xff) | (((value >> 59) & 0x3) << 8)
                    sig = 8 + (value >> 58) & 0x1
                } else {
                    exp = ((value >> 50) & 0xff) | ((value >> 61) & 0x3) << 8
                    sig = (value >> 58) & 0x7
                }
                sig *= 1000
                sig += BigDecimal.decodeDPD[(value >> 40) & 0x3ff]
                sig *= 1000
                sig += BigDecimal.decodeDPD[(value >> 30) & 0x3ff]
                sig *= 1000
                sig += BigDecimal.decodeDPD[(value >> 20) & 0x3ff]
                sig *= 1000
                sig += BigDecimal.decodeDPD[(value >> 10) & 0x3ff]
                sig *= 1000
                sig += BigDecimal.decodeDPD[value & 0x3ff]
            }
            if sig > Decimal64.maxSignificand {
                sig = 0
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
            self.significand = 0
        } else if value.isInfinite {
            self.isNan = false
            self.isInfinite = true
            self.exponent = 0
            self.significand = 0
        } else if value.abs > BigDecimal.MAX64 {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = 0
        } else {
            self.isNan = false
            self.isInfinite = false
            let w = Rounding.decimal64.round(value).abs
            var exp = 398 + w.exponent
            var sig = UInt64(w.significand.asInt()!)
            while exp > 767 {
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
    let significand: UInt64
    let isNan: Bool
    let isInfinite: Bool
    
    func asBigDecimal() -> BigDecimal {
        if self.isNan {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            return self.sign ? BigDecimal.infinityN : BigDecimal.infinity
        } else {
            return BigDecimal(BInt(self.sign ? -Int(self.significand) : Int(self.significand)), Int(self.exponent) - 398)
        }
    }
    
    func asUInt64(_ encoding: BigDecimal.Encoding = .dpd) -> UInt64 {
        if self.isNan {
            return Decimal64.nan
        } else if self.isInfinite {
            return self.sign ? Decimal64.minusInf : Decimal64.plusInf
        }
        assert(self.exponent <= 0x2ff)
        assert(self.significand <= 0x2386f26fc0ffff)
        var value = self.sign ? UInt64(0x8000000000000000) : UInt64(0x0000000000000000)
        switch encoding {
        case .bid:
            if self.significand < 0x20000000000000 {
                value |= self.exponent << 53
                value |= self.significand
            } else {
                value |= ((0x3 << 10) | self.exponent) << 51
                value |= self.significand & 0x7ffffffffffff
            }
        case .dpd:
            let d1 = self.significand % 1000
            let d2 = (self.significand / 1000) % 1000
            let d3 = (self.significand / 1000000) % 1000
            let d4 = (self.significand / 1000000000) % 1000
            let d5 = (self.significand / 1000000000000) % 1000
            let d6 = self.significand / 1000000000000000
            if d6 < 8 {
                value |= (self.exponent & 0x300) << 53
                value |= d6 << 58
                value |= (self.exponent & 0xff) << 50
            } else {
                value |= 0x3 << 61
                value |= (self.exponent & 0x3ff) << 51
                value |= (d6 & 0x1) << 58
                value |= (self.exponent & 0xff) << 50
            }
            value |= BigDecimal.encodeDPD[d5] << 40
            value |= BigDecimal.encodeDPD[d4] << 30
            value |= BigDecimal.encodeDPD[d3] << 20
            value |= BigDecimal.encodeDPD[d2] << 10
            value |= BigDecimal.encodeDPD[d1]
        }
        return value
    }

}
