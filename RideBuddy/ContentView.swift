import SwiftUI

struct ContentView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeterSources

    var body: some View {
        VStack {

            ForEach(0 ..< defaultMeters.allTheThings.count) { index in
                MeterView(meterSource: self.defaultMeters.allTheThings[index])
            }
//            MeterView(meterSource: defaultMeters.heartRateMeterSource2x).padding()
//            MeterView(meterSource: defaultMeters.heartRateMeterSource).padding()
//            MeterView(meterSource: defaultMeters.batteryLevelMeterSource).padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
