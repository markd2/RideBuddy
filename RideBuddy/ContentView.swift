import SwiftUI
import Combine


class HeartRateThunk: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()

    @Published var heartRate: String = "---"
    @Published var batteryLevel: String = "---"

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

        bluetoothAccess.batteryLevelPublisher
        .receive(on: RunLoop.main)
        .map {
            return String(Int($0 * 100))
        }
        .assign(to: \.batteryLevel, on: self)
        .store(in: &subscriptions)
    }
}

struct ContentView: View {
    private var subscriptions = Set<AnyCancellable>()

    @ObservedObject var thunk: HeartRateThunk = HeartRateThunk()

    @Environment(\.bluetoothAccess) var bluetoothAccess: BlueToothAccess
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeters

    var heartRateMeterSource : MeterSource?
    var heartRateMeterSource2x : MeterSource?
    var batteryLevelMeterSource: MeterSource?

    init() {
//        thunk = HeartRateThunk(bluetoothAccess: bluetoothAccess)

    }

    var body: some View {
        VStack {
            MeterView(meterSource: defaultMeters.heartRateMeterSource).padding()
            MeterView(meterSource: defaultMeters.heartRateMeterSource2x).padding()
            MeterView(meterSource: defaultMeters.heartRateMeterSource).padding()
            MeterView(meterSource: defaultMeters.batteryLevelMeterSource).padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
