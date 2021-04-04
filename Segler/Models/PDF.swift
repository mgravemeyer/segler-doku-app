import Foundation

struct PDF: Hashable {
    let id = UUID()
    let name: String
    let data: Data
}
