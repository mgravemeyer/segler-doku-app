import Foundation

class UserViewModel: ObservableObject {
    @Published var username = String()
    @Published var password = String()
    @Published var loggedIn = false
}
