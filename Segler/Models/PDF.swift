import Foundation

struct PDF: Hashable {
    let id = UUID()
    var name: String
    let data: Data
}
