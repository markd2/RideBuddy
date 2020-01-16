import Foundation
import Combine


class HeartRateDataSource: ServiceTypeResolvable {
    var dataSource: DataSource

    required init(resolver: Resolver) {
        if let toof = resolver.maybeResolve(BlueToothAccess.self) {
            dataSource = toof.heartRatePublisher
            .receive(on: RunLoop.main)
            .map {
                return String($0)
            }.eraseToAnyPublisher()
        
        } else {
            dataSource = [1, 2, 3, 4].publisher
            .map {
                return String($0)
            }.eraseToAnyPublisher()
        }
    }
}

class HeartRateDataSource2X: ServiceTypeResolvable {
    var dataSource: DataSource

    required init(resolver: Resolver) {
        if let toof = resolver.maybeResolve(BlueToothAccess.self) {
            dataSource = toof.heartRatePublisher
            .receive(on: RunLoop.main)
            .map {
                return String($0 * 2)
            }.eraseToAnyPublisher()
        
        } else {
            dataSource = [1, 2, 3, 4].publisher
            .map {
                return String($0 * 2)
            }.eraseToAnyPublisher()
        }
    }
}

