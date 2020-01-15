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
                    if let blahError = error as? BlahError {
                        self.isError = true

                        switch blahError {
                        case .badDecoding(let complaint):
                            self.errorText = complaint

                        case .rideJournalError(let errorCode):
                            if errorCode == .invalidLogin {
                                self.errorText = "Could not log in. Double-check your username and password."
                            } else {
                                self.errorText = "Error from Ride Journal: \(errorCode.rawValue)"
                            }

                        case .unknown:
                            self.errorText = "Something went wrong but I don't know what it was :-("
                        }

                    } else {
                        self.isError = true
                        self.errorText = error.localizedDescription
                    }
                }
            },
            receiveValue: {
                print("received login \($0)")
            })
        .store(in: &subscriptions)
    }
}
