import SwiftUI

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

            VStack {
                ForEach(0 ..< defaultMeters.allTheThings.count) { index in
                    MeterView(meterSource: self.defaultMeters.allTheThings[index])
                }
            }.tabItem {
                VStack {
                    Text("All Meters")
                    Image(systemName: "speedometer")
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
