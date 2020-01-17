import Foundation
import SwiftUI

struct HeartZones {
    // make some percentage of the total.
    let zone5Pad = 15

    static var zero = HeartZones(zone1Boundary: 0,
        zone2Boundary: 0,
        zone3Boundary: 0,
        zone4Boundary: 0,
        zone5Boundary: 0)

    let zone1Boundary: Int  // Bottom of interesting zone ranges
    let zone2Boundary: Int
    let zone3Boundary: Int  // T1
    let zone4Boundary: Int
    let zone5Boundary: Int  // T2

    func zoneForHeartRate(_ heartRate: Double) -> Double {
        let heartRate = Int(heartRate)
        
        var zone = 0.0
        var basis = 0
        var range = 0

        if heartRate >= zone5Boundary {
            zone = 5
            basis = heartRate - zone5Boundary
            range = zone5Pad
        }
        if heartRate >= zone4Boundary {
            zone = 4
            basis = heartRate - zone4Boundary
            range = zone5Boundary - zone4Boundary
        }
        if heartRate >= zone3Boundary {
            zone = 3
            basis = heartRate - zone3Boundary
            range = zone4Boundary - zone3Boundary
        }
        if heartRate >= zone2Boundary {
            zone = 2
            basis = heartRate - zone2Boundary
            range = zone3Boundary - zone2Boundary
        }
        if heartRate >= zone1Boundary {
            zone = 1
            basis = heartRate - zone1Boundary
            range = zone2Boundary - zone1Boundary
        }

        guard zone > 0 else { return 0 }
        
        let fraction = Double(basis) / Double(range)
        zone += fraction

        return zone
    }

    func minMax() -> (min: Int, max: Int) {
        return (zone1Boundary, zone5Pad)
    }

    func ranges() -> [Int] {
        var ranges: [Int] = []
        
        ranges += [zone2Boundary - zone1Boundary]
        ranges += [zone3Boundary - zone2Boundary]
        ranges += [zone4Boundary - zone3Boundary]
        ranges += [zone5Boundary - zone4Boundary]
        ranges += [zone5Pad]

        return ranges
    }

    func zonePercentages() -> [Double] {
        let ranges = self.ranges()
        let total = Double(ranges.reduce(0, { $0 + $1 }))

        let percentages = ranges.map {
            Double($0) / total
        }

        return percentages
    }
}

enum HeartZonesColor {
    static let blueLow = Color(red: 0.0000, green: 0.5430, blue: 0.8240)
    static let blueHigh = Color(red: 0.0000, green: 0.6520, blue: 0.9920)
    static let greenLow = Color(red: 0.0000, green: 0.8050, blue: 0.2850)
    static let greenHigh = Color(red: 0.0000, green: 0.9880, blue: 0.3480)
    static let yellowLow = Color(red: 0.8125, green: 0.7270, blue: 0.0000)
    static let yellowHigh = Color(red: 0.9920, green: 0.8870, blue: 0.0000)
    static let orangeLow = Color(red: 0.8060, green: 0.4570, blue: 0.0000)
    static let orangeHigh = Color(red: 0.9880, green: 0.5590, blue: 0.0000)
    static let redLow = Color(red: 0.7460, green: 0.0980, blue: 0.1250)
    static let redHigh = Color(red: 0.9220, green: 0.1210, blue: 0.1520)
}
