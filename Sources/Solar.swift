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
        return self - self.rounded(.down)
    }
}

public struct Sun: Body {
    static func meanAnomaly(forCentury century: JulianCentury) -> Radians {
        return FullCircle * (0.993133 + 99.997361 * century).fractional()
    }
    
    static func eclipticLongitude(forCentury century: JulianCentury) -> Radians {
        let M = self.meanAnomaly(forCentury: century)
        let L = 0.7859453 + (M / FullCircle) + ((6893.0 * sin(M) + 72.0 * sin(2.0 * M) + 6191.2 * century) / 1296.0E3)
        return FullCircle * L.fractional()
    }
    
    //
    //
    // A quick calculation for the postion of the Sun relative to Earth. It isn't
    // all that accurate, being maybe accurate to 20-30 arcminutes or so. But it
    // is accurate enough for basic calculations around sun/moon cycles, if not
    // eclipses.
    public static func fastPosition(forCentury century: JulianCentury) -> Cartesian3D {
        let L = self.eclipticLongitude(forCentury: century)
        
        let spherical = Spherical(phi: L, theta: 0.0, radius: 149_598_000.0)
        return Cartesian3D(withSpherical: spherical)
    }
}
