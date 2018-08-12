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

extension Double {
    func fractional() -> Double {
        return self.truncatingRemainder(dividingBy: 1.0)
    }
}

extension Matrix3D {
    static func transformToEcliptic(forCentury century: JulianCentury) -> Matrix3D {
        let eps: Double = ( 23.43929111 - (46.8150 + ( 0.00059 - 0.001813 * century) * century ) * century / 3600.0)
        return Matrix3D(withRotationAroundX: rad(fromDeg: eps))
    }
    
    static func transformToEquatorial(forCentury century: JulianCentury) -> Matrix3D {
        return Matrix3D.transformToEcliptic(forCentury: century).transposed()
    }
}

struct Sun {
    static func meanAnomaly(forCentury century: JulianCentury) -> Radians {
        return FullCircle * (0.993133 + 99.997361 * century).fractional()
    }
    
    static func eclipticLongitude(forCentury century: JulianCentury) -> Radians {
        let M = self.meanAnomaly(forCentury: century)
        let L = 0.7859453 + (M / FullCircle) + ((6893.0 * sin(M) + 72.0 * sin(2.0 * M) + 6191.2 * century) / 1296.0E3)
        return FullCircle * L.fractional()
    }
    
    static func fastPosition(forDate date: JulianDate) -> Spherical {
        return self.fastPosition(forCentury: century(fromJ2000: date))
    }
    
    static func fastPosition(forCentury century: JulianCentury) -> Spherical {
        let L = self.eclipticLongitude(forCentury: century)
        
        let spherical = Spherical(phi: L, theta: 0.0, radius: 1.0)
        let vector = Cartesian3D(withSpherical: spherical)
        let transformedVector = vector * Matrix3D.transformToEquatorial(forCentury: century)
        return Spherical(withCartesian: transformedVector)
    }
}
