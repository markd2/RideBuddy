import SwiftUI

let ride = Ride()

struct ContentView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeterSources

    var body: some View {
        TabView {

            LoginView().tabItem {
                VStack {
                    Text("All Meters")
                    Image(systemName: "desktopcomputer")
                }
            }

            SixUpView(meterSources: ride.$sixUp).tabItem {
                VStack {
                    Text("Six-Up")
                    Image(systemName: "leaf.arrow.circlepath")
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
