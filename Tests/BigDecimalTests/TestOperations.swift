//
//  Test Math Operations
//  
//
//  Created by Mike Griebling on 28.06.2023.
//

import XCTest
@testable import BigDecimal

class TestOperations: XCTestCase {

    func testPi() throws {
        let pi = BigDecimal.pi(Rounding.decimal128)
        XCTAssertEqual(pi.description,"3.141592653589793238462643383279503")
    }
    
    func testRoots() throws {
        let sqrt1 = BigDecimal.sqrt(BigDecimal.one, Rounding.decimal128)
        XCTAssertEqual(sqrt1, BigDecimal.one)
        let sqrt2 = BigDecimal.sqrt(2, Rounding.decimal128)
        XCTAssertEqual(sqrt2.description,"1.414213562373095048801688724209698")
        let sqrt10000 = BigDecimal.sqrt(10000, Rounding.decimal128)
        XCTAssertEqual(sqrt10000, BigDecimal(100))
    }

}
