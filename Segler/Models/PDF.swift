import Foundation

struct PDF: Hashable {
    let id = UUID()
    var name: String
    var data: Data
    var time: Date?
    var isArchive: Bool
    var pdfName: String?
}
