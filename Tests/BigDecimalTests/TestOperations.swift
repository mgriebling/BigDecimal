//
//  Test Math Operations
//  
//
//  Created by Mike Griebling on 28.06.2023.
//

import XCTest
@testable import BigDecimal
import BigInt

class TestOperations: XCTestCase {

    func testPi() throws {
        let pi = BigDecimal.pi(Rounding.decimal128)
        XCTAssertEqual(pi.description,"3.141592653589793238462643383279503")
        XCTAssertEqual(Decimal32.pi.description, "3.141593")
    }
    
    func testRoots() throws {
        let sqrt1 = BigDecimal.sqrt(BigDecimal.one, Rounding.decimal128)
        XCTAssertEqual(sqrt1, BigDecimal.one)
        let sqrt2 = BigDecimal.sqrt(2, Rounding.decimal128)
        XCTAssertEqual(sqrt2.description,"1.414213562373095048801688724209698")
        let sqrt10000 = BigDecimal.sqrt(10000, Rounding.decimal128)
        XCTAssertEqual(sqrt10000, BigDecimal(100))
        XCTAssertEqual(Decimal32(2).squareRoot().description, "1.414214")
        
        print("Decimal32 size   = \(MemoryLayout<Decimal32>.size)")
        print("Decimal32 align  = \(MemoryLayout<Decimal32>.alignment)")
        print("Decimal32 stride = \(MemoryLayout<Decimal32>.stride)\n")
        
        print("Decimal64 size   = \(MemoryLayout<Decimal64>.size)")
        print("Decimal64 align  = \(MemoryLayout<Decimal64>.alignment)")
        print("Decimal64 stride = \(MemoryLayout<Decimal64>.stride)\n")
        
        print("Decimal128 size   = \(MemoryLayout<Decimal128>.size)")
        print("Decimal128 align  = \(MemoryLayout<Decimal128>.alignment)")
        print("Decimal128 stride = \(MemoryLayout<Decimal128>.stride)\n")
        
        print("BigDecimal size   = \(MemoryLayout<BigDecimal>.size)")
        print("BigDecimal align  = \(MemoryLayout<BigDecimal>.alignment)")
        print("BigDecimal stride = \(MemoryLayout<BigDecimal>.stride)\n")
        
        print("BigInt size   = \(MemoryLayout<BInt>.size)")
        print("BigInt align  = \(MemoryLayout<BInt>.alignment)")
        print("BigInt stride = \(MemoryLayout<BInt>.stride)")
    }

}
