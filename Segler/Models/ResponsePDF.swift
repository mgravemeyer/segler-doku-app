import Foundation

struct ResponsePDF: Decodable, Encodable, Identifiable {
    var id = UUID()
    let name: String
    let datei: String
    private enum Keys: String, CodingKey {
        case name = "Name"
        case datei = "Datei"
    }
    init(from decoder: Decoder) throws {
          let values = try decoder.container(keyedBy: Keys.self)

          name = try values.decodeIfPresent(String.self, forKey: .name)!
          datei = try values.decodeIfPresent(String.self, forKey: .datei)!
      }
}
