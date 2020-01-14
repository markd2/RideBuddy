import SwiftUI
import Combine

private var subscriptions = Set<AnyCancellable>()

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var isError: Bool = false

    var body: some View {
        VStack {
            Text("Log in to RideJournal").padding()

            TextField("Username", text: $username)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .padding(.horizontal)

            SecureField("Password", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            Button("Login", action: login)
        }.alert(isPresented: $isError, content: {
                Alert(title: Text("Snorgle"),
                    message: Text("dn fsjdfn sjnfsdjnf sjdn fjsnjfsdnjf"),
                    dismissButton: .default(Text("OK")))
            })
    }



    private func login() {
        RideJournal().login(username: username, password: password)
        .sink(receiveCompletion: { print("completed login: \($0)") },
            receiveValue: { print("received login \($0)") })
        .store(in: &subscriptions)
    }
}
