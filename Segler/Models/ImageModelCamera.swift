import Foundation
import UIKit

struct ImageModelCamera: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage
    var order: Int
}
