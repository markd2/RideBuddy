import Foundation
import Combine
import SwiftUI

class DefaultMeterSources {
    private var bluetoothAccess: BlueToothAccess!

    let sources: Container

    lazy var heartRateMeterSource : MeterSource = {
        MeterSource(name: "Heart Rate",
            dataSource: sources.resolve(HeartRateDataSource.self).dataSource)
    }()

    lazy var heartRateMeterSource2X : MeterSource = {
        MeterSource(name: "Heart Rate 2X",
            dataSource: sources.resolve(HeartRateDataSource2X.self).dataSource)
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
        
        sources = Container()
//        .register(BlueToothAccess.self, instance: bluetoothAccess)
//        .register(HeartRateDataSource.self, { resolver in
//                return HeartRateDataSource(withResolver: resolver)
//            })
        .register(HeartRateDataSource.self)
        .register(HeartRateDataSource2X.self)
        print("blargle \(sources)")
        let flonk = sources.resolve(HeartRateDataSource.self)
    }
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
