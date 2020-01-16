import Foundation

struct HeartZones {
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

        if heartRate >= zone5Boundary { return 5 }
        if heartRate >= zone4Boundary { return 4 }
        if heartRate >= zone3Boundary { return 3 }
        if heartRate >= zone2Boundary { return 2 }
        if heartRate >= zone1Boundary { return 1 }

        return 0
    }
}
