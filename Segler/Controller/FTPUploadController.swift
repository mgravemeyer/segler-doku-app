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
            ("User", "\(user)"),
            ("AppVersion", Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String),
            ("Geraet", UIDevice.current.name)
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
        
        var errorMessage = "Fehler: \n"
        var error = false
        
        var orderNrCheck = false
        var orderPositionCheck = false
        
        var imagesCheck = false
        var commentCheck = false
        
        var jsonObject = Data()
        
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        let convertedDate = dateFormatter.string(from: date)
        
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HHmmss"
        let convertedDateTime = dateFormatter.string(from: date)
                
        ProgressHUD.show()
        
        let session = NMSSHSession.init(host: "\(self.settingsVM.ip)", andUsername: "\(self.settingsVM.serverUsername)")
        session.connect()
        session.authenticate(byPassword: "\(self.settingsVM.serverPassword)")
        
            DispatchQueue.main.async {
                //CHECK orderNr for Valid Numbers
                for char in self.orderViewModel.orderNr {
                    if char.isNumber {
                        orderNrCheck = true
//                        self.orderViewModel.orderNrIsOk = true
                    } else {
                        orderNrCheck = false
//                        self.orderViewModel.orderNrIsOk = false
                        break
                    }
                }
                
                if self.orderViewModel.orderNrIsOk && self.orderViewModel.orderNr.count == 5 {
                    orderNrCheck = true
//                    self.orderViewModel.orderNrIsOk = true
                } else {
                    orderNrCheck = false
//                    self.orderViewModel.orderNrIsOk = false
                }
                
                if self.orderViewModel.orderPositionIsOk && self.orderViewModel.orderPosition.count == 3 || self.orderViewModel.orderPosition.count == 2 || self.orderViewModel.orderPosition.count == 1 {
                    for char in self.orderViewModel.orderPosition {
                        if char.isNumber {
//                            self.orderViewModel.orderPositionIsOk = true
                            orderPositionCheck = true
                        } else {
//                            self.orderViewModel.orderPositionIsOk = false
                            orderPositionCheck = false
                            break
                        }
                    }
                } else {
                    orderPositionCheck = false
//                    self.orderViewModel.orderPositionIsOk = false
                }
                
                if self.mediaViewModel.images.isEmpty && self.mediaViewModel.imagesCamera.isEmpty && self.mediaViewModel.videos.isEmpty && self.mediaViewModel.videosCamera.isEmpty {
                    error = true
                    imagesCheck = false
//                    self.mediaViewModel.imagesIsOk = false
                    errorMessage = errorMessage + "Kein Bild ausgewählt! \n"
                } else {
                    imagesCheck = true
//                    self.mediaViewModel.imagesIsOk = true
                }
                
                if remarksVM.selectedComment == "" {
                    error = true
                    commentCheck = false
//                    remarksVM.commentIsOk = false
                    errorMessage = errorMessage + "Kein Kommentar ausgewählt! \n"
                } else {
                    commentCheck = true
//                    remarksVM.commentIsOk = true
                }
                
                if !orderNrCheck {
                    error = true
                    orderNrCheck = false
//                    self.orderViewModel.orderNrIsOk = false
                    errorMessage = errorMessage + "Keine/Falsche Auftrags-Nr! \n"
                } else {
                    orderNrCheck = true
//                    self.orderViewModel.orderNrIsOk = true
                }
                
                if !orderPositionCheck {
                    error = true
//                    self.orderViewModel.orderPositionIsOk = false
                    orderPositionCheck = false
                    errorMessage = errorMessage + "Keine/Falsche Positions-Nr! \n"
                } else {
                    orderPositionCheck = true
//                    self.orderViewModel.orderPositionIsOk = true
                }
                    
                for image in mediaViewModel.images {
                    if image.selected {
                        let image = UIImage(data: image.fetchImage())
                        if UIDevice.current.name.contains("iPhone") {
                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(truncating: NumberFormatter().number(from: settingsVM.qp_iPhone)!)))!)
                            print("Ipone Send Image With Quality: \(settingsVM.qp_iPhone)")
                        } else
                        if UIDevice.current.name.contains("iPod touch") {
                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(truncating: NumberFormatter().number(from: settingsVM.qp_iPad)!)))!)
                        } else
                        if UIDevice.current.name.contains("iPad") {
                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(truncating: NumberFormatter().number(from: settingsVM.qp_iPad)!)))!)
                        } else {
                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(truncating: NumberFormatter().number(from: settingsVM.qp_iPod)!)))!)
                        }
                    }
                }
            
                for image in mediaViewModel.imagesCamera {
                    if UIDevice.current.name.contains("iPhone") {
                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPhone.floatValue)))!)
                    } else
                    if UIDevice.current.name.contains("iPod touch") {
                        print(CGFloat(settingsVM.qp_iPod.floatValue))
                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPod.floatValue)))!)
                    } else
                    if UIDevice.current.name.contains("iPad") {
                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPad.floatValue)))!)
                    } else {
                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPod.floatValue)))!)
                    }
                }
                        
                for video in mediaViewModel.videos {
                    if video.selected {
                        print("Video: \(video)")
                        finishedVideoArray.append(video.fetchVideo())
                    }
                }
                for video in mediaViewModel.videosCamera {
                    print("VideoCamera: \(video)")
                    finishedVideoArray.append(video.video)
                }
                
//                if finishedPhotoArray || finishedVideoArray {
//                    error = true
//                }
                
                if error {
                    completion(errorMessage)
                }
                        
                //setting up json file
                if self.settingsVM.useFixedUser {
                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                } else {
                    jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.userVM.username)!
                }
            
            
            DispatchQueue.global(qos: .background).async {
        
            let sftpsession = NMSFTP(session : session)
            sftpsession.connect()
            
                if sftpsession.isConnected && !error {
                        
                    var counter = 0

//                    if !finishedPhotoArray.isEmpty {
//                        print("IF SCHLEIFE IST OK")
//                        print("TRANSFERDATA: \(finishedPhotoArray)")
                        for photoData in finishedPhotoArray {
                            print("TRANSFER PHOTO DATA LOLr")
                            sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").json")
                            sftpsession.writeContents(photoData, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").jpg")
                            counter += 1
                        }
//                    }
                    if !finishedVideoArray.isEmpty {
                        for videoData in finishedVideoArray {
                            sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").json")
                            sftpsession.writeContents(videoData, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").mp4")
                            counter += 1
                        }
                    }
                    completion(nil)
                } else {
                    print("ERRORHELP")
                }
            }
        }
    }
}
