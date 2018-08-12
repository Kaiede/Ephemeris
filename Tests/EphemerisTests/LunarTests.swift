/*
 Ephemeris
 
 Copyright (c) 2018 Adam Thayer
 Licensed under the MIT license, as follows:
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.)
 */

import XCTest
@testable import Ephemeris

class LunarTests: XCTestCase {
    func testEquatorialCoord() {
        // TODO: Need Better Test Data. Currently Feeding It Into Itself
        // Algorithm is producing results very similar to expected, but maybe a bit off. Not sure.
        let testDates = [
            // Time, Right Ascension, Declination
            ("2005-01-01 19:00:00.000 UTC", 169.62940682363717, 3.7971391300167823),
            ("2018-08-08 15:00:00.000 UTC", 97.29047832421709, 22.813143713718517),
            ("3001-01-06 17:00:00.000 UTC", 169.5325374070488, 5.052870689946976)
        ]
        
        for (inputString, targetRightAscension, targetDeclination) in testDates {
            guard let date = SolarTests.calendarFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }
            
            let j2000Date = date.toJ2000Date()
            let coordinates = Moon.fastPosition(forDate: j2000Date)
            
            // Currently more accurate than half a degree to NREL
            let targetAccuracy = 0.38
            
            XCTAssertEqual(coordinates.rightAscension, targetRightAscension, accuracy: targetAccuracy)
            XCTAssertEqual(coordinates.declination, targetDeclination, accuracy: targetAccuracy / 2.0)
        }
    }
    
    static var allTests = [
        ("testEquatorialCoord", testEquatorialCoord),
        ]
    
    static let calendarFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS O"
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}
