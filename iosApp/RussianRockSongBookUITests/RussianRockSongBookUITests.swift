//
//  RussianRockSongBookUITests.swift
//  RussianRockSongBookUITests
//
//  Created by User on 04.05.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import XCTest

final class RussianRockSongBookUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        while(!app.staticTexts["Кино"].exists) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts["Кино"].exists)
        while(!app.staticTexts["Алюминиевые огурцы"].exists) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts["Алюминиевые огурцы"].exists)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
