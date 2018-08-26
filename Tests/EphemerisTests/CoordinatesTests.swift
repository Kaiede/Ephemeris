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

class CoordinateTests: XCTestCase {
    func testPolarConversion() {
        let testData = [
            // X, Y, Z ... Azimuth, Altitude, Radius
            (0.0, 20.0, 20.0, 90.0, 45.0, 28.284271247461902),
            (20.0, 20.0, sqrt( 20 * 20 * 2 ), 45.0, 45.0, 40.0),
            (20.0, -20.0, sqrt( 20 * 20 * 2 ), 315.0, 45.0, 40.0),
            (-20.0, 20.0, sqrt( 20 * 20 * 2 ), 135.0, 45.0, 40.0),
            (-20.0, -20.0, sqrt( 20 * 20 * 2 ), 225.0, 45.0, 40.0)
        ]
        
        for data in testData {
            let vector = Cartesian3D(x: data.0, y: data.1, z: data.2)
            let polar = Spherical(withCartesian: vector)
            
            let targetAzimuth = data.3
            let targetAltitude = data.4
            let targetRadius = data.5
            
            let maxAccuracy = 1E-14
            XCTAssertEqual(polar.azimuth, targetAzimuth, accuracy: maxAccuracy)
            XCTAssertEqual(polar.altitude, targetAltitude, accuracy: maxAccuracy)
            XCTAssertEqual(polar.radius, targetRadius, accuracy: maxAccuracy)
        }
    }
    
    func testCartesianConversion() {
        let testData = [
            // X, Y, Z ... Azimuth, Altitude, Radius
            (0.0, 20.0, 20.0, 90.0, 45.0, 28.284271247461902),
            (20.0, 20.0, sqrt( 20 * 20 * 2 ), 45.0, 45.0, 40.0),
            (20.0, -20.0, sqrt( 20 * 20 * 2 ), -45.0, 45.0, 40.0),
            (-20.0, 20.0, sqrt( 20 * 20 * 2 ), 135.0, 45.0, 40.0),
            (-20.0, -20.0, sqrt( 20 * 20 * 2 ), -135.0, 45.0, 40.0)
        ]
        
        for data in testData {
            let polar = Spherical(azimuth: data.3, altitude: data.4, radius: data.5)
            let vector = Cartesian3D(withSpherical: polar)
            
            let targetX = data.0
            let targetY = data.1
            let targetZ = data.2
            
            let maxAccuracy = 1E-14
            XCTAssertEqual(vector.x, targetX, accuracy: maxAccuracy)
            XCTAssertEqual(vector.y, targetY, accuracy: maxAccuracy)
            XCTAssertEqual(vector.z, targetZ, accuracy: maxAccuracy)
        }
    }
    
    static var allTests = [
        ("testPolarConversion", testPolarConversion),
        ("testCartesianConversion", testCartesianConversion)
    ]
}
