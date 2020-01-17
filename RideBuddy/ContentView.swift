import SwiftUI

let ride = Ride()

struct ContentView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeterSources

    var body: some View {
        TabView {

            StripChartView().tabItem {
                VStack {
                    Text("All Meters")
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
