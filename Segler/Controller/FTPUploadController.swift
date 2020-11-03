import Foundation
import CFNetwork
import ProgressHUD
import NMSSH
import Combine
import SwiftUI

extension Dictionary {
    init(_ keyValuePairs: [(Key, Value)]) {
        self.init(minimumCapacity: keyValuePairs.count)

        for (key, value) in keyValuePairs {
            self[key] = value
        }
    }
}

struct FTPUploadController {
    
    @ObservedObject var settingsVM : SettingsViewModel
    @ObservedObject var mediaViewModel : MediaViewModel
    @ObservedObject var orderViewModel : OrderViewModel
    @ObservedObject var userVM: UserViewModel
    
    func createJSON(bereich: String, meldungstyp: String, freitext: String, user: String) -> Data? {
        
        let keyValuePairs = [
            ("Bereich", "\(bereich)"),
            ("Meldungstyp", "\(meldungstyp)"),
            ("Freitext", "\(freitext)"),
            ("User", "\(user)")
        ]
        
        let dict = Dictionary(keyValuePairs)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
                return jsonData as Data
        } catch _ {
            return nil
        }
    }

    init(settingsVM: SettingsViewModel,mediaVM: MediaViewModel, orderViewModel: OrderViewModel, userVM: UserViewModel) {
        self.mediaViewModel = mediaVM
        self.settingsVM = settingsVM
        self.orderViewModel = orderViewModel
        self.userVM = userVM
     }

    func authenticate() -> Bool  {
        print("AUTH")
        var bool: Bool = false
        let session = NMSSHSession.init(host: "\(settingsVM.ip)", andUsername: "\(settingsVM.serverUsername)")
        session.connect()
        if session.isConnected {
            session.authenticate(byPassword: "\(settingsVM.serverPassword)")
            if session.isAuthorized {
                bool = true
            }
        } else {
            ProgressHUD.showError(" ")
            bool = false
        }
        return bool
    }
    
    func someAsyncFunction(remarksVM : RemarksViewModel,_ shouldThrow: Bool, completion: @escaping(String?) -> ()) {
        
        var finishedPhotoArray = [Data]()
        var finishedVideoArray = [Data]()
        
        var orderNrCheck = false

            DispatchQueue.global(qos: .background).async {
                
                ProgressHUD.show()
                
                DispatchQueue.main.async {
                
                let date = Date()
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyyMMdd"
                let convertedDate = dateFormatter.string(from: date)
                
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "HHmmss"
                let convertedDateTime = dateFormatter.string(from: date)
                
                //CHECK orderNr for Valid Numbers
                for char in self.orderViewModel.orderNr {
                    if char.isNumber {
                        self.orderViewModel.orderNrIsOk = true
                    } else {
                        self.orderViewModel.orderNrIsOk = false
                        break
                    }
                }
                
                if self.orderViewModel.orderNrIsOk && self.orderViewModel.orderNr.count == 5 {
                    self.orderViewModel.orderNrIsOk = true
                } else {
                    self.orderViewModel.orderNrIsOk = false
                }
                
                if self.orderViewModel.orderPositionIsOk && self.orderViewModel.orderPosition.count == 3 || self.orderViewModel.orderPosition.count == 2 || self.orderViewModel.orderPosition.count == 1 {
                    for char in self.orderViewModel.orderPosition {
                        if char.isNumber {
                            self.orderViewModel.orderPositionIsOk = true
                        } else {
                            self.orderViewModel.orderPositionIsOk = false
                            break
                        }
                    }
                } else {
                    self.orderViewModel.orderPositionIsOk = false
                }
                
                var errorMessage = "Fehler: \n"
                
                var error = false
                
                let session = NMSSHSession.init(host: "\(self.settingsVM.ip)", andUsername: "\(self.settingsVM.serverUsername)")
                session.connect()
                session.authenticate(byPassword: "\(self.settingsVM.serverPassword)")
                
                if self.mediaViewModel.images.isEmpty {
                    error = true
                    self.mediaViewModel.imagesIsOk = false
                    errorMessage = errorMessage + "Kein Bild ausgewählt! \n"
                } else {
                    self.mediaViewModel.imagesIsOk = true
                }
                
                if remarksVM.selectedComment == "" {
                    error = true
                    remarksVM.commentIsOk = false
                    errorMessage = errorMessage + "Kein Kommentar ausgewählt! \n"
                } else {
                    remarksVM.commentIsOk = true
                }
                
                if !(self.orderViewModel.orderNrIsOk) {
                    error = true
                    self.orderViewModel.orderNrIsOk = false
                    errorMessage = errorMessage + "Keine/Falsche Auftrags-Nr! \n"
                } else {
                    self.orderViewModel.orderNrIsOk = true
                }
                
                if !(self.orderViewModel.orderPositionIsOk) {
                    error = true
                    self.orderViewModel.orderPositionIsOk = false
                    errorMessage = errorMessage + "Keine/Falsche Positions-Nr! \n"
                } else {
                    self.orderViewModel.orderPositionIsOk = true
                }
            
                if error {
                    completion(errorMessage)
                }
                
                    let sftpsession = NMSFTP(session: session)
                    sftpsession.connect()
                    if sftpsession.isConnected && !error {
                        
                        for x in 0..<mediaViewModel.images.count {
                            
                            if mediaViewModel.images[x].selected {
                            
                                var jsonObject = Data()
                                
                                if self.settingsVM.useFixedUser {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                                } else {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.userVM.username)!
                                }
                                sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").json")
                                if sftpsession.writeContents(mediaViewModel.images[x].fetchImage(), toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").jpg") {
                                    completion(nil)
                                } else {
                                    errorMessage = errorMessage + "Fehler beim Hochladen "
                                }
                                
                            }
                        }
                        
                        for x in 0..<mediaViewModel.videos.count {
                            
                            if mediaViewModel.videos[x].selected {
                                
                                var jsonObject = Data()
                                
                                if self.settingsVM.useFixedUser {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                                } else {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.userVM.username)!
                                }
                                sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)v").json")
                                if sftpsession.writeContents(mediaViewModel.videos[x].fetchVideo(), toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)v").mp4") {
                                    completion(nil)
                                } else {
                                    errorMessage = errorMessage + "Fehler beim Hochladen "
                                }
                            }
                        }
                        
                        for x in 0..<mediaViewModel.imagesCamera.count {
                            
                                var jsonObject = Data()
                                
                                if self.settingsVM.useFixedUser {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                                } else {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.userVM.username)!
                                }
                                sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").json")
                            if sftpsession.writeContents(mediaViewModel.imagesCamera[x].image.pngData()!, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").jpg") {
                                    completion(nil)
                                } else {
                                    errorMessage = errorMessage + "Fehler beim Hochladen "
                                }
                        }
                        
                        for x in 0..<mediaViewModel.videosCamera.count {
                            
                                var jsonObject = Data()
                                
                                if self.settingsVM.useFixedUser {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                                } else {
                                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.userVM.username)!
                                }
                                sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").json")
                            if sftpsession.writeContents(mediaViewModel.videosCamera[x].video, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").mp4") {
                                    completion(nil)
                                } else {
                                    errorMessage = errorMessage + "Fehler beim Hochladen "
                                }
                        }
                        
                    }
                    }
            }
    }
}
