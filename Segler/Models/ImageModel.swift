import Foundation
import UIKit

struct ImageModel: Identifiable, Hashable {
    let id = UUID()
    var selected = false
    var assetURL: URL
    var thumbnail: UIImage
    var order: Int
    var orientation: String
    
    func fetchImage() -> Data {
            let photo = try? NSData(contentsOf: assetURL, options: .mappedIfSafe)
            return photo! as Data
    }
}
