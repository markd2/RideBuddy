import Foundation
import Combine

typealias IntPublisher = AnyPublisher<Int, Never>

private func bluetoothOrFakePublisher(_ resolver: Resolver) -> IntPublisher {

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
            return String($0)
        }.eraseToAnyPublisher()
    }

}

class HeartRateDataSource2X: ServiceTypeResolvable {
    var dataSource: DataSource

    required init(resolver: Resolver) {
        dataSource = bluetoothOrFakePublisher(resolver)
        .receive(on: RunLoop.main)
        .map {
            return String($0 * 2)
        }.eraseToAnyPublisher()
    }
}


class AverageHeartRateDataSource: ServiceTypeResolvable {
    var _dataSource: DataSource? = nil
    var dataSource: DataSource { return _dataSource! }

    var sum = 0
    var count = 0
    var average: Double = 0.0

    func update(with value: Int) {
        sum += value
        count += 1
        average = Double(sum) / Double(count)
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
