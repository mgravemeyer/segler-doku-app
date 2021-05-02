import Foundation
import NMSSH

//to:do handles currently network stuff and also perparing data to be send. could be later splitted up to data and a seperate network manager.
class NetworkDataManager {
    
    static let shared = NetworkDataManager()
    
    var config: Data?
    var protokolle: [NMSFTPFile]?
    
    var session: NMSFTP?
    
    func connect(host: String, username: String, password: String, isInit: Bool) -> Bool {
        if (session == nil) {
            let connection = NMSSHSession.init(host: host, andUsername: username)
            connection.connect()
            if connection.isConnected {
                connection.authenticate(byPassword: password)
                if connection.isAuthorized {
                    self.session = NMSFTP(session: connection)
                    self.session!.connect()
                    if isInit {
                        config = self.session!.contents(atPath: "config/config.json")
                        protokolle = self.session!.contentsOfDirectory(atPath: "protokolle")!
                    }
                    return true
                } else { return false }
            } else { return false }
        }
        return false
    }
    
    func prepImagesData(mediaVM: MediaViewModel) -> [Data] {
        var data = [Data]()
        for image in mediaVM.images {
            data.append(image.fetchImage())
        }
        for image in mediaVM.imagesCamera {
            data.append(image.image.pngData()!)
        }
        return data
    }
    
    func prepVideosData(mediaVM: MediaViewModel) -> [Data] {
        var data = [Data]()
        for video in mediaVM.videos {
            data.append(video.fetchVideo())
        }
        for video in mediaVM.videosCamera {
            data.append(video.video)
        }
        return data
    }
    
    func sendToFTP(photos: [Data], videos: [Data], pdf: Data, mediaVM: MediaViewModel, userVM: UserViewModel, orderVM: OrderViewModel, remarksVM: RemarksViewModel) {
        let filename = generateDataName(orderVM: orderVM)
        let json = generateJSON(userVM: userVM, remarksVM: remarksVM)
        if !photos.isEmpty {
            sendPhotos(filename: filename, data: prepImagesData(mediaVM: mediaVM), json: json!)
        }
        if !videos.isEmpty {
            sendVideos(filename: filename, data: prepVideosData(mediaVM: mediaVM), json: json!)
        }
        if !pdf.isEmpty {
            sendPDF(filename: filename, pdfData: pdf, jsonData: json!)
        }
    }
    
    func sendPhotos(filename: String, data: [Data], json: Data) {
        DispatchQueue.main.async {
            for (index, photo) in data.enumerated() {
                self.session!.writeContents(json, toFileAtPath: "\(filename)\(index).json")
                self.session!.writeContents(photo, toFileAtPath: "\(filename)\(index).json")
            }
        }
    }
    
    func sendVideos(filename: String, data: [Data], json: Data) {
        DispatchQueue.main.async {
            for (index, video) in data.enumerated() {
                self.session!.writeContents(json, toFileAtPath: "\(filename)\(index).json")
                self.session!.writeContents(video, toFileAtPath: "\(filename)\(index).mp4")
            }
        }
    }
    
    func sendPDF(filename: String, pdfData: Data, jsonData: Data) {
        DispatchQueue.main.async {
            self.session!.writeContents(jsonData, toFileAtPath: "\(filename).json")
            self.session!.writeContents(pdfData, toFileAtPath: "\(filename).pdf")
            guard
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
                    print("error while saving or finding files")
                    return
                }
            let fileURL = url.appendingPathComponent("\(filename).pdf")
            do {
                try pdfData.write(to: fileURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func generateDataName(orderVM: OrderViewModel) -> String {
        return ("\(orderVM.orderNr)\(orderVM.orderPosition)\(getDate())\(getTime())")
    }
    
    func getDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: currentDate)
    }
    
    func getTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HHmmss"
        return dateFormatter.string(from: currentDate)
    }
    
    func generateJSON(userVM: UserViewModel, remarksVM: RemarksViewModel) -> Data? {
        
        let keyValuePairs = [
            ("Bereich", "\(remarksVM.bereich)"),
            ("Meldungstyp", "\(remarksVM.selectedComment)"),
            ("Freitext", "\(remarksVM.additionalComment)"),
            ("User", "\(userVM.username)"),
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

}
