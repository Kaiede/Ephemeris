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
            ("2005-01-01 19:00:00.000 UTC", 171.1319730083413, 7.350831282429239),
            ("2018-08-08 15:00:00.000 UTC", 97.29047832421709, 20.68959174083346),
            ("3001-01-06 17:00:00.000 UTC", 168.14127690650466, 1.8185384351205993)
        ]
        
        for (inputString, targetRightAscension, targetDeclination) in testDates {
            guard let date = SolarTests.calendarFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }
            
            let j2000Date = date.toJ2000Date()
            let coordinates = Moon.fastEquatorialPosition(forJ2000: j2000Date)
            
            // Currently more accurate than half a degree to NREL
            let targetAccuracy = 0.38
            
            XCTAssertEqual(coordinates.rightAscension, targetRightAscension, accuracy: targetAccuracy)
            XCTAssertEqual(coordinates.declination, targetDeclination, accuracy: targetAccuracy / 2.0)
        }
    }
    
    func testIllumination() {
        // TODO: Need Better Test Data. Phase angle is only checking for changes in behavior.
        // Illumination data from http://aa.usno.navy.mil/data/docs/MoonFraction.php
        let testDates = [
            // Time, Phase Angle, Illumination Fraction
            ("2005-01-01 00:00:00.000 UTC", 58.57, 0.76),
            ("2018-08-08 00:00:00.000 UTC", 131.91, 0.17),
            ("2015-05-15 00:00:00.000 UTC", 137.28, 0.13),
            ("2015-02-27 00:00:00.000 UTC", 74.72, 0.63),
            // Specifically Look at Waxing
            ("2018-05-22 00:00:00.000 UTC", 91.91,  0.48),
            // Look at the first day of each month, 2018
            ("2018-01-01 00:00:00.000 UTC", 16.18, 0.98),
            ("2018-02-01 00:00:00.000 UTC", 6.10, 1.00),
            ("2018-03-01 00:00:00.000 UTC", 13.95, 0.99),
            ("2018-04-01 00:00:00.000 UTC", 7.50, 1.00),
            ("2018-05-01 00:00:00.000 UTC", 12.32, 0.99),
            ("2018-06-01 00:00:00.000 UTC", 26.82, 0.95),
            ("2018-07-01 00:00:00.000 UTC", 30.30, 0.93),
            ("2018-08-01 00:00:00.000 UTC", 45.68, 0.85),
            ("2018-09-01 00:00:00.000 UTC", 63.64, 0.72),
            ("2018-10-01 00:00:00.000 UTC", 71.74, 0.66),
            ("2018-11-01 00:00:00.000 UTC", 93.84, 0.47),
            ("2018-12-01 00:00:00.000 UTC", 102.57, 0.39),
        ]
        
        for (inputString, targetPhaseAngle, targetIllumination) in testDates {
            guard let date = SolarTests.calendarFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }
            
            print(inputString)
            let j2000Date = date.toJ2000Date()
            let illumination = Moon.fastIllumination(forDate: j2000Date)
            
            // Currently more accurate than half a degree to NREL
            let targetAccuracy = 0.01
            
            XCTAssertEqual(deg(fromRad: illumination.phaseAngle), targetPhaseAngle, accuracy: targetAccuracy)
            XCTAssertEqual(illumination.fraction, targetIllumination, accuracy: targetAccuracy / 2.0)
        }
    }

    func testMoonrise() {
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
            // Time, Moonset, Moonrise
            // Look at the first day of each month, 2018
            ("2018-01-01 00:00:00.000 PT", "07:16 PT", "16:33 PT"),
            ("2018-02-01 00:00:00.000 PT", "08:24 PT", "18:58 PT"),
            ("2018-03-01 00:00:00.000 PT", "06:52 PT", "17:46 PT"),
            ("2018-04-01 00:00:00.000 PT", "07:47 PT", "21:12 PT"),
            ("2018-05-01 00:00:00.000 PT", "07:13 PT", "22:13 PT"),
            ("2018-06-01 00:00:00.000 PT", "07:53 PT", "23:39 PT"),
            ("2018-07-01 00:00:00.000 PT", "08:32 PT", "23:26 PT"),
            ("2018-08-01 00:00:00.000 PT", "10:34 PT", "23:13 PT"),
            ("2018-09-01 00:00:00.000 PT", "12:55 PT", "23:06 PT"),
            ("2018-10-01 00:00:00.000 PT", "14:11 PT", "23:17 PT"),
            ("2018-11-01 00:00:00.000 PT", "15:26 PT", "00:28 PT"),
            ("2018-12-01 00:00:00.000 PT", "14:00 PT", "01:00 PT"),
            ]

        for (inputString, moonsetTime, moonriseTime) in testDates {
            guard let date = inputFormatter.date(from: inputString) else {
                XCTFail(inputString)
                continue
            }

            let j2000Date = date.toJ2000Date()
            let event = Moon.events(forDate: j2000Date, planetRise: .moonrise, location: testLocation)
            switch event {
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
                XCTAssertEqual(setsString, moonsetTime, "\(inputString) -> \(setsComplete)")
                XCTAssertEqual(risesString, moonriseTime, "\(inputString) -> \(risesComplete)")
            }
        }
    }
    
    static var allTests = [
        ("testEquatorialCoord", testEquatorialCoord),
        ("testIllumination", testIllumination),
        ("testMoonrise", testMoonrise)
        ]
    
    static let calendarFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS O"
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}
