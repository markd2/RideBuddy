import SwiftUI
import Combine


class HeartRateThunk: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()

    @Published var heartRate: String = "---"

    init(bluetoothAccess: BlueToothAccess? = nil) {
        guard let bluetoothAccess = bluetoothAccess else {
            return
        }
        bluetoothAccess.heartRatePublisher
        .receive(on: RunLoop.main)
        .map {
            return String($0)
        }
        .assign(to: \.heartRate, on: self)
        .store(in: &subscriptions)
    }
}

struct ContentView: View {
    @ObservedObject var thunk: HeartRateThunk = HeartRateThunk()

    @Environment(\.bluetoothAccess) var bluetoothAccess: BlueToothAccess

    init() {
        thunk = HeartRateThunk(bluetoothAccess: bluetoothAccess)
    }

    var body: some View {
        Text(thunk.heartRate).font(.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
