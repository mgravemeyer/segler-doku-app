import Foundation
import NMSSH

class NetworkDataManager {
    
    static let shared = NetworkDataManager()
    
    var config: Data?
    var protokolle: [NMSFTPFile]?
    
    var session: NMSFTP?
    
    func connect(host: String, username: String, password: String) -> Bool {
        if (session == nil) {
            let connection = NMSSHSession.init(host: host, andUsername: username)
            connection.connect()
            if connection.isConnected {
                connection.authenticate(byPassword: password)
                if connection.isAuthorized {
                    print("wtf")
                    self.session = NMSFTP(session: connection)
                    self.session!.connect()
                    config = self.session!.contents(atPath: "config/config.json")
                    protokolle = self.session!.contentsOfDirectory(atPath: "protokolle")!
                    return true
                } else { return false }
            } else { return false }
        }
        return false
    }
}
