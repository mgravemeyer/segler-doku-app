//import Foundation
//
//func downloadJSON(_ urlString: String, completed: @escaping (_ fetchedComments : [Comment]) -> Void) {
//    let url = URL(string: urlString)
//
//    var comments = [Comment]()
//
//    URLSession.shared.dataTask(with: url!) { (data, response, error) in
//        if error == nil {
//            do{
//                comments = try JSONDecoder().decode([Comment].self, from: data!)
//                DispatchQueue.main.async{
//                    completed(comments)
//                }
//            } catch {
//                print("JSON Error")
//                print(error.localizedDescription)
//            }}
//        }.resume()
//}
