import Foundation
import UIKit

struct VideoModel: Identifiable, Hashable {
    let id = UUID()
    var selected = false
    var assetURL: URL
    var thumbnail: UIImage
    var order: Int
    var orientation: String
    
    func fetchVideo() -> Data {
            let video = try? NSData(contentsOf: assetURL, options: .mappedIfSafe)
            return video! as Data
    }
}
