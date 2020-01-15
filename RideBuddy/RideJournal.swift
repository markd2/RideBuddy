import Foundation
import Combine

enum BlahError: Error {
    case unknown
    case badDecoding(String) // explanatory text
    case rideJournalError(RideJournalErrorCode)
}

enum RideJournalErrorCode: Int {
    // Upload results, client-side
    case resultExceptionPassthrough = -9   // .Net exception leaked through to RideBuddy
    case copyPathError = -8         
    case removePathError = -7
    
    // Download resuls client-side
    case commError = -6
    case noResultCode = -5
    case versionMismatch = -4
    case noEnvelope = -3
    case noDataSent = -2
    case unknown = -1
    
    // Server-side results
    case success = 0
    case invalidLogin = 1
    case exception = 2
    case databaseInsertError = 3
}

struct RideJournalPayload {
    let flurbage = "Grongweezle"

    let heartZones: [Int]
    let threshold: Int
    let userType: String?
    let username: String
    let weight: Int?      // e.g. 250 :'-(
    let plannedRides: [RideJournalPlannedRide]

    init(webPayload wrapper: WebRideJournalPayload) throws {
        guard let payload = wrapper.usefulBits else {
            throw BlahError.badDecoding("Could not decode ride journal payload")
        }
        guard let errorCodeNumber = payload.errorCode else {
            throw BlahError.badDecoding("Could not decode ride journal error code")
        }


        guard let errorCode = RideJournalErrorCode(rawValue: errorCodeNumber) else {
            throw BlahError.badDecoding("Unexpected ride journal error code \(errorCodeNumber)")
        }

        if errorCode != .success {
            throw BlahError.rideJournalError(errorCode)
        }


        guard let heartZones = payload.heartZones else {
            throw BlahError.badDecoding("Could not decode heart zones")
        }
        self.heartZones = heartZones

        guard let threshold = payload.threshold else {
            throw BlahError.badDecoding("Could not decode threshold")
        }
        self.threshold = threshold

        guard let userType = payload.userType else {
            throw BlahError.badDecoding("Could not decode userType")
        }
        self.userType = userType

        guard let username = payload.username else {
            throw BlahError.badDecoding("Could not decode username")
        }
        self.username = username

        guard let weight = payload.weight else {
            throw BlahError.badDecoding("Could not decode weight")
        }
        self.weight = weight

        guard let plannedRides = payload.plannedRides else {
            throw BlahError.badDecoding("Could not decode plannedRides")
        }
        self.plannedRides = try plannedRides.map(RideJournalPlannedRide.init(webPlannedRide:))
    }
}

struct RideJournalPlannedRide {
    let plannedDateString: String
    let plannedDate: Date
    let plannedRideMinutes: Int
    let zoneTargets: [Int]
    // TODO - do the scaled zone target thing as well

    init(webPlannedRide planned: WebRideJournalPayloadUsefulBits.WebPlannedRide) throws {
        guard let plannedDateString = planned.plannedDate else {
            throw BlahError.badDecoding("Could not decode planned date")
        }
        self.plannedDateString = plannedDateString

        guard let plannedRideMinutes = planned.plannedRideMinutes else {
            throw BlahError.badDecoding("Could not decode planned ride minutes")
        }
        self.plannedRideMinutes = plannedRideMinutes

        guard let zoneTargets = planned.zoneTargets else {
            throw BlahError.badDecoding("Could not decode planned zoneTarget")
        }
        self.zoneTargets = zoneTargets

        guard let plannedDate = plannedDateString.rideJournalDate() else {
            throw BlahError.badDecoding("Could not convert planned date")
        }
        self.plannedDate = plannedDate
    }
}

struct WebRideJournalPayload: Codable {
    let usefulBits: WebRideJournalPayloadUsefulBits?

    private enum CodingKeys: String, CodingKey {
        case usefulBits = "d"  // .net-ism
    }
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
    let plannedRides: [WebPlannedRide]?

    private enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case heartZones
        case plannedRides
        case threshold
        case type = "__type"
        case userType
        case username = "userName"
        case version
        case weight
    }

    struct WebPlannedRide: Codable {
        let burnRate: [Double]?  // unused - for calorie calculation I think
        let plannedDate: String?
        let plannedRideMinutes: Int?
        let zoneTargets: [Int]?
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
        .map(\.data)
        .map { data in
            let string = String(data: data, encoding: .utf8)
            return data
        }
        .decode(type: WebRideJournalPayload.self, decoder: decoder)
        .tryMap { webPayload in
            try RideJournalPayload(webPayload: webPayload)
        }
        .eraseToAnyPublisher()

        return pipeline
    }
}

