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
            DispatchQueue.global(qos: .background).async {
                
                ProgressHUD.show()
                
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
                
                    var imagesWithJpegData = [Data]()
                
                    for x in 0..<self.mediaViewModel.images.count {
                        if mediaViewModel.images[x].selected {
                            guard var jpegData = try? self.mediaViewModel.images[x].thumbnail.jpegData(compressionQuality: 0.2)
                            else { fatalError("Keine Datei gefunden") }
                            self.addJPEGComment(to: &jpegData, "\(remarksVM.selectedComment)")
                            self.addJPEGComment(to: &jpegData, "\(remarksVM.additionalComment)")
                            imagesWithJpegData.append(jpegData)
                        }
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
                                if sftpsession.writeContents(imagesWithJpegData[x], toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(x)").jpg") {
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
                    }
        }
    }
    
//    func uploadFile(remarksVM : RemarksViewModel) {
//
//
//
//        let date = Date()
//        let calendar = Calendar.current
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
//        let day = calendar.component(.day, from: date)
//        let month = calendar.component(.month, from: date)
//        let year = calendar.component(.year, from: date)
//
//        let session = NMSSHSession.init(host: "\(settingsVM.ip)", andUsername: "\(settingsVM.serverUsername)")
//        session.connect()
//        session.authenticate(byPassword: "\(settingsVM.serverPassword)")
//
//        if !mediaViewModel.images.isEmpty {
//
//            var imagesWithJpegData = [Data]()
//
//            for x in 0..<mediaViewModel.images.count {
//                guard var jpegData = try? mediaViewModel.images[x].jpegData(compressionQuality: 0.2)
//                else { fatalError("Keine Datei gefunden") }
//                addJPEGComment(to: &jpegData, "\(remarksVM.selectedComment)")
//                addJPEGComment(to: &jpegData, "\(remarksVM.additionalComment)")
//
//                imagesWithJpegData.append(jpegData)
//            }
////            var data : Data = Data(addMetaData(image: mediaViewModel.image!).jpegData(compressionQuality: 0.2)!)
////            let data : Data = mediaViewModel.image!.jpegData(compressionQuality: 0.2)!
//            if orderViewModel.orderNr != "" {
//                if session.isAuthorized {
//                    let sftpsession = NMSFTP(session: session)
//                    sftpsession.connect()
//                    if sftpsession.isConnected {
//                        for x in 0..<imagesWithJpegData.count {
//                            if sftpsession.writeContents(imagesWithJpegData[x], toFileAtPath: "\("\(orderViewModel.orderNr)_\(orderViewModel.orderPosition)_\(day)\(month)\(year)_\(hour)\(minutes)\(seconds)_\(x)").jpg") {
//                                ProgressHUD.showSuccess("Hochgeladen")
////                                orderViewModel.machineName = ""
////                                orderViewModel.orderNr = ""
////                                orderViewModel.orderPosition = ""
////                                mediaViewModel.images.removeAll()
////                                remarksVM.selectedComment = ""
////                                remarksVM.additionalComment = ""
//                            } else {
//                                ProgressHUD.showError("Fehler beim Hochladen")
//                            }
//                        }
//                    } else {
//                        ProgressHUD.showError("Nicht verbunden")
//                    }
//                } else {
//                    ProgressHUD.showError("Keine Autorisierung")
//                }
//            } else {
//                ProgressHUD.showError("Auftrags-Nr eintragen")
//            }
//        }
//    }
    
    func addJPEGComment(to jpegData: inout Data, _ comment: String) {

        // find index of first SOF marker, or EOI
        let sofMarkers: [UInt8] = [
            0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6,
            0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE,
            0xCF, 0xD9 // EOI
        ]

        var firstSOFRange: Range<Data.Index>?
        for marker in sofMarkers {
            if let range = jpegData.range(of: Data(bytes: [ 0xFF, marker ])) {
                firstSOFRange = range
                break
            }
        }

        guard let firstSOFIndex = firstSOFRange?.lowerBound
            else { fatalError("No SOF or EOI marker found.") }

        // create comment byte array
        let length = comment.lengthOfBytes(using: .utf8) + 2
        let l1 = UInt8((length >> 8) & 0xFF)
        let l2 = UInt8(length & 0xFF)
        let commentArray = [ 0xFF, 0xFE /* COM marker */, l1, l2 ] + [UInt8](comment.utf8)

        // insert comment array into image data object
        jpegData.insert(contentsOf: commentArray, at: firstSOFIndex)
    }
}
