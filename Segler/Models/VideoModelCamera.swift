import Foundation
import UIKit

struct VideoModelCamera: Identifiable, Hashable {
    let id = UUID()
    var url: URL
    var video: Data
    var thumbnail: UIImage
    var order: Int
    var orientation: String
}
