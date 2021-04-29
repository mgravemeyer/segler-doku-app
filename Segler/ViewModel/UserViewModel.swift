import Foundation

class UserViewModel: ObservableObject {
    
    init() {
        if(UserDefaults.standard.bool(forKey: "useFixedUser")){
            self.username = UserDefaults.standard.string(forKey: "fixedUserName") ?? ""
            self.loggedIn = true
        } else {
            self.loggedIn = false
        }
    }
    
    @Published var username = String()
    @Published var password = String()
    @Published var loggedIn: Bool
}
