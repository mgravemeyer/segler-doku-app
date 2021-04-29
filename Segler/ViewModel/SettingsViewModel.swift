import Foundation
import NMSSH
import ProgressHUD

class SettingsViewModel: ObservableObject {
    
    init() {
        loadSavedSettings()
        decoderURL(jsonData: NetworkDataManager.shared.config!)
        decoderAdminPassword(jsonData: NetworkDataManager.shared.config!)
    }
    
    @Published var pdfsToSearchOnServer = [ResponsePDF]()
    
    @Published var archive = [PDF]()
    
    @Published var savedPDF = PDF(name: "", data: Data())
    
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
        
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        else {
                print("error while saving or finding files")
                return
            }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for url in fileURLs {
                try archive.append(PDF(name: "\((url.lastPathComponent).dropLast(4))", data: Data(contentsOf: url)))
            }
            print(fileURLs)
        } catch {
            print("erroror")
            print(error.localizedDescription)
        }
        
//        decodaPDFs(jsonData: content as! Data)
//        let string = String(bytes: content, encoding: .utf8)
                
//                    let tempPdfData = sftpsession.contentsOfDirectory(atPath: "protokolle")
//
//                    for pdf in pdfsToSearchOnServer {
//                        let content = sftpsession.contents(atPath: "protokolle/\(pdf.datei).pdf")
//                        pdfs.append(PDF(name: pdf.name, data: content!))
//                        print("append \(pdf)")
//                    }
//
//                    print("full array: \(pdfs)")
                

//                    if let string = String(bytes: content, encoding: .utf8) {
//                        let jsonData = Foundation.Data(string.data(using: .utf8)!)
//                        decoda(jsonData: jsonData)
//                        decodaURL(jsonData: jsonData)
//                        decodaMediaQualityModel(jsonData: jsonData)
//                        configLoaded = true
//                    }
        
//                }
//            }
//        }
        
        
//        let session = NMSSHSession.init(host: "\(self.ip)", andUsername: "\(self.serverUsername)")
//        session.connect()
//        if session.isConnected{
//            session.authenticate(byPassword: "\(self.serverPassword)")
//            if session.isAuthorized {
//                let sftpsession = NMSFTP(session : session)
//                sftpsession.connect()
//                    let content = sftpsession.contents(atPath: "config/config.json")
//
//
//                    decodaPDFs(jsonData: content!)
//
//                    let tempPdfData = sftpsession.contentsOfDirectory(atPath: "protokolle")
//
//                    for pdf in pdfsToSearchOnServer {
//                        let content = sftpsession.contents(atPath: "protokolle/\(pdf.datei).pdf")
//                        pdfs.append(PDF(name: pdf.name, data: content!))
//                        print("append \(pdf)")
//                    }
//
//                    print("full array: \(pdfs)")
//
//                    if content != nil {
//                    if let string = String(bytes: content!, encoding: .utf8) {
//                        let jsonData = Foundation.Data(string.data(using: .utf8)!)
//                        decoda(jsonData: jsonData)
//                        decodaURL(jsonData: jsonData)
//                        decodaMediaQualityModel(jsonData: jsonData)
//                        configLoaded = true
//                    }
//                } else {
//                    configLoaded = false
//                }
//            }
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
    func decoderAdminPassword(jsonData : Foundation.Data) {
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
    
    struct ResponsePDF: Decodable, Encodable, Identifiable {
        var id = UUID()
        let name: String
        let datei: String
        private enum Keys: String, CodingKey {
            case name = "Name"
            case datei = "Datei"
        }
        init(from decoder: Decoder) throws {
              let values = try decoder.container(keyedBy: Keys.self)

              name = try values.decodeIfPresent(String.self, forKey: .name)!
              datei = try values.decodeIfPresent(String.self, forKey: .datei)!
          }
    }
    
    struct ResponsePDFs: Codable {
      var pdfs: [ResponsePDF]
      enum CodingKeys: String, CodingKey {
        case response = "Einstellungen"
        case pdfsArray = "Protokolle"
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy:
        CodingKeys.self, forKey: .response)
        
        self.pdfs = try response.decode([ResponsePDF].self, forKey: .pdfsArray)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var response = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        try response.encode(self.pdfs, forKey: .pdfsArray)
       }
    }
}

extension SettingsViewModel {
    func decodaPDFs(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let tempPDFs = try decoder.decode(ResponsePDFs.self, from: jsonData)
            pdfsToSearchOnServer = tempPDFs.pdfs
//            self.comments = [try decoder.decode(Comment.self, from: jsonData)]
        } catch {
            print("KOMMENTARE KONNTEN NICHT GELADEN WERDEN")
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
