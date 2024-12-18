//
//  Flashcards_AppTests.swift
//  Flashcards AppTests
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import XCTest
@testable import Flashcards_App

final class Flashcards_AppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // test correct text split
    }
    
    func testCorrectTestSplit() {
        let out = splitText(text: "hey hey", correctText: "hey")
        XCTAssertEqual(out.textPrefix, "hey")
        XCTAssertEqual(out.textMiddle, " hey")
        XCTAssertEqual(out.textSuffix, "")
        XCTAssertEqual(out.correctPrefix, "hey")
        XCTAssertEqual(out.correctMiddle, "")
        XCTAssertEqual(out.correctSuffix, "")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
