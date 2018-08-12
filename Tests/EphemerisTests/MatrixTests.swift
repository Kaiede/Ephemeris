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

class MatrixTests: XCTestCase {
    func testSimpleTranslation() {
        let vector = Cartesian3D(x: 15, y: 5, z: 20)
        let matrix = Matrix3D(withTranslationX: 5, y: 10, z: 25)
        
        let result = matrix * vector
        XCTAssertEqual(result.x, 20.0, accuracy: Double.ulpOfOne)
        XCTAssertEqual(result.y, 15.0, accuracy: Double.ulpOfOne)
        XCTAssertEqual(result.z, 45.0, accuracy: Double.ulpOfOne)
    }
    
    func testManyTranslations() {
        let range = -1000.0...1000.0
        for _ in 1...100 {
            // Translate two random vectors using matrix math, check against simple addition.
            // Harder to validate, but should bubble up more subtle issues than a fixed data set.
            let vector1 = Cartesian3D(x: Double.random(in: range), y: Double.random(in: range), z: Double.random(in: range))
            let vector2 = Cartesian3D(x: Double.random(in: range), y: Double.random(in: range), z: Double.random(in: range))
            
            let matrix = Matrix3D(withTranslation: vector2)
            let result = vector1 * matrix
            XCTAssertEqual(result.x, vector1.x + vector2.x, accuracy: Double.ulpOfOne)
            XCTAssertEqual(result.y, vector1.y + vector2.y, accuracy: Double.ulpOfOne)
            XCTAssertEqual(result.z, vector1.z + vector2.z, accuracy: Double.ulpOfOne)
        }
    }
    
    func testRotationX() {
        let testData = [
            // Rotation ... Result Y, Z
            (rad(fromDeg: 0.0), 35.0, 45.0 ),
            (rad(fromDeg: 45.0), 56.568542494923804, 7.071067811865479 ),
            (rad(fromDeg: 135.0), 7.071067811865479, -56.568542494923804 ),
            (rad(fromDeg: 180.0), -35.0, -45.0 ),
            (rad(fromDeg: 300.0), -21.47114317029974, 52.81088913245535 ),
        ]
        
        for data in testData {
            let vector = Cartesian3D(x: 20, y: 35, z: 45)
            let matrix = Matrix3D(withRotationAroundX: data.0)
            
            let targetY = data.1
            let targetZ = data.2
                
            let result = vector * matrix
            
            // Distance and X are invariant
            XCTAssertEqual(result.x, vector.x, accuracy: vector.x.ulp)
            XCTAssertEqual(result.radius(), vector.radius(), accuracy: vector.radius().ulp)
            
            // Y & Z are variant, rotations can be a little inaccurate from Deg/Rad conversion
            XCTAssertEqual(result.y, targetY, accuracy: targetY.ulp * 2.0)
            XCTAssertEqual(result.z, targetZ, accuracy: targetZ.ulp * 2.0)
        }
    }
    
    func testRotationY() {
        let testData = [
            // Rotation ... Result X, Z
            (rad(fromDeg: 0.0), 20.0, 45.0 ),
            (rad(fromDeg: 45.0), -17.677669529663685, 45.96194077712559 ),
            (rad(fromDeg: 135.0), -45.96194077712559, -17.677669529663685 ),
            (rad(fromDeg: 180.0), -20.0, -45.0 ),
            (rad(fromDeg: 300.0), 48.97114317029974, 5.179491924311229 ),
            ]
        
        for data in testData {
            let vector = Cartesian3D(x: 20, y: 35, z: 45)
            let matrix = Matrix3D(withRotationAroundY: data.0)
            
            let targetX = data.1
            let targetZ = data.2
            
            let result = vector * matrix
            
            // Distance and Y are invariant
            XCTAssertEqual(result.y, vector.y, accuracy: vector.y.ulp)
            XCTAssertEqual(result.radius(), vector.radius(), accuracy: vector.radius().ulp)
            
            // X & Z are variant, rotations can be a little inaccurate from Deg/Rad conversion
            XCTAssertEqual(result.x, targetX, accuracy: targetX.ulp * 2.0)
            XCTAssertEqual(result.z, targetZ, accuracy: targetZ.ulp * 2.0)
        }
    }
    
    func testRotationZ() {
        let testData = [
            // Rotation ... Result X, Y
            (rad(fromDeg: 0.0), 20.0, 35.0 ),
            (rad(fromDeg: 45.0), 38.890872965260115, 10.606601717798215 ),
            (rad(fromDeg: 135.0), 10.606601717798215, -38.890872965260115 ),
            (rad(fromDeg: 180.0), -20.0, -35.0 ),
            (rad(fromDeg: 300.0), -20.31088913245535, 34.82050807568877 ),
            ]
        
        for data in testData {
            let vector = Cartesian3D(x: 20, y: 35, z: 45)
            let matrix = Matrix3D(withRotationAroundZ: data.0)
            
            let targetX = data.1
            let targetY = data.2
            
            let result = vector * matrix
            
            // Distance and Z are invariant
            XCTAssertEqual(result.z, vector.z, accuracy: vector.z.ulp)
            XCTAssertEqual(result.radius(), vector.radius(), accuracy: vector.radius().ulp)
            
            // Y & Z are variant, rotations can be a little inaccurate from Deg/Rad conversion
            XCTAssertEqual(result.x, targetX, accuracy: targetX.ulp * 2.0)
            XCTAssertEqual(result.y, targetY, accuracy: targetY.ulp * 2.0)
        }
    }
    
    static var allTests = [
        ("testSimpleTranslation", testSimpleTranslation),
        ("testManyTranslations", testManyTranslations),
        ("testRotationX", testRotationX),
        ("testRotationY", testRotationY),
        ("testRotationZ", testRotationZ)
    ]
}
