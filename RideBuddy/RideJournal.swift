import Foundation
import Combine

struct RideJournalPayload {
    let flurbage = "Grongweezle"
}

struct RideJournal {
    private let networkQueue = DispatchQueue(label: "RideJournal",
        qos: .default, attributes: .concurrent)

    func login(username: String,
//        password: String) -> AnyPublisher<RideJournalPayload, Error> {
        password: String) -> AnyPublisher<Data, URLError> {

        let url = URL(string: "https://www.cyclingfusiontrainingcenter.com/RideJournal/RJPlanner.aspx")!

        let pipeline = URLSession.shared
        .dataTaskPublisher(for: url)
        .receive(on: networkQueue)
        .print("snorgle")
        .map(\.data)
        .eraseToAnyPublisher()


        return pipeline
    }
}

