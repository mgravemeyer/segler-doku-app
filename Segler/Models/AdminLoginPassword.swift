import Foundation

struct AdminLoginPassword: Decodable, Identifiable {
    
    var id = UUID()
    var password : String
    
    private enum Keys: String, CodingKey {
        case response = "Einstellungen"
        case adminPassword = "Passwort"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let response = try container.nestedContainer(keyedBy: Keys.self, forKey: .response)
        password = try response.decodeIfPresent(String.self, forKey: .adminPassword)!
        print("PASSWORD: \(password)")
    }
}
