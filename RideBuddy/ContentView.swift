import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LoginView().tabItem {
                VStack {
                    Text("Login")
                    Image(systemName: "desktopcomputer")
                }
            }
            
            Text("Snarnge").tabItem {
                VStack {
                    Text("Lub Dub")
                    Image(systemName: "heart.circle.fill")
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
