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
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "UTC")!
        let components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        let year = components.year!
        let month = components.month!
        let day = components.day!
        // JDN = (1461 × (Y + 4800 + (M − 14)/12))/4 +(367 × (M − 2 − 12 × ((M − 14)/12)))/12 − (3 × ((Y + 4900 + (M - 14)/12)/100))/4 + D − 32075
        
        let julianDay = (1461 * (year + 4800 + (month - 14)/12) ) / 4 +
            (367 * (month - 2 - 12 * ((month - 14) / 12) ) ) / 12 -
            (3 * ((year + 4900 + (month - 14)/12) / 100) ) / 4 +
            day -
        32075
        
        var julianDate = Double(julianDay)
        
        julianDate += (Double(components.hour!) - 12.0) / 24.0
        julianDate += Double(components.minute!) / 1440.0
        julianDate += Double(components.second!) / 86400.0
        
        return julianDate
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
