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

public typealias Seconds = Double
public typealias Hours = Double
public typealias J2000Date = Double
public typealias ModifiedJulianDate = Double
public typealias JulianDate = Double
public typealias JulianCentury = Double
public typealias JulianInterval = Double
public typealias GMST = Double

let MJDEpoch: JulianDate = 2400000.5
let J2000: JulianDate = 2451545.0
let J1970: JulianDate = 2440587.5 // Start of Computer Epoch

let JulianCenturyLength: Double = 36525.0

func century(fromJ2000 date: J2000Date) -> JulianCentury {
    return date / JulianCenturyLength
}

func century(fromJulianDate date: JulianDate) -> JulianCentury {
    return century(fromJ2000: date - J2000)
}

func century(fromModifiedJulianDate date: ModifiedJulianDate) -> JulianCentury {
    return century(fromJulianDate: date + MJDEpoch)
}

func dateJ2000(fromCentury century: JulianCentury) -> J2000Date {
    return century * JulianCenturyLength
}

func julianDay(fromDate date: JulianDate) -> JulianDate {
    return date.rounded(.down)
}

func julianTime(fromHours hours: Hours) -> JulianInterval {
    return hours / 24.0
}

func seconds(duringJulianDate date: JulianDate) -> Seconds {
    let secondsPerDay: Double = 86400.0
    let day = date.rounded(.down)
    return (date - day) * secondsPerDay
}

func seconds(duringJ200Date date: J2000Date) -> Seconds {
    return seconds(duringJulianDate: date)
}

func modifiedJulianDate(fromJulianDate date: JulianDate) -> ModifiedJulianDate {
    return date - MJDEpoch
}

func modifiedJulianDate(fromJ2000 date: J2000Date) ->ModifiedJulianDate {
    return modifiedJulianDate(fromJulianDate: date + J2000)
}

func gmst(fromModifiedJulian date: ModifiedJulianDate) -> GMST {
    let date0 = date.rounded(.down)
    let centuryDate: Double = century(fromModifiedJulianDate: date)
    let centuryDay: Double = century(fromModifiedJulianDate: date0)
    let universalTime: Double = seconds(duringJulianDate: date)
    let gmstTime = 24110.54841
        + (8640184.812866 * centuryDay)
        + (1.0027379093 * universalTime)
        + (0.093104 * centuryDate * centuryDate)
        - (0.0000062 * centuryDate * centuryDate * centuryDate)

    return gmstTime
}

func gmst(fromJ2000 date: J2000Date) -> GMST {
    return gmst(fromModifiedJulian: modifiedJulianDate(fromJ2000: date))
}

public extension Date {
    public func toJulianDay() -> JulianDate {
        return julianDay(fromDate: self.toJulianDate())
    }
    
    public func toJulianDate() -> JulianDate {
        let secondsSince1970 = self.timeIntervalSince1970
        let daysSince1970 = secondsSince1970 / (24.0 * 60.0 * 60.0)
        
        return daysSince1970 + J1970
    }
    
    public func toJ2000Date() -> J2000Date {
        return self.toJulianDate() - J2000
    }

    public func toGmst() -> GMST {
        return gmst(fromModifiedJulian: modifiedJulianDate(fromJulianDate: self.toJulianDate()))
    }
    
    public init(fromJulian julianDate: JulianDate) {
        let daysSince1970 = julianDate - J1970
        let secondsSince1970: TimeInterval = daysSince1970 * (24.0 * 60.0 * 60.0)
        self.init(timeIntervalSince1970: secondsSince1970)
    }
    
    public init(fromJ2000 julianDate: J2000Date) {
        self.init(fromJulian: julianDate + J2000)
    }
}
