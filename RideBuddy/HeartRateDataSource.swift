import Foundation
import Combine

protocol HeartRateDataSource {
    init(withResolver: Resolver)
}

class HeartRateDataSourceImpl: HeartRateDataSource {
    required init(withResolver resolver: Resolver) {
        let toof = resolver.resolve(BlueToothAccess.self)
        print("whoa")
    }
}

