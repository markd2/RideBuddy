import Foundation
import SwiftUI


class Ride {
    let sources: DefaultMeterSources
    let bluetoothAccess: BlueToothAccess

    @State private(set) var sixUp: [MeterSource]

    init() {
        bluetoothAccess = BlueToothAccess()
        sources = DefaultMeterSources(bluetoothAccess)
        sixUp = [sources.heartRateMeterSource,
            sources.heartRateMeterSource,
            sources.heartRateMeterSource2x,
            sources.heartRateMeterSource2x,
            sources.heartRateMeterSource,
            sources.batteryLevelMeterSource]
    }
}

