import Foundation
import NMSSH
import ProgressHUD

class SettingsViewModel: ObservableObject {
    
    @Published var pdfs = [PDF]()
    @Published var selectedPDF = PDF(name: "", data: Data())
    
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
    
    @Published var qp_iPhone = String()
    @Published var qv_iPhone = String()
    
    @Published var qp_iPod = String()
    @Published var qv_iPod = String()
    
    @Published var qp_iPad = String()
    @Published var qv_iPad = String()
    
    @Published var errorsJSON = [String]()
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
                    
                    let tempPdfData = sftpsession.contentsOfDirectory(atPath: "protokolle")
                    if tempPdfData != nil {
                        for pdfData in tempPdfData! {
                            self.pdfs.append(PDF(name: "\(pdfData.filename)", data: sftpsession.contents(atPath: "protokolle/\(pdfData.filename)")!))
                            print(pdfData.filename)
                        }
                    }
                
                    if content != nil {
                    if let string = String(bytes: content!, encoding: .utf8) {
                        let jsonData = Foundation.Data(string.data(using: .utf8)!)
                        decoda(jsonData: jsonData)
                        decodaURL(jsonData: jsonData)
                        decodaMediaQualityModel(jsonData: jsonData)
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
            print(error.localizedDescription)
        }
    }
}

extension SettingsViewModel {
    func decodaMediaQualityModel(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let mediaQualityModel = try decoder.decode(MediaQualityModel.self, from: jsonData)
            
            if mediaQualityModel.Qp_iPhone == "error" || mediaQualityModel.Qp_iPhone == "" {
                errorsJSON.append("qp_iPhone falsch")
            } else {
                qp_iPhone = mediaQualityModel.Qp_iPhone
            }
            
            if mediaQualityModel.Qv_iPhone == "error" || mediaQualityModel.Qv_iPhone == "" {
                errorsJSON.append("qv_iPhone falsch")
            } else {
                qv_iPhone = mediaQualityModel.Qv_iPhone
            }
            
            if mediaQualityModel.Qp_iPod == "error" || mediaQualityModel.Qp_iPod == "" {
                errorsJSON.append("qp_iPod falsch")
            } else {
                qp_iPod = mediaQualityModel.Qp_iPod
            }
            
            if mediaQualityModel.Qv_iPod == "error" || mediaQualityModel.Qv_iPod == "" {
                errorsJSON.append("qv_iPod falsch")
            } else {
                qv_iPod = mediaQualityModel.Qv_iPod
            }
            
            if mediaQualityModel.Qp_iPad == "error" || mediaQualityModel.Qp_iPad == "" {
                errorsJSON.append("qp_iPad falsch")
            } else {
                qp_iPad = mediaQualityModel.Qp_iPad
            }
            
            if mediaQualityModel.Qv_iPad == "error" || mediaQualityModel.Qv_iPad == ""  {
                errorsJSON.append("qv_iPad falsch")
            } else {
                qv_iPad = mediaQualityModel.Qv_iPad
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension SettingsViewModel {
//    func loadLocalPDFNames() {
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        do {
//            let urls = try FileManager.default.contentsOfDirectory(at: url!, includingPropertiesForKeys: nil)
//            for url in urls {
//                print(url.lastPathComponent)
//                pdfNameList.append(url.lastPathComponent)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func addPDF(name: String) {
//        self.pdfNameList.append(name)
//    }
    
//    func deletePDFFileManager(selection: String) {
//        guard
//            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        else {
//            print("error while finding file")
//            return
//        }
//        let fileURL = url.appendingPathComponent("\(selection)")
//        do {
//            try FileManager.default.removeItem(at: fileURL)
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
}
