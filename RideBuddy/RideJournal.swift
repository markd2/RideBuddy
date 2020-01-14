import Foundation
import Combine

struct RideJournalPayload {
    let flurbage = "Grongweezle"

    init(webPayload payload: WebRideJournalPayload) {
    }
}

struct WebRideJournalPayload: Codable {
}

struct RideJournal {
    private let networkQueue = DispatchQueue(label: "RideJournal",
        qos: .default, attributes: .concurrent)

    var session: URLSession {
        return URLSession.shared
    }

    private let decoder = JSONDecoder()

    func login(username: String,
        password: String) -> AnyPublisher<RideJournalPayload, Error> {

        let url = URL(string: "https://www.cyclingfusiontrainingcenter.com/RideJournal/RJPlanner.aspx")!

        let pipeline = session
        .dataTaskPublisher(for: url)
        .receive(on: networkQueue)
        .print("snorgle")
        .map(\.data)
        .decode(type: WebRideJournalPayload.self, decoder: decoder)
        .map { webPayload in
            RideJournalPayload(webPayload: webPayload)
        }
        .eraseToAnyPublisher()

        return pipeline
    }
}

