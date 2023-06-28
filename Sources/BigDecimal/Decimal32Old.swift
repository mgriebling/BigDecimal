//
//  Decimal32Old.swift
//  BigDecimal
//
//  Created by Leif Ibsen on 30/08/2021.
//

import BigInt

struct Decimal32Old {
    
    static let nan = UInt32(0x7c000000)
    static let plusInf = UInt32(0x78000000)
    static let minusInf = UInt32(0xf8000000)
    static let maxSignificand = 9999999

    init(_ value: UInt32, _ encoding: BigDecimal.Encoding = .dpd) {
        self.sign = value & 0x80000000 != 0
        let x = value >> 26 & 0x1f
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
            var exp = UInt32(0)
            var sig = UInt32(0)
            let bb = (value >> 29) & 0x3
            switch encoding {
            case .bid:
                if bb == 3 {
                    exp = (value >> 21) & 0xff
                    sig = 0x800000 | (value & 0x1fffff)
                } else {
                    exp = (value >> 23) & 0xff
                    sig = value & 0x7fffff
                }
            case .dpd:
                if bb == 3 {
                    exp = ((value >> 20) & 0x3f) | (((value >> 27) & 0x3) << 6)
                    sig = 8 + (value >> 26) & 0x1
                } else {
                    exp = ((value >> 20) & 0x3f) | ((value >> 29) & 0x3) << 6
                    sig = (value >> 26) & 0x7
                }
                sig *= 1000
                sig += BigDecimal.decodeDPD[(value >> 10) & 0x3ff]
                sig *= 1000
                sig += BigDecimal.decodeDPD[value & 0x3ff]
            }
            if sig > Decimal32Old.maxSignificand {
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
        } else if value.abs > BigDecimal.MAX32 {
            self.isNan = true
            self.isInfinite = false
            self.exponent = 0
            self.significand = 0
        } else {
            self.isNan = false
            self.isInfinite = false
            let w = Rounding.decimal32.round(value).abs
            var exp = 101 + w.exponent
            var sig = UInt32(w.digits.asInt()!)
            while exp > 191 {
                exp -= 1
                sig *= 10
            }
            while exp < 0 {
                exp += 1
                sig /= 10
            }
            self.exponent = UInt32(exp)
            self.significand = sig
        }
    }

    let sign: Bool
    let exponent: UInt32
    let significand: UInt32
    let isNan: Bool
    let isInfinite: Bool


    func asBigDecimal() -> BigDecimal {
        if self.isNan {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            return self.sign ? -BigDecimal.infinity : BigDecimal.infinity
        } else {
            return BigDecimal(BInt(self.sign ? -Int(self.significand)
                        : Int(self.significand)), Int(self.exponent) - 101)
        }
    }

    func asUInt32(_ encoding: BigDecimal.Encoding = .dpd) -> UInt32 {
        if self.isNan {
            return Decimal32Old.nan
        } else if self.isInfinite {
            return self.sign ? Decimal32Old.minusInf : Decimal32Old.plusInf
        }
        assert(self.exponent <= 0xbf)
        assert(self.significand <= 0x98967f)
        var value = self.sign ? UInt32(0x80000000) : UInt32(0x00000000)
        switch encoding {
        case .bid:
            if self.significand < 0x800000 {
                value |= self.exponent << 23
                value |= self.significand
            } else {
                value |= ((0x3 << 8) | self.exponent) << 21
                value |= self.significand & 0x1fffff
            }
        case .dpd:
            let d1 = self.significand % 1000
            let d2 = (self.significand / 1000) % 1000
            let d3 = self.significand / 1000000
            if d3 < 8 {
                value |= (self.exponent & 0xc0) << 23
                value |= d3 << 26
                value |= (self.exponent & 0x3f) << 20
            } else {
                value |= 0x3 << 29
                value |= (self.exponent & 0xc0) << 21
                value |= (d3 & 0x1) << 26
                value |= (self.exponent & 0x3f) << 20
            }
            value |= BigDecimal.encodeDPD[d2] << 10
            value |= BigDecimal.encodeDPD[d1]
        }
        return value
    }

}
