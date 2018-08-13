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

public typealias Arcseconds = Double
public typealias Degrees = Double
public typealias Radians = Double

let FullCircle: Radians = Double.pi * 2.0

func normalize(radians: Radians) -> Radians {
    var result = radians
    while result < 0.0 {
        result += FullCircle
    }
    return result
}

func deg(fromRad rad: Radians) -> Degrees {
    return rad * 180.0 / Double.pi
}

func rad(fromDeg deg: Degrees) -> Radians {
    return deg * Double.pi / 180.0
}

func rad(fromArcseconds arcs: Arcseconds) -> Radians {
    return rad(fromDeg: arcs / 3600.0)
}

public struct Spherical {
    var phi: Radians
    var theta: Radians
    var radius: Double
    
    init(phi: Radians, theta: Radians, radius: Double) {
        self.phi = phi
        self.theta = theta
        self.radius = radius
    }
}

// Right Ascension / Declination Interface
public extension Spherical {
    var rightAscension: Degrees {
        get {
            return deg(fromRad: normalize(radians: self.phi))
        }
        set {
            self.phi = rad(fromDeg: newValue)
        }
    }
    
    var declination: Degrees {
        get {
            return deg(fromRad: self.theta)
        }
        set {
            self.theta = rad(fromDeg: newValue)
        }
    }
    
    init(rightAscension: Degrees, declination: Degrees, radius: Double) {
        self.phi = rad(fromDeg: rightAscension)
        self.theta = rad(fromDeg: declination)
        self.radius = radius
    }
}

// Altitude/Azimuth Interface
public extension Spherical {
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
public extension Spherical {
    init(withCartesian coords: Cartesian3D) {
        // rho is Length of projection in x-y plane
        let rhoSquared = coords[0] * coords[0] + coords[1] * coords[1]
        self.radius = sqrt( rhoSquared + coords[2] * coords[2] )
        
        // Azimuth & Altitude
        self.phi = atan2( coords[1] , coords[0] )
        self.theta = atan2( coords[2] , rhoSquared.squareRoot() )
    }
}

public struct Cartesian3D {
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

// From Polar
public extension Cartesian3D {
    init(withSpherical coords: Spherical) {
        let radius = coords.radius
        self.vector[0] = radius * (cos(coords.theta) * cos(coords.phi))
        self.vector[1] = radius * (cos(coords.theta) * sin(coords.phi))
        self.vector[2] = radius * (sin(coords.theta))
    }
}

// X/Y/Z Access
public extension Cartesian3D {
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

public extension Cartesian3D {
    func norm() -> Double {
        return sqrt( self.vector[0] * self.vector[0] +
                     self.vector[1] * self.vector[1] +
                     self.vector[2] * self.vector[2] )
    }
    
    func inverted() -> Cartesian3D {
        return Cartesian3D(x: -self.x, y: -self.y, z: -self.z)
    }
}

public func + (_ lhs: Cartesian3D, _ rhs: Cartesian3D) -> Cartesian3D {
    let x = lhs[0] + rhs[0]
    let y = lhs[1] + rhs[1]
    let z = lhs[2] + rhs[2]
    return Cartesian3D(x: x, y: y, z: z)
}

public func - (_ lhs: Cartesian3D, _ rhs: Cartesian3D) -> Cartesian3D {
    let x = lhs[0] - rhs[0]
    let y = lhs[1] - rhs[1]
    let z = lhs[2] - rhs[2]
    return Cartesian3D(x: x, y: y, z: z)
}
