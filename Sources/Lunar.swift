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

struct Moon {
    static func meanLongitude(forCentury century: JulianCentury) -> Radians {
        return (0.606433 + 1336.855225 * century).fractional()
    }
    
    static func meanAnomaly(forCentury century: JulianCentury) -> Radians {
        return FullCircle * (0.374897 + 1325.552410 * century).fractional()
    }
    
    static func diffLongtiude(forCentury century: JulianCentury) -> Radians {
        return FullCircle * (0.827361 + 1236.853086 * century).fractional()
    }
    
    static func distFromAscendingNode(forCentury century: JulianCentury) -> Radians {
        return FullCircle * (0.259086 + 1342.227825 * century).fractional()
    }
    
    static func fastPosition(forDate date: JulianDate) -> Spherical {
        return self.fastPosition(forCentury: century(fromJ2000: date))
    }
    
    static func fastPosition(forCentury century: JulianCentury) -> Spherical {
        let L_0 = self.meanLongitude(forCentury: century)
        let M = self.meanAnomaly(forCentury: century)
        let MSun = Sun.meanAnomaly(forCentury: century)
        let D = self.diffLongtiude(forCentury: century)
        let F = self.distFromAscendingNode(forCentury: century)
        
        // Calculations of Peturbations
        let dL = 22640 * sin(M)
                 - 4586 * sin(M - 2 * D)
                 + 2370 * sin(2 * D)
                 + 869 * sin(2 * M)
                 - 668 * sin(MSun)
                 - 412 * sin(2 * F)
                 - 212 * sin(2 * M - 2 * D)
                 - 206 * sin(M + MSun - 2 * D)
                 + 192 * sin(M + 2 * D)
                 - 165 * sin(MSun - 2 * D)
                 - 125 * sin(D)
                 - 110 * sin(M + MSun)
                 + 148 * sin(M - MSun)
                 - 55 * sin(2 * F - 2 * D)
        
        //let S = F + (dL + 412 * sin(2 * F) + 541 * sin(MSun)) / Arcs // What is Arcs?
        let S = rad(fromArcseconds: F + (dL + 412 * sin(2 * F) + 541 * sin(MSun)))
        let h = F - 2 * D
        let N = -526 * sin(h)
                + 44 * sin(M + h)
                - 31 * sin(-M + h)
                - 23 * sin(MSun + h)
                + 11 * sin(-MSun + h)
                - 25 * sin(-2 * M + F)
                + 21 * sin(-M + F)
        
        let longMoon = FullCircle * ( L_0 + dL / 1296.0E3 ).fractional()
        //let latMoon = ( 18520.0 * sin(S) + N ) / Arcs // What is Arcs?
        let latMoon = rad(fromArcseconds: 18520.0 * sin(S) + N)
        
        let spherical = Spherical(phi: longMoon, theta: latMoon, radius: 1.0)
        let vector = Cartesian3D(withSpherical: spherical)
        let transformedVector = vector * Matrix3D.transformToEquatorial(forCentury: century)
        return Spherical(withCartesian: transformedVector)
        
    }
}
