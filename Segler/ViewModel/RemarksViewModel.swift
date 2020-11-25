import Foundation
import NMSSH
import ProgressHUD

class RemarksViewModel: ObservableObject {
    
    @Published var bereich = ""
    @Published var selectedComment = ""
    @Published var comments = [Comment]()
    @Published var additionalComment = String()
    @Published var firstHirarActive : Bool = Bool()
    @Published var secondHirarActive : Bool = Bool()
    @Published var configLoaded = false
    @Published var commentIsOk = true
    
    func decoda(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let tempComments = try decoder.decode(ResponseComments.self, from: jsonData)
            comments = tempComments.comments
//            self.comments = [try decoder.decode(Comment.self, from: jsonData)]
        } catch {
            print("KOMMENTARE KONNTEN NICHT GELADEN WERDEN")
        }
    }
    
    func getJSON(session: String, username: String, password: String) {
        let session = NMSSHSession.init(host: "\(session)", andUsername: "\(username)")
        session.connect()
        if session.isConnected{
            session.authenticate(byPassword: "\(password)")
            if session.isAuthorized {
                let sftpsession = NMSFTP(session : session)
                sftpsession.connect()
                let content = sftpsession.contents(atPath: "config/config.json")
                if content != nil {
                    if let string = String(bytes: content!, encoding: .utf8) {
                    let jsonData = Foundation.Data(string.data(using: .utf8)!)
                        decoda(jsonData: jsonData)
                    }
                    configLoaded = true
                } else {
                    configLoaded = false
                }
            }
        }
    }
    
}
