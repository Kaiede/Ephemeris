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

//
// MARK: Body Protocol
//
public protocol Body {
    static func fastPosition(forCentury century: JulianCentury) -> Cartesian3D
}

public extension Body {
    static func fastPosition(forJ2000 date: J2000Date) -> Cartesian3D {
        return self.fastPosition(forCentury: century(fromJ2000: date))
    }

    static func fastEquatorialPosition(forCentury century: JulianCentury) -> Spherical {
        let vector = self.fastPosition(forCentury: century)
        let transformedVector = vector * Matrix3D.transformToEquatorial(forCentury: century)
        return Spherical(withCartesian: transformedVector)
    }

    static func fastEquatorialPosition(forJ2000 date: J2000Date) -> Spherical {
        return self.fastEquatorialPosition(forCentury: century(fromJ2000: date))
    }
}

//
// MARK: Illumination
//
public struct Illumination {
    var k: Double
    var phi: Radians
}

// Non-scientific variable names
public extension Illumination {
    var fraction: Double {
        return self.k
    }

    var phaseAngle: Radians {
        return self.phi
    }
}

//
// MARK: Illuminated Body
//
public protocol IlluminatedBody {
    static func fastIllumination(forCentury century: JulianCentury) -> Illumination
}

public extension IlluminatedBody {
    static func fastIllumination(forDate date: J2000Date) -> Illumination {
        return self.fastIllumination(forCentury: century(fromJ2000: date))
    }
}

//
//
//
public enum PlanetRise: Double {
    // Sun
    case sunrise
    case civilTwilight
    case nauticalTwilight
    case astronomicalTwilight

    // Moon
    case moonrise

    // Planets
    case planetRise

    public var rawValue: Double {
        switch self {
        case .sunrise:
            return sin(rad(fromArcminutes: -50.0))
        case .civilTwilight:
            return sin(rad(fromDeg: -6.0))
        case .nauticalTwilight:
            return sin(rad(fromDeg: -12.0))
        case .astronomicalTwilight:
            return sin(rad(fromDeg: -18.0))
        case .moonrise:
            return sin(rad(fromArcminutes: 8.0))
        case .planetRise:
            return sin(rad(fromArcminutes: -34))
        }
    }
}

public enum RiseEvent {
    case neverRises
    case neverSets
    case Rises(J2000Date)
    case Sets(J2000Date)
    case RisesAndSets(J2000Date, J2000Date)

    init(riseDate: J2000Date?, setDate: J2000Date?, above: Bool) {
        if riseDate == nil && setDate == nil {
            self = above ? .neverSets : .neverRises
        } else if riseDate == nil {
            self = .Sets(setDate!)
        } else if setDate == nil {
            self = .Rises(riseDate!)
        } else {
            self = .RisesAndSets(riseDate!, setDate!)
        }
    }
}

struct Events {
    // TODO: Needs a rise, set,
}

public struct GeographicLocation {
    let longitude: Degrees
    let latitude: Degrees

    var cosPhi: Radians {
        return cos(rad(fromDeg: self.latitude))
    }

    var sinPhi: Radians {
        return sin(rad(fromDeg: self.latitude))
    }

    var lambda: Radians {
        return rad(fromDeg: self.longitude)
    }

    public init(longitude: Degrees, latitude: Degrees) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

public extension Body {
    static func sinAltitude(forDate date: J2000Date, location: GeographicLocation) -> Double {
        let position = self.fastEquatorialPosition(forJ2000: date)
        let gmstTime = gmst(fromJ2000: date)
        let gmstRad = FullCircle * (gmstTime / 86400.0).truncatingRemainder(dividingBy: 1.0)

        let tau = gmstRad + location.lambda - position.phi
        return location.sinPhi * sin(position.theta) + location.cosPhi * cos(position.theta) * cos(tau)
    }

    // Assumes that the date is the start of the search, using local time. So it should be midnight
    // for the local region.
    static func events(forDate date: J2000Date, planetRise: PlanetRise, location: GeographicLocation) -> RiseEvent {
        let sinh0 = planetRise.rawValue

        var riseTime: Double? = nil
        var setTime: Double? = nil
        var hour: Double = 1.0

        // Initialize Search
        var yMinus = self.sinAltitude(forDate: date, location: location) - sinh0 // hour - 1.0
        let above = yMinus > 0.0

        repeat {
            let y0    = self.sinAltitude(forDate: date + julianTime(fromHours: hour), location: location) - sinh0
            let yPlus = self.sinAltitude(forDate: date + julianTime(fromHours: hour + 1.0), location: location) - sinh0

            let (_, ye, roots) = findRoots(yMinus: yMinus, y0: y0, yPlus: yPlus)
            if roots.count == 1 {
                if yMinus < 0.0 {
                    riseTime = hour + roots[0]
                } else {
                    setTime = hour + roots[0]
                }
            } else if roots.count == 2 {
                if ye < 0.0 {
                    riseTime = hour + roots[1]
                    setTime = hour + roots[0]
                } else {
                    riseTime = hour + roots[0]
                    setTime = hour + roots[1]
                }
            }

            yMinus = yPlus
            hour += 2.0
        } while hour < 25.0 && !(riseTime != nil && setTime != nil)

        let riseDate: J2000Date? = riseTime == nil ? nil : date + julianTime(fromHours: riseTime!)
        let setDate: J2000Date? = setTime == nil ? nil : date + julianTime(fromHours: setTime!)
        return RiseEvent(riseDate: riseDate, setDate: setDate, above: above)
    }
}

//
// MARK: Transformations for Ecliptic/Equatorial
//
extension Matrix3D {
    static func transformToEcliptic(forCentury century: JulianCentury) -> Matrix3D {
        //( 23.43929111-(46.8150+(0.00059-0.001813*T)*T)*T/3600.0 )
        let eps: Double = ( 23.43929111 - (46.8150 + ( 0.00059 - 0.001813 * century) * century ) * century / 3600.0)
        return Matrix3D(withRotationAroundX: rad(fromDeg: eps))
    }

    static func transformToEquatorial(forCentury century: JulianCentury) -> Matrix3D {
        return Matrix3D.transformToEcliptic(forCentury: century).transposed()
    }
}
