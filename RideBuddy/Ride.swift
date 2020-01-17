import Foundation
import SwiftUI


class Ride {
    let sources: DefaultMeterSources
    let bluetoothAccess: BlueToothAccess

    let rollingHeartRate = TimedRollingDoler.shared.dataSource.eraseToAnyPublisher()

    let heartZones: HeartZones

    @State var sixUp: [MeterSource]
    @State var allTheMeters: [MeterSource]

    init() {
        bluetoothAccess = BlueToothAccess()
        heartZones = HeartZones(zone1Boundary: 90,
            zone2Boundary: 108,
            zone3Boundary: 125,
            zone4Boundary: 138,
            zone5Boundary: 150)
        sources = DefaultMeterSources(bluetoothAccess,
                                      heartZones: heartZones)
        sixUp = [sources.heartRateMeterSource,
            sources.averageHeartRateMeterSource,
            sources.heartRateMeterSource2X,
            sources.currentHeartZoneMeterSource,
            sources.heartRateMeterSource,
            sources.batteryLevelMeterSource]
        
        allTheMeters = [sources.heartRateMeterSource,
            sources.heartRateMeterSource2X,
            sources.batteryLevelMeterSource]
    }
}

