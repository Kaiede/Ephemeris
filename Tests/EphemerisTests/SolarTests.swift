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

class SolarTests: XCTestCase {
    func testEquatorialCoord() {
        // Test Data From https://midcdmz.nrel.gov/solpos/spa.html
        let testDates = [
            // Time, Right Ascension, Declination
            ("2005-01-01 19:00:00.000 UTC", 282.795524, -22.919350),
            ("2018-08-08 15:00:00.000 UTC", 138.753862, 15.949098),
            ("3001-01-06 17:00:00.000 UTC", 287.369439, -22.351202)
        ]
        
        for (inputString, targetRightAscension, targetDeclination) in testDates {
            guard let date = SolarTests.calendarFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }
            
            let j2000Date = date.toJ2000Date()
            let coordinates = Sun.fastEquatorialPosition(forJ2000: j2000Date)
            
            // Currently more accurate than half a degree to NREL
            let targetAccuracy = 0.38
                        
            XCTAssertEqual(coordinates.rightAscension, targetRightAscension, accuracy: targetAccuracy)
            XCTAssertEqual(coordinates.declination, targetDeclination, accuracy: targetAccuracy / 2.0)
        }
    }
    
    func testSunrise() {
        // Seattle, WA
        let testLocation = GeographicLocation(longitude: -122.3321, latitude: 47.6062)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm v"
        formatter.timeZone = TimeZone(abbreviation: "PDT")!
        formatter.calendar = Calendar(identifier: .gregorian)

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS v"
        inputFormatter.timeZone = TimeZone(abbreviation: "PDT")!
        inputFormatter.calendar = Calendar(identifier: .gregorian)


        // Data from https://www.timeanddate.com/moon/usa/seattle
        // And from Astronomy on the Personal Computer (Sunset example)
        let testDates: [(String, String, String)] = [
            // Time, Sunrise, Sunset
            // Look at the first day of each month, 2018
            ("2018-01-01 00:00:00.000 PT", "07:57 PT", "16:28 PT"),
            ("2018-02-01 00:00:00.000 PT", "07:35 PT", "17:10 PT"),
            ("2018-03-01 00:00:00.000 PT", "06:49 PT", "17:54 PT"),
            ("2018-04-01 00:00:00.000 PT", "06:47 PT", "19:39 PT"),
            ("2018-05-01 00:00:00.000 PT", "05:52 PT", "20:21 PT"),
            ("2018-06-01 00:00:00.000 PT", "05:15 PT", "20:59 PT"),
            ("2018-07-01 00:00:00.000 PT", "05:15 PT", "21:10 PT"),
            ("2018-08-01 00:00:00.000 PT", "05:47 PT", "20:43 PT"),
            ("2018-09-01 00:00:00.000 PT", "06:27 PT", "19:49 PT"),
            ("2018-10-01 00:00:00.000 PT", "07:08 PT", "18:48 PT"),
            ("2018-11-01 00:00:00.000 PT", "07:53 PT", "17:51 PT"),
            ("2018-12-01 00:00:00.000 PT", "07:37 PT", "16:19 PT"),
            ]

        for (inputString, sunriseTime, sunsetTime) in testDates {
            guard let date = inputFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }

            let j2000Date = date.toJ2000Date()
            let sunriseEvent = Sun.events(forDate: j2000Date, planetRise: .sunrise, location: testLocation)
            switch sunriseEvent {
            case .neverSets:
                XCTFail("No Data Never Sets: \(inputString)")
            case .neverRises:
                XCTFail("No Data Never Rises: \(inputString)")
            case .Rises( _):
                XCTFail("No Data Only Rises: \(inputString)")
            case .Sets( _):
                XCTFail("No Data Only Sets: \(inputString)")
            case .RisesAndSets(let rises, let sets):
                let setsString = formatter.string(from: Date(fromJ2000: sets))
                let setsComplete = inputFormatter.string(from: Date(fromJ2000: sets))
                let risesString = formatter.string(from: Date(fromJ2000: rises))
                let risesComplete = inputFormatter.string(from: Date(fromJ2000: rises))
                XCTAssertEqual(risesString, sunriseTime, "\(inputString) -> \(risesComplete)")
                XCTAssertEqual(setsString, sunsetTime, "\(inputString) -> \(setsComplete)")
            }
        }
    }

    func testCivilTwilight() {
        // Seattle, WA
        let testLocation = GeographicLocation(longitude: -122.3321, latitude: 47.6062)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm v"
        formatter.timeZone = TimeZone(abbreviation: "PDT")!
        formatter.calendar = Calendar(identifier: .gregorian)

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS v"
        inputFormatter.timeZone = TimeZone(abbreviation: "PDT")!
        inputFormatter.calendar = Calendar(identifier: .gregorian)

        // Data from https://www.timeanddate.com/moon/usa/seattle
        // And from Astronomy on the Personal Computer (Sunset example)
        let testDates: [(String, String, String)] = [
            // Time, Sunrise, Sunset
            // Look at the first day of each month, 2018
            ("2018-01-01 00:00:00.000 PT", "07:22 PT", "17:04 PT"),
            ("2018-02-01 00:00:00.000 PT", "07:02 PT", "17:44 PT"),
            ("2018-03-01 00:00:00.000 PT", "06:18 PT", "18:25 PT"),
            ("2018-04-01 00:00:00.000 PT", "06:16 PT", "20:10 PT"),
            ("2018-05-01 00:00:00.000 PT", "05:17 PT", "20:56 PT"),
            ("2018-06-01 00:00:00.000 PT", "04:36 PT", "21:39 PT"),
            ("2018-07-01 00:00:00.000 PT", "04:35 PT", "21:51 PT"),
            ("2018-08-01 00:00:00.000 PT", "05:11 PT", "21:19 PT"),
            ("2018-09-01 00:00:00.000 PT", "05:56 PT", "20:21 PT"),
            ("2018-10-01 00:00:00.000 PT", "06:37 PT", "19:19 PT"),
            ("2018-11-01 00:00:00.000 PT", "07:21 PT", "18:23 PT"),
            ("2018-12-01 00:00:00.000 PT", "07:01 PT", "16:55 PT"),
            ]

        for (inputString, sunriseTime, sunsetTime) in testDates {
            guard let date = inputFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }

            let j2000Date = date.toJ2000Date()
            let sunriseEvent = Sun.events(forDate: j2000Date, planetRise: .civilTwilight, location: testLocation)
            switch sunriseEvent {
            case .neverSets:
                XCTFail("No Data Never Sets: \(inputString)")
            case .neverRises:
                XCTFail("No Data Never Rises: \(inputString)")
            case .Rises( _):
                XCTFail("No Data Only Rises: \(inputString)")
            case .Sets( _):
                XCTFail("No Data Only Sets: \(inputString)")
            case .RisesAndSets(let rises, let sets):
                let setsString = formatter.string(from: Date(fromJ2000: sets))
                let setsComplete = inputFormatter.string(from: Date(fromJ2000: sets))
                let risesString = formatter.string(from: Date(fromJ2000: rises))
                let risesComplete = inputFormatter.string(from: Date(fromJ2000: rises))
                XCTAssertEqual(risesString, sunriseTime, "\(inputString) -> \(risesComplete)")
                XCTAssertEqual(setsString, sunsetTime, "\(inputString) -> \(setsComplete)")
            }
        }
    }

    func testNauticalTwilight() {
        // Seattle, WA
        let testLocation = GeographicLocation(longitude: -122.3321, latitude: 47.6062)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm v"
        formatter.timeZone = TimeZone(abbreviation: "PDT")!
        formatter.calendar = Calendar(identifier: .gregorian)

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS v"
        inputFormatter.timeZone = TimeZone(abbreviation: "PDT")!
        inputFormatter.calendar = Calendar(identifier: .gregorian)

        // Data from https://www.timeanddate.com/moon/usa/seattle
        // And from Astronomy on the Personal Computer (Sunset example)
        let testDates: [(String, String, String)] = [
            // Time, Sunrise, Sunset
            // Look at the first day of each month, 2018
            ("2018-01-01 00:00:00.000 PT", "06:42 PT", "17:43 PT"),
            ("2018-02-01 00:00:00.000 PT", "06:25 PT", "18:20 PT"),
            ("2018-03-01 00:00:00.000 PT", "05:43 PT", "19:01 PT"),
            ("2018-04-01 00:00:00.000 PT", "05:39 PT", "20:48 PT"),
            ("2018-05-01 00:00:00.000 PT", "04:34 PT", "21:40 PT"),
            ("2018-06-01 00:00:00.000 PT", "03:43 PT", "22:32 PT"),
            ("2018-07-01 00:00:00.000 PT", "03:40 PT", "22:46 PT"),
            ("2018-08-01 00:00:00.000 PT", "04:24 PT", "22:05 PT"),
            ("2018-09-01 00:00:00.000 PT", "05:17 PT", "20:59 PT"),
            ("2018-10-01 00:00:00.000 PT", "06:02 PT", "19:54 PT"),
            ("2018-11-01 00:00:00.000 PT", "06:44 PT", "19:00 PT"),
            ("2018-12-01 00:00:00.000 PT", "06:22 PT", "17:33 PT"),
            ]

        for (inputString, sunriseTime, sunsetTime) in testDates {
            guard let date = inputFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }

            let j2000Date = date.toJ2000Date()
            let sunriseEvent = Sun.events(forDate: j2000Date, planetRise: .nauticalTwilight, location: testLocation)
            switch sunriseEvent {
            case .neverSets:
                XCTFail("No Data Never Sets: \(inputString)")
            case .neverRises:
                XCTFail("No Data Never Rises: \(inputString)")
            case .Rises( _):
                XCTFail("No Data Only Rises: \(inputString)")
            case .Sets( _):
                XCTFail("No Data Only Sets: \(inputString)")
            case .RisesAndSets(let rises, let sets):
                let setsString = formatter.string(from: Date(fromJ2000: sets))
                let setsComplete = inputFormatter.string(from: Date(fromJ2000: sets))
                let risesString = formatter.string(from: Date(fromJ2000: rises))
                let risesComplete = inputFormatter.string(from: Date(fromJ2000: rises))
                XCTAssertEqual(risesString, sunriseTime, "\(inputString) -> \(risesComplete)")
                XCTAssertEqual(setsString, sunsetTime, "\(inputString) -> \(setsComplete)")
            }
        }
    }

    func testAstroTwilight() {
        // Seattle, WA
        let testLocation = GeographicLocation(longitude: -122.3321, latitude: 47.6062)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm v"
        formatter.timeZone = TimeZone(abbreviation: "PDT")!
        formatter.calendar = Calendar(identifier: .gregorian)

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS v"
        inputFormatter.timeZone = TimeZone(abbreviation: "PDT")!
        inputFormatter.calendar = Calendar(identifier: .gregorian)

        // Data from https://www.timeanddate.com/moon/usa/seattle
        // And from Astronomy on the Personal Computer (Sunset example)
        let testDates: [(String, String, String)] = [
            // Time, Sunrise, Sunset
            // Look at the first day of each month, 2018
            ("2018-01-01 00:00:00.000 PT", "06:05 PT", "18:20 PT"),
            ("2018-02-01 00:00:00.000 PT", "05:49 PT", "18:56 PT"),
            ("2018-03-01 00:00:00.000 PT", "05:07 PT", "19:37 PT"),
            ("2018-04-01 00:00:00.000 PT", "05:00 PT", "21:27 PT"),
            ("2018-05-01 00:00:00.000 PT", "03:44 PT", "22:29 PT"),
            ("2018-06-01 00:00:00.000 PT", "02:27 PT", "23:48 PT"),
            ("2018-07-01 00:00:00.000 PT", "02:13 PT", "00:12 PT"),
            ("2018-08-01 00:00:00.000 PT", "03:28 PT", "23:00 PT"),
            ("2018-09-01 00:00:00.000 PT", "04:35 PT", "21:41 PT"),
            ("2018-10-01 00:00:00.000 PT", "05:25 PT", "20:30 PT"),
            ("2018-11-01 00:00:00.000 PT", "06:09 PT", "19:36 PT"),
            ("2018-12-01 00:00:00.000 PT", "05:46 PT", "18:10 PT"),
            ]

        for (inputString, sunriseTime, sunsetTime) in testDates {
            guard let date = inputFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }

            let j2000Date = date.toJ2000Date()
            let sunriseEvent = Sun.events(forDate: j2000Date, planetRise: .astronomicalTwilight, location: testLocation)
            switch sunriseEvent {
            case .neverSets:
                XCTFail("No Data Never Sets: \(inputString)")
            case .neverRises:
                XCTFail("No Data Never Rises: \(inputString)")
            case .Rises( _):
                XCTFail("No Data Only Rises: \(inputString)")
            case .Sets( _):
                XCTFail("No Data Only Sets: \(inputString)")
            case .RisesAndSets(let rises, let sets):
                let setsString = formatter.string(from: Date(fromJ2000: sets))
                let setsComplete = inputFormatter.string(from: Date(fromJ2000: sets))
                let risesString = formatter.string(from: Date(fromJ2000: rises))
                let risesComplete = inputFormatter.string(from: Date(fromJ2000: rises))
                XCTAssertEqual(risesString, sunriseTime, "\(inputString) -> \(risesComplete)")
                XCTAssertEqual(setsString, sunsetTime, "\(inputString) -> \(setsComplete)")
            }
        }
    }
    
    static var allTests = [
        ("testEquatorialCoord", testEquatorialCoord),
        ("testSunrise", testSunrise),
        ("testCivilTwilight", testCivilTwilight),
        ("testNauticalTwilight", testNauticalTwilight),
        ("testAstroTwilight", testAstroTwilight)
        ]
    
    static let calendarFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS O"
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}
