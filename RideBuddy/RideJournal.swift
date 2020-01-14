import Foundation
import Combine

struct RideJournalPayload {
    let flurbage = "Grongweezle"

    init(webPayload payload: WebRideJournalPayload) {
        print("whoa - \(payload)")
    }
}

struct WebRideJournalPayload: Codable {
    let d: WebRideJournalPayloadUsefulBits?
}

struct WebRideJournalPayloadUsefulBits: Codable {
    let errorCode: Int?
    let heartZones: [Int]?
    let threshold: Int?
    let type: String?  // e.g. Download:http://www.RideBuddycom/Data/
    let userType: String? // e.g. Rider
    let username: String?
    let version: String?  // e.g. 1.0
    let weight: Int?      // e.g. 250 :'-(

    private enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case heartZones
        case threshold
        case type = "__type"
        case userType
        case username = "userName"
        case version
        case weight
    }
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

