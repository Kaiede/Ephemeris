import XCTest
@testable import EphemerisTests

XCTMain([
    testCase(JulianCalendarTests.allTests),
    testCase(CoordinateTests.allTests),
    testCase(MatrixTests.allTests),
])
