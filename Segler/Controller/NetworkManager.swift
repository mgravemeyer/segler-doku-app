import Foundation
import NMSSH

enum SelectedDataFromServer {
    case config
    case pdfs
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var session: NMSFTP?
    
    func connect(host: String, username: String, password: String) -> Bool {
        let connection = NMSSHSession.init(host: host, andUsername: username)
        if (session == nil) {
            connection.connect()
            if connection.isConnected {
                connection.authenticate(byPassword: password)
                if connection.isAuthorized {
                    self.session = NMSFTP(session: connection)
                    self.session!.connect()
                }
            }
            return true
        } else {
            return false
        }
    }
    func loadData(data: SelectedDataFromServer) -> Any {
        if (session != nil) {
            switch (data) {
            case .config:
                let data = self.session!.contents(atPath: "config/config.json")
                if (data != nil) {
                    return data!
                } else {
                    return Data()
                }
            case .pdfs:
                let data = self.session!.contentsOfDirectory(atPath: "protokolle")
                if (data != nil) {
                    return data!
                } else {
                    return Data()
                }
            }
        } else {
            return Data()
        }
    }
}
