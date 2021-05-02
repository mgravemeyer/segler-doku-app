import Foundation
import NMSSH

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
    
    func sendPhotosVideos(filename: String, data: [Data], json: Data) {
        DispatchQueue.main.async {
            for data in data {
                self.session!.writeContents(json, toFileAtPath: "\(filename)")
                self.session!.writeContents(data, toFileAtPath: "\(filename)")
            }
        }
    }
    
    func sendPDF(filename: String, pdfData: Data, json: Data) {
        DispatchQueue.main.async {
            self.session!.writeContents(json, toFileAtPath: "\(filename)")
            self.session!.writeContents(pdfData, toFileAtPath: "\(filename)")
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
}
