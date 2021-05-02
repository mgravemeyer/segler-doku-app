import Foundation

struct ImageModelCamera: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage
    var order: Int
}
