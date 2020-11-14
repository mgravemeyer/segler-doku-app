import Foundation

struct MediaQualityModel: Decodable, Identifiable {
    
    var id = UUID()
    var Qp_iPhone : String
    var Qv_iPhone : String
    var Qp_iPod : String
    var Qv_iPod : String
    var Qp_iPad : String
    var Qv_iPad : String
    
    private enum Keys: String, CodingKey {
        
        case response = "Einstellungen"
        
        case responseNested = "Medienqualitaet"
        
        case Qp_iPhone = "Qp_iPhone"
        case Qv_iPhone = "Qv_iPhone"
        case Qp_iPod = "Qp_iPod"
        case Qv_iPod = "Qv_iPod"
        case Qp_iPad = "Qp_iPad"
        case Qv_iPad = "Qv_iPad"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let response = try container.nestedContainer(keyedBy: Keys.self, forKey: .response)
        let responseNested = try response.nestedContainer(keyedBy: Keys.self, forKey: .responseNested)

        print(container)
        print(response)
        
        Qp_iPhone = try responseNested.decodeIfPresent(String.self, forKey: .Qp_iPhone)!
        Qv_iPhone = try responseNested.decodeIfPresent(String.self, forKey: .Qv_iPhone)!
        Qp_iPod = try responseNested.decodeIfPresent(String.self, forKey: .Qp_iPod)!
        Qv_iPod = try responseNested.decodeIfPresent(String.self, forKey: .Qv_iPod)!
        Qp_iPad = try responseNested.decodeIfPresent(String.self, forKey: .Qp_iPad)!
        Qv_iPad = try responseNested.decodeIfPresent(String.self, forKey: .Qv_iPad)!
        
        print("\(Qp_iPhone) \(Qv_iPhone) \(Qp_iPod) \(Qv_iPod) \(Qp_iPad) \(Qv_iPad)")
    }
}

