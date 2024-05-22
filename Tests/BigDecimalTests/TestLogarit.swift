//
//  TestLogarit.swift
//  
//
//  Created by Nguyen ManhPhi on 22/5/24.
//

import XCTest
import BigDecimal

final class TestLogarit: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogarit() throws {
        let result = BigDecimal.log10(BigDecimal(10.01))
        XCTAssertEqual(result.round(.decimal32).asString(), "10.00043")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
