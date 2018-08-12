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
    
    static var allTests = [
        ("testSimpleTranslation", testSimpleTranslation),
        ("testManyTranslations", testManyTranslations)
    ]
}
