import Foundation
import Combine

struct RideJournalPayload {
    let flurbage = "Grongweezle"
}

struct RideJournal {
    func login(username: String,
        password: String) -> AnyPublisher<RideJournalPayload, Error> {
        return Just(RideJournalPayload())
        .setFailureType(to: Swift.Error.self)
        .eraseToAnyPublisher()
    }
}

