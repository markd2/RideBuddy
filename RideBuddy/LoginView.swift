import SwiftUI
import Combine

private var subscriptions = Set<AnyCancellable>()

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""

    @State var isError: Bool = false
    @State var errorText: String = ""

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
                    message: Text(errorText),
                    dismissButton: .default(Text("OK")))
            })
    }



    private func login() {
        RideJournal().login(username: username, password: password)
        .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.isError = true
                    self.errorText = error.localizedDescription
                }
            },
            receiveValue: {
                print("received login \($0)")
            })
        .store(in: &subscriptions)
    }
}
