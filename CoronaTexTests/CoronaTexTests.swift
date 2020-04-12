//
//  CoronaTexTests.swift
//  CoronaTexTests
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import XCTest
@testable import CoronaTex

class CoronaTexTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidTimeline() throws {
        let text = "County Name,Population,03-04,03-05\nDallas,2639966,42,7\nDenton,20123,0,1"
        let data = CountyTimelineData.init(text: text)
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.dates, ["03-04-2020", "03-05-2020"])
        XCTAssertEqual(data?.countyPopulation, ["Dallas": 2639966, "Denton": 20123])
        XCTAssertEqual(data?.countyDataPoints, ["Dallas": [42,7], "Denton": [0, 1]])
    }
    
    func testTimelineWrongCountyHeader() throws {
        let text = "County,Population,03-04,03-05\nDallas,2639966,42,7\nDenton,20123,0,1"
        XCTAssertNil(CountyTimelineData.init(text: text))
    }
    
    func testTimelineWrongPopulationHeader() throws {
        let text = "County Name,Pop,03-04,03-05\nDallas,2639966,42,7\nDenton,20123,0,1"
        XCTAssertNil(CountyTimelineData.init(text: text))
    }
    
    func testTimelineWrongDateHeader() throws {
        let text = "County Name,Population,XX-04,03-05\nDallas,2639966,42,7\nDenton,20123,0,1"
        XCTAssertNil(CountyTimelineData.init(text: text))
    }
}
