//
//  TestComplex.swift
//  BigDecimal
//
//  Created by Mike Griebling on 28.08.2024.
//

import XCTest
@testable import BigDecimal

final class TestComplex: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let c = CBDecimal.i
        let a = CBDecimal(BigDecimal(10.5))
        let x = c * a
        let s = x.description
        print(s)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
