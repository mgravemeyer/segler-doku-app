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
    @Published var commentIsOk = true
    
    func loadJSON() {
        decoderComments(jsonData: NetworkDataManager.shared.config!)
    }
    
    func decoderComments(jsonData : Foundation.Data) {
        let decoder = JSONDecoder()
        do {
            let tempComments = try decoder.decode(ResponseComments.self, from: jsonData)
            comments = tempComments.comments
        } catch {
            print("KOMMENTARE KONNTEN NICHT GELADEN WERDEN")
        }
    }
}
