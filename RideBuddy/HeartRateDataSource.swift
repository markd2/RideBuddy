import Foundation
import Combine

typealias NumericPublisher = AnyPublisher<Double, Never>

private func bluetoothOrFakePublisher(_ resolver: Resolver) -> NumericPublisher {

    if let toof = resolver.maybeResolve(BlueToothAccess.self) {
        return toof.heartRatePublisher.eraseToAnyPublisher()
        
    } else {
        return TimedDoler.shared.dataSource.eraseToAnyPublisher()
    }
}

class HeartRateDataSource: ServiceTypeResolvable {
    var numericPublisher: NumericPublisher
    
    required init(resolver: Resolver) {
        numericPublisher = bluetoothOrFakePublisher(resolver)
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}

class HeartRateDataSource2X: ServiceTypeResolvable {
    var numericPublisher: NumericPublisher

    required init(resolver: Resolver) {
        let heartRate = resolver.resolve(HeartRateDataSource.self).numericPublisher

        numericPublisher = heartRate
        .receive(on: RunLoop.main)
        .map {
            return Double(Int($0 * 2))
        }.eraseToAnyPublisher()
    }
}


class AverageHeartRateDataSource: ServiceTypeResolvable {
    var _numericPublisher: NumericPublisher? = nil
    var numericPublisher: NumericPublisher { return _numericPublisher! }

    var sum = 0.0
    var count = 0
    var average = 0.0

    func update(with value: Double) {
        sum += value
        count += 1
        average = sum / Double(count)
    }

    required init(resolver: Resolver) {
        let heartRate = resolver.resolve(HeartRateDataSource.self).numericPublisher

        _numericPublisher = heartRate
        .receive(on: RunLoop.main)
        .map {
            self.update(with: $0)
            return self.average
        }.eraseToAnyPublisher()
    }
}
