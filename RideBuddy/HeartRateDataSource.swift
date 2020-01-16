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
    var dataSource: DataSource
    
    required init(resolver: Resolver) {
        dataSource = bluetoothOrFakePublisher(resolver)
        .receive(on: RunLoop.main)
        .map {
            return String(Int($0))
        }.eraseToAnyPublisher()
    }

}

class HeartRateDataSource2X: ServiceTypeResolvable {
    var dataSource: DataSource

    required init(resolver: Resolver) {
        dataSource = bluetoothOrFakePublisher(resolver)
        .receive(on: RunLoop.main)
        .map {
            return String(Int($0 * 2))
        }.eraseToAnyPublisher()
    }
}


class AverageHeartRateDataSource: ServiceTypeResolvable {
    var _dataSource: DataSource? = nil
    var dataSource: DataSource { return _dataSource! }

    var sum = 0.0
    var count = 0
    var average = 0.0

    func update(with value: Double) {
        sum += value
        count += 1
        average = sum / Double(count)
    }

    required init(resolver: Resolver) {
        _dataSource = bluetoothOrFakePublisher(resolver)
        .receive(on: RunLoop.main)
        .map {
            self.update(with: $0)
            return String(format: "%0.1f", self.average)
        }.eraseToAnyPublisher()
    }
}
