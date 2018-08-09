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

class JulianCalendarTests: XCTestCase {
    func testJulianFromDate() {
        // Test Data From http://aa.usno.navy.mil/data/docs/JulianDate.php
        let testDates = [
            ("2000-01-01 12:00:00.000 UTC", 2451545.0, 2451545.0), // J2000
            ("2018-08-09 03:51:00.000 UTC", 2458339.0, 2458339.660417),
            ("2020-02-29 16:15:00.000 UTC", 2458909.0, 2458909.177083),
            ("2005-04-15 18:30:00.000 UTC", 2453476.0, 2453476.270833),
            ("2025-12-25 15:45:45.000 UTC", 2461035.0, 2461035.156771),
            ("3001-05-15 17:38:25.000 UTC", 2817287.0, 2817287.235012)
        ]
        
        for (inputString, targetJulianDay, targetJulianDate) in testDates {
            let J2000: JulianDate = 2451545.0
            guard let date = JulianCalendarTests.calendarFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }
            
            // Accuracy should be "perfect" for Julian day, but only to the 6 decimal places we have
            // test data for.
            XCTAssertEqual(date.toJulianDate(), targetJulianDate, accuracy: 0.000001)
            XCTAssertEqual(date.toJulianDay(), targetJulianDay, accuracy: targetJulianDay.ulp)
            XCTAssertEqual(date.toJ2000Date(), targetJulianDate - J2000, accuracy: 0.000001)
        }
    }
    
    func testDateFromJulian() {
        // Test Data From http://aa.usno.navy.mil/data/docs/JulianDate.php
        let testDates = [
            ("2000-01-01 12:00:00.000 UTC", 2451545.0, 2451545.0), // J2000
            ("2018-08-09 03:51:00.000 UTC", 2458339.0, 2458339.660417),
            ("2020-02-29 16:15:00.000 UTC", 2458909.0, 2458909.177083),
            ("2005-04-15 18:30:00.000 UTC", 2453476.0, 2453476.270833),
            ("2025-12-25 15:45:45.000 UTC", 2461035.0, 2461035.156771),
            ("3001-05-15 17:38:25.000 UTC", 2817287.0, 2817287.235012)
        ]
        
        for (targetString, _, inputJulianDate) in testDates {
            let J2000: JulianDate = 2451545.0
            let date = Date(fromJulian: inputJulianDate)
            let date2 = Date(fromJ2000: inputJulianDate - J2000)            
            guard let targetDate = JulianCalendarTests.calendarFormatter.date(from: targetString) else {
                XCTFail()
                continue
            }
            
            // Issue here is that the test data has already been rounded off, losing precision.
            // So make sure our drift isn't any bigger than +/- 1/2 of 0.000001 Julian Day.
            // This is about as good as it will ever get for this data set. 
            let maxDriftSec = 0.0864 / 2.0
        
            XCTAssertEqual(date, date2)
            let drift = abs(date.timeIntervalSince(targetDate))
            XCTAssert(drift < maxDriftSec, "drift of \(drift) for date '\(targetString)' exceeds \(Int(maxDriftSec * 1000)) milliseconds")
        }
    }
    
    static var allTests = [
        ("testJulianFromDate", testJulianFromDate),
        ("testDateFromJulian", testDateFromJulian)
    ]
    
    static let calendarFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS O"
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}

