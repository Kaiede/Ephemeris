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

import Foundation

struct Matrix3D {
    fileprivate var matrix: [[Double]] =
        [[ 1, 0, 0, 0 ],
         [ 0, 1, 0, 0 ],
         [ 0, 0, 1, 0 ],
         [ 0, 0, 0, 1 ]]
    
    subscript(index: Int) -> [Double] {
        get {
            return self.matrix[index]
        }
        set(newValue) {
            self.matrix[index] = newValue
        }
    }
    
    // Identity
    init() {}
}

// Transposition
extension Matrix3D {
    func transposed() -> Matrix3D {
        var result = Matrix3D()
        
        result.matrix[0][0] = self.matrix[0][0]
        result.matrix[0][1] = self.matrix[1][0]
        result.matrix[0][2] = self.matrix[2][0]
        result.matrix[0][3] = self.matrix[3][0]

        result.matrix[1][0] = self.matrix[0][1]
        result.matrix[1][1] = self.matrix[1][1]
        result.matrix[1][2] = self.matrix[2][1]
        result.matrix[1][3] = self.matrix[3][1]

        result.matrix[2][0] = self.matrix[0][2]
        result.matrix[2][1] = self.matrix[1][2]
        result.matrix[2][2] = self.matrix[2][2]
        result.matrix[2][3] = self.matrix[3][2]

        result.matrix[3][0] = self.matrix[0][3]
        result.matrix[3][1] = self.matrix[1][3]
        result.matrix[3][2] = self.matrix[2][3]
        result.matrix[3][3] = self.matrix[3][3]

        return result
    }
}

// Convenience Initializers
extension Matrix3D {
    init(withData data: [[Double]]) {
        // Yes, this is unrolled. Why not?
        self.matrix[0][0] = data[0][0]
        self.matrix[0][1] = data[0][1]
        self.matrix[0][2] = data[0][2]
        self.matrix[0][3] = data[0][3]

        self.matrix[1][0] = data[1][0]
        self.matrix[1][1] = data[1][1]
        self.matrix[1][2] = data[1][2]
        self.matrix[1][3] = data[1][3]

        self.matrix[2][0] = data[2][0]
        self.matrix[2][1] = data[2][1]
        self.matrix[2][2] = data[2][2]
        self.matrix[2][3] = data[2][3]

        self.matrix[3][0] = data[3][0]
        self.matrix[3][1] = data[3][1]
        self.matrix[3][2] = data[3][2]
        self.matrix[3][3] = data[3][3]
    }
    
    init(withTranslationX x: Double, y: Double, z: Double) {
        self.matrix[0][3] = x
        self.matrix[1][3] = y
        self.matrix[2][3] = z
    }
    
    init(withTranslation translation: Cartesian3D) {
        self.matrix[0][3] = translation.x
        self.matrix[1][3] = translation.y
        self.matrix[2][3] = translation.z
    }
    
    init(withRotationAroundX rotation: Radians) {
        self.matrix[1][1] = cos(rotation)
        self.matrix[1][2] = sin(rotation)

        self.matrix[2][1] = -sin(rotation)
        self.matrix[2][2] = cos(rotation)
    }
    
    init(withRotationAroundY rotation: Radians) {
        self.matrix[0][0] = cos(rotation)
        self.matrix[0][2] = -sin(rotation)

        self.matrix[2][0] = sin(rotation)
        self.matrix[2][2] = cos(rotation)
    }
    
    init(withRotationAroundZ rotation: Radians) {
        self.matrix[0][0] = cos(rotation)
        self.matrix[0][1] = sin(rotation)
        
        self.matrix[1][0] = -sin(rotation)
        self.matrix[1][1] = cos(rotation)
    }
}

// Matrix Mathematics
func * (_ lhs: Matrix3D, _ rhs: Cartesian3D) -> Cartesian3D {
    let x = rhs[0] * lhs[0][0] + rhs[1] * lhs[0][1] + rhs[2] * lhs[0][2] + lhs[0][3]
    let y = rhs[0] * lhs[1][0] + rhs[1] * lhs[1][1] + rhs[2] * lhs[1][2] + lhs[1][3]
    let z = rhs[0] * lhs[2][0] + rhs[1] * lhs[2][1] + rhs[2] * lhs[2][2] + lhs[2][3]
    return Cartesian3D(x: x, y: y, z: z)
}

func * (_ lhs: Cartesian3D, _ rhs: Matrix3D) -> Cartesian3D {
    return rhs * lhs
}
