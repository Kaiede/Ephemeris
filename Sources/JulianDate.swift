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

public typealias JulianDate = Double

let J2000: JulianDate = 2451545.0
let J1970: JulianDate = 2440587.5 // Start of Computer Epoch

public extension Date {
    public func toJulianDay() -> JulianDate {
        return self.toJulianDate().rounded(.down)
    }
    
    public func toJulianDate() -> JulianDate {
        let secondsSince1970 = self.timeIntervalSince1970
        let daysSince1970 = secondsSince1970 / (24.0 * 60.0 * 60.0)
        
        return daysSince1970 + J1970
    }
    
    public func toJ2000Date() -> JulianDate {
        return self.toJulianDate() - J2000
    }
    
    public init(fromJulian julianDate: JulianDate) {
        let daysSince1970 = julianDate - J1970
        let secondsSince1970: TimeInterval = daysSince1970 * (24.0 * 60.0 * 60.0)
        self.init(timeIntervalSince1970: secondsSince1970)
    }
    
    public init(fromJ2000 julianDate: JulianDate) {
        self.init(fromJulian: julianDate + J2000)
    }
}
