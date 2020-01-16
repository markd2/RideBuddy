import Foundation
import SwiftUI


class Ride {
    let sources: DefaultMeterSources
    let bluetoothAccess: BlueToothAccess

    @State var sixUp: [MeterSource]
    @State var allTheMeters: [MeterSource]

    init() {
        bluetoothAccess = BlueToothAccess()
        sources = DefaultMeterSources(bluetoothAccess)
        sixUp = [sources.heartRateMeterSource,
            sources.heartRateMeterSource,
            sources.heartRateMeterSource2x,
            sources.heartRateMeterSource2x,
            sources.heartRateMeterSource,
            sources.batteryLevelMeterSource]
        
        allTheMeters = [sources.heartRateMeterSource,
            sources.heartRateMeterSource2x,
            sources.batteryLevelMeterSource]
    }
}

