import Foundation

struct ResponseComments: Codable {
  var comments: [Comment]
  enum CodingKeys: String, CodingKey {
    case response = "Einstellungen"
    case commentsArray = "Guiparameter"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let response = try container.nestedContainer(keyedBy:
    CodingKeys.self, forKey: .response)
    
    self.comments = try response.decode([Comment].self, forKey: .commentsArray)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    var response = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
    try response.encode(self.comments, forKey: .commentsArray)
   }
}

struct Comment: Encodable, Decodable, Identifiable {
    var id = UUID()
    var title : String
    var comments : [String]
    private enum Keys: String, CodingKey {
        case title = "Bereich"
        case comments = "Meldungstyp"
    }
    
      init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: Keys.self)

            title = try values.decodeIfPresent(String.self, forKey: .title)!
            comments = try values.decodeIfPresent([String].self, forKey: .comments)!
    //        title = try commentsArray.decodeIfPresent(String.self, forKey: .title)!
    //        comments = try commentsArray.decodeIfPresent([String].self, forKey: .comments)!
        }
}

//struct CommentsArray: Decodable {
//    var comments : [Comment]
//
//    private enum Keys: String, CodingKey {
//        case response = "Response"
//        case commentsArray = "commentsArray"
//        case title = "title"
//        case comments = "comments"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: Keys.self)
//        let response = try values.nestedContainer(keyedBy: Keys.self, forKey: .response)
//        comments = try response.decodeIfPresent([Comment].self, forKey: .commentsArray)!
//        print(comments)
////        title = try commentsArray.decodeIfPresent(String.self, forKey: .title)!
////        comments = try commentsArray.decodeIfPresent([String].self, forKey: .comments)!
//    }
//}

//struct Response: Decodable {
//    var commentsArray: [Comment]
//
//    init(from decoder: Decoder) {
//        let container = try! decoder.container(keyedBy: ResponseCodingKeys.self)
//        let response = try! container.nestedContainer(keyedBy: ListCodingKeys.self, forKey: .response)
//        commentsArray = try! response.decode([Comment].self, forKey: .commentsArray)
//    }
//
//    enum ResponseCodingKeys: String, CodingKey { case response = "Response" }
//    enum ListCodingKeys: String, CodingKey { case commentsArray }
//}
//
//struct Comment: Decodable {
//    var id = UUID()
//    var title: String
//    var comments: [String]
//}
