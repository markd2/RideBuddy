import Foundation
import Combine
import SwiftUI

class DefaultMeterSources {
    private var bluetoothAccess: BlueToothAccess!

    lazy var heartRateMeterSource : MeterSource = {
        MeterSource(name: "Heart Rate",
            dataSource: bluetoothAccess.heartRatePublisher
            .receive(on: RunLoop.main)
            .map {
                return String($0)
            }.eraseToAnyPublisher())
    }()

    lazy var heartRateMeterSource2x : MeterSource = { 
        MeterSource(name: "Heart Rate 2x",
            dataSource: bluetoothAccess.heartRatePublisher
            .receive(on: RunLoop.main)
            .map {
                return String($0 * 2)
            }.eraseToAnyPublisher())
    }()

    lazy var batteryLevelMeterSource : MeterSource = {
        MeterSource(name: "Battery Level",
            dataSource: bluetoothAccess.batteryLevelPublisher
            .receive(on: RunLoop.main)
            .map {
                return String($0 * 100) + "%"
            }.eraseToAnyPublisher())
    }()

    init(_ bluetoothAccess: BlueToothAccess) {
        self.bluetoothAccess = bluetoothAccess
    }

    lazy var allTheThings: [MeterSource] = {
        [heartRateMeterSource, heartRateMeterSource2x, batteryLevelMeterSource]
    }()
}


struct DefaultMetersKey: EnvironmentKey {
    static let defaultValue: DefaultMeterSources = DefaultMeterSources(BlueToothAccess())
}

extension EnvironmentValues {
    var defaultMeters: DefaultMeterSources {
        get {
            return self[DefaultMetersKey.self]
        }
        set {
            self[DefaultMetersKey.self] = newValue
        }
    }
}
