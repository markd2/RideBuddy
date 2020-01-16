import Foundation
import Combine

protocol HeartRateDataSource {
    init(withResolver: Resolver)
}

class HeartRateDataSourceImpl: HeartRateDataSource {
    required init(withResolver resolver: Resolver) {
        if let toof = resolver.maybeResolve(BlueToothAccess.self) {
            print("oop")
        } else {
            print("ack")
        }

    }
}

