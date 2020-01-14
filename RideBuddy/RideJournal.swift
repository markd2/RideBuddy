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

    func loginPayload() -> Data? {
        let loginJSON =
        """
        {
            "user": {
                "password": "iwuvumikey",
                "userName": "markd"
            }
        }
        """

        return loginJSON.data(using: .utf8)
    }

    func login(username: String,
        password: String) -> AnyPublisher<RideJournalPayload, Error> {

        guard let payload = loginPayload() else {
            fatalError("do something reasonable here")
        }

        let url = URL(string: "https://www.cyclingfusiontrainingcenter.com/RideJournal/RideBuddyServer.svc/Ajax/Download")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "User-Agent" : "RideBuddy2"
        ]

        request.httpBody = payload
        

        let pipeline = session
        .dataTaskPublisher(for: request)
        .receive(on: networkQueue)
        .print()
        .map(\.data)
        .print("snorgle")
        .map { data in
            let string = String(data: data, encoding: .utf8)
            print("SNORGLE ", string)
            return data
        }
        .decode(type: WebRideJournalPayload.self, decoder: decoder)
        .map { webPayload in
            RideJournalPayload(webPayload: webPayload)
        }
        .eraseToAnyPublisher()

        return pipeline
    }
}

