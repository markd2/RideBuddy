import Foundation
import SwiftUI


class Ride {
    let sources: DefaultMeterSources
    let bluetoothAccess: BlueToothAccess

    @State var sixUp: [MeterSource]
    @State var allTheMeters: [MeterSource]

    init() {
        bluetoothAccess = BlueToothAccess()
        let heartZones = HeartZones(zone1Boundary: 90,
            zone2Boundary: 108,
            zone3Boundary: 125,
            zone4Boundary: 138,
            zone5Boundary: 150)
        sources = DefaultMeterSources(bluetoothAccess,
                                      heartZones: heartZones)
        sixUp = [sources.heartRateMeterSource,
            sources.averageHeartRateMeterSource,
            sources.heartRateMeterSource2X,
            sources.heartRateMeterSource2X,
            sources.heartRateMeterSource,
            sources.batteryLevelMeterSource]
        
        allTheMeters = [sources.heartRateMeterSource,
            sources.heartRateMeterSource2X,
            sources.batteryLevelMeterSource]
    }
}

