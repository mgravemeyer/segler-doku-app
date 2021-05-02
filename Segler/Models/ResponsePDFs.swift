import Foundation

struct ResponsePDFs: Codable {
  var pdfs: [ResponsePDF]
  enum CodingKeys: String, CodingKey {
    case response = "Einstellungen"
    case pdfsArray = "Protokolle"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let response = try container.nestedContainer(keyedBy:
    CodingKeys.self, forKey: .response)
    
    self.pdfs = try response.decode([ResponsePDF].self, forKey: .pdfsArray)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    var response = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
    try response.encode(self.pdfs, forKey: .pdfsArray)
   }
}
