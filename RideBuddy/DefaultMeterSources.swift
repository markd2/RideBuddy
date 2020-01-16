import Foundation
import Combine
import SwiftUI

class DefaultMeterSources {
    private var bluetoothAccess: BlueToothAccess!

    let dependencyContainer: Container

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
        
        dependencyContainer = Container()
        .register(BlueToothAccess.self, instance: bluetoothAccess)
        .register(HeartRateDataSource.self, { resolver in
                return HeartRateDataSourceImpl(withResolver: resolver)
            })
        print("blargle \(dependencyContainer)")
        let flonk = dependencyContainer.resolve(HeartRateDataSource.self)
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
