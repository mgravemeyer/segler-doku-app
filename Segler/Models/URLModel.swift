import Foundation

struct URLModel: Decodable, Identifiable {
    
    var id = UUID()
    var url : String
    
    private enum Keys: String, CodingKey {
        case response = "Einstellungen"
        case url = "URL"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let response = try container.nestedContainer(keyedBy: Keys.self, forKey: .response)
        url = try response.decodeIfPresent(String.self, forKey: .url)!
    }
}
