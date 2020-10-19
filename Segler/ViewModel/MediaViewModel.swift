import Foundation
import UIKit

class MediaViewModel : ObservableObject {
    @Published var images : [ImageModel] = [ImageModel]()
    @Published var image : UIImage?
    @Published var sourceType: Int = 0
    @Published var showImagePicker: Bool = false
    @Published var askForCameraOrGallery: Bool = false
    @Published var showImageScanner : Bool = false
    @Published var loginShowImageScannner : Bool = false
    @Published var imagesIsOk = true
}

struct ImageModel: Identifiable, Hashable {
    var id = UUID()
    var image: UIImage
}
