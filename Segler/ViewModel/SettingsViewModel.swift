import Foundation
import NMSSH
import ProgressHUD

class SettingsViewModel: ObservableObject {
    
    @Published var ip = String()
    @Published var adminMenuePassword = String()
    @Published var helpURL = String()
    @Published var serverUsername = String()
    @Published var serverPassword = String()
    @Published var userUsername = String()
    @Published var userPassword = String()
    @Published var hasSettedUp = UserDefaults.standard.bool(forKey: "hasSettedUp")
    @Published var jsonIsOnSameServer : Bool = Bool()
    @Published var configLoaded = false
    @Published var useFixedUser: Bool = UserDefaults.standard.bool(forKey: "useFixedUser")
    @Published var useFixedUserTemp: Bool = UserDefaults.standard.bool(forKey: "useFixedUser")
    @Published var fixedUserName: String = UserDefaults.standard.string(forKey: "fixedUserName") ?? ""
    @Published var stringUrl = String()
}

extension SettingsViewModel {
    func getJSON() {
        
        loadSavedSettings()
        

        
        let session = NMSSHSession.init(host: "\(self.ip)", andUsername: "\(self.serverUsername)")
        session.connect()
        if session.isConnected{
            session.authenticate(byPassword: "\(self.serverPassword)")
            if session.isAuthorized {
                let sftpsession = NMSFTP(session : session)
                sftpsession.connect()
                    let content = sftpsession.contents(atPath: "config/config.json")
                    if content != nil {
                    if let string = String(bytes: content!, encoding: .utf8) {
                        let jsonData = Foundation.Data(string.data(using: .utf8)!)
                        decoda(jsonData: jsonData)
                        decodaURL(jsonData: jsonData)
                        configLoaded = true
                    }
                } else {
                    configLoaded = false
                }
            }
        }
    }
}

extension SettingsViewModel {
    func loadSavedSettings() {
        self.ip = UserDefaults.standard.string(forKey: "ip") ?? ""
        self.serverUsername = UserDefaults.standard.string(forKey: "serverUsername") ?? ""
        self.serverUsername = UserDefaults.standard.string(forKey: "serverUsername") ?? ""
        self.serverPassword = UserDefaults.standard.string(forKey: "serverPassword") ?? ""
        if useFixedUser {
            self.userUsername = UserDefaults.standard.string(forKey: "fixedUserName") ?? ""
        } else {
            self.userUsername = UserDefaults.standard.string(forKey: "UserUsername") ?? ""
        }
        self.userPassword = UserDefaults.standard.string(forKey: "userPassword") ?? ""
    }
}

extension SettingsViewModel {
    func saveServerSettings() {
        UserDefaults.standard.set(ip, forKey: "ip")
        UserDefaults.standard.set(serverUsername, forKey: "serverUsername")
        UserDefaults.standard.set(serverPassword, forKey: "serverPassword")
        UserDefaults.standard.set(useFixedUserTemp, forKey: "useFixedUser")
        UserDefaults.standard.set(fixedUserName, forKey: "fixedUserName")
        self.useFixedUser = self.useFixedUserTemp
        if useFixedUser {
            self.userUsername = self.fixedUserName
        }
    }
}

extension SettingsViewModel {
    func deviceIsSettedUp() {
        hasSettedUp = true
        UserDefaults.standard.set(hasSettedUp, forKey: "hasSettedUp")
    }
}

extension SettingsViewModel {
    func deviceIsNotSettedUp() {
        hasSettedUp = false
        UserDefaults.standard.set(hasSettedUp, forKey: "hasSettedUp")
    }
}

extension SettingsViewModel {
    //RETURN FALSE IF hasSettedUp IS NEVER STORED -> DEVICE IS NEVER SETTED UP OR IP / USERNAME / PASSWORD IS EMPTY
    func hasSettedUpCheck() -> Bool {
        return UserDefaults.standard.object(forKey: "hasSettedUp") != nil
    }
}

extension SettingsViewModel {
    func decoda(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let adminMenuePasswordTemp = try decoder.decode(AdminLoginPassword.self, from: jsonData)
            adminMenuePassword.self = adminMenuePasswordTemp.password
        } catch {
            print("HIER IST ETWAS NICHT IN ORDNUNG")
            print(error.localizedDescription)
        }
    }
}

extension SettingsViewModel {
    func decodaURL(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let adminMenuePasswordTemp = try decoder.decode(URLModel.self, from: jsonData)
            helpURL.self = adminMenuePasswordTemp.url
        } catch {
            print("HIER IST ETWAS NICHT IN ORDNUNG")
            print(error.localizedDescription)
        }
    }
}
