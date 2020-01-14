import SwiftUI
import Combine

private var subscriptions = Set<AnyCancellable>()

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .padding(.horizontal)

            SecureField("Username", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            Button("Login", action: login)
        }
    }



    private func login() {
        RideJournal().login(username: username, password: password)
        .sink(receiveCompletion: { print("completed login: \($0)") },
            receiveValue: { print("received login \($0)") })
        .store(in: &subscriptions)
    }
}
