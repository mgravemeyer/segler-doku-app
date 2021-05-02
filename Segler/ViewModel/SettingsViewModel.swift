import Foundation
import NMSSH
import ProgressHUD

class SettingsViewModel: ObservableObject {
    
    init() {
        loadSavedSettings()
    }
    
    @Published var ip = String()
    @Published var adminMenuePassword = String()
    @Published var helpURL = String()
    @Published var serverUsername = String()
    @Published var serverPassword = String()
    @Published var userUsername = String()
    @Published var userPassword = String()
    @Published var jsonIsOnSameServer : Bool = Bool()
    @Published var useFixedUser: Bool = UserDefaults.standard.bool(forKey: "useFixedUser")
    @Published var useFixedUserTemp: Bool = UserDefaults.standard.bool(forKey: "useFixedUser")
    @Published var fixedUserName: String = UserDefaults.standard.string(forKey: "fixedUserName") ?? ""
    @Published var stringUrl = String()
    
    @Published var qp_iPhone = String()
    @Published var qv_iPhone = String()
    
    @Published var qp_iPod = String()
    @Published var qv_iPod = String()
    
    @Published var qp_iPad = String()
    @Published var qv_iPad = String()
    
    @Published var errorsJSON = [String]()
    
    func loadJSON() {
        decoderURL(jsonData: NetworkDataManager.shared.config!)
        decoderAdminPassword(jsonData: NetworkDataManager.shared.config!)
    }
    
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
    
    func decoderAdminPassword(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let adminMenuePasswordTemp = try decoder.decode(AdminLoginPassword.self, from: jsonData)
            adminMenuePassword.self = adminMenuePasswordTemp.password
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func decoderURL(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let adminMenuePasswordTemp = try decoder.decode(URLModel.self, from: jsonData)
            helpURL.self = adminMenuePasswordTemp.url
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
