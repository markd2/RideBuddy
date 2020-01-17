import SwiftUI

let ride = Ride()

struct ContentView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeterSources

    var body: some View {
        TabView {
            
            VStack {
                StripChartView(dataSource: ride.rollingHeartRate,
                    heartZones: ride.heartZones)
                HStack {
                    MeterView(meterSource: ride.sixUp[0])
                    MeterView(meterSource: ride.sixUp[3])
                }
            }.tabItem {
                VStack {
                    Text("Chart")
                    Image(systemName: "tornado")
                }
            }

            SixUpView(meterSources: ride.$sixUp, allTheMeters: ride.$allTheMeters).tabItem {
                VStack {
                    Text("Six-Up")
                    Image(systemName: "leaf.arrow.circlepath")
                }
            }

            LoginView().tabItem {
                VStack {
                    Text("All Meters")
                    Image(systemName: "desktopcomputer")
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
