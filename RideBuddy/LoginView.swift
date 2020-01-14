import SwiftUI

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
        print("Snorgle")
    }
}
