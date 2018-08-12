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

typealias Degrees = Double
typealias Radians = Double

func deg(fromRad rad: Radians) -> Degrees {
    return rad * 180.0 / Double.pi
}

func rad(fromDeg deg: Degrees) -> Radians {
    return deg * Double.pi / 180.0
}

struct Polar3D {
    var phi: Radians
    var theta: Radians
    var radius: Double
    
    init(phi: Radians, theta: Radians, radius: Double) {
        self.phi = phi
        self.theta = theta
        self.radius = radius
    }
}

// Altitude/Azimuth Interface
extension Polar3D {
    var azimuth: Degrees {
        get {
            return deg(fromRad: self.phi)
        }
        set {
            self.phi = rad(fromDeg: newValue)
        }
    }
    
    var altitude: Degrees {
        get {
            return deg(fromRad: self.theta)
        }
        set {
            self.theta = rad(fromDeg: newValue)
        }
    }
    
    init(azimuth: Degrees, altitude: Degrees, radius: Double) {
        self.phi = rad(fromDeg: azimuth)
        self.theta = rad(fromDeg: altitude)
        self.radius = radius
    }
}

// From Cartesian
extension Polar3D {
    init(withCartesian coords: Cartesian3D) {
        // rho is Length of projection in x-y plane
        let rhoSquared = coords[0] * coords[0] + coords[1] * coords[1]
        self.radius = sqrt( rhoSquared + coords[2] * coords[2] )
        
        // Azimuth & Altitude
        self.phi = atan2( coords[1] , coords[0] )
        self.theta = atan2( coords[2] , rhoSquared.squareRoot() )
    }
}

struct Cartesian3D {
    fileprivate var vector: [Double] = [ 0, 0, 0 ]
    
    subscript(index: Int) -> Double {
        get {
            return self.vector[index]
        }
        set(newValue) {
            self.vector[index] = newValue
        }
    }
    
    init(x: Double, y: Double, z: Double) {
        self.vector[0] = x
        self.vector[1] = y
        self.vector[2] = z
    }
}

// X/Y/Z Access
extension Cartesian3D {
    var x: Double {
        get {
            return self.vector[0]
        }
        set {
            self.vector[0] = newValue
        }
    }
    
    var y: Double {
        get {
            return self.vector[1]
        }
        set {
            self.vector[1] = newValue
        }
    }
    
    var z: Double {
        get {
            return self.vector[2]
        }
        set {
            self.vector[2] = newValue
        }
    }
}

extension Cartesian3D {
    func radius() -> Double {
        return sqrt( self.vector[0] * self.vector[0] +
                     self.vector[1] * self.vector[1] +
                     self.vector[2] * self.vector[2] )
    }
}
