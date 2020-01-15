import SwiftUI

struct ContentView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeters

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
