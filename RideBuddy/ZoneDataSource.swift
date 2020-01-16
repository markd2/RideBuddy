import Foundation
import Combine

class HeartZoneDataSource: ServiceTypeResolvable {
    var numericPublisher: NumericPublisher

    required init(resolver: Resolver) {
        let heartRate = resolver.resolve(HeartRateDataSource.self).numericPublisher
        let zones = resolver.resolve(HeartZones.self)

        numericPublisher = heartRate
        .receive(on: RunLoop.main)
        .map {
            let zone = zones.zoneForHeartRate($0)
            return zone
        }.eraseToAnyPublisher()
    }

}

