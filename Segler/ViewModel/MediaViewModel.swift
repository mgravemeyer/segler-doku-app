import Foundation
import UIKit
import Photos

struct VideoModel: Identifiable, Hashable {
    let id = UUID()
    var selected = false
    var assetURL: URL
    var thumbnail: UIImage
    
    func fetchVideo() -> Data {
            let video = try? NSData(contentsOf: assetURL, options: .mappedIfSafe)
            return video! as Data
    }
}

struct ImageModel: Identifiable, Hashable {
    let id = UUID()
    var selected = false
    var assetURL: URL
    var thumbnail: UIImage
    
    func fetchImage() -> Data {
            let photo = try? NSData(contentsOf: assetURL, options: .mappedIfSafe)
            return photo! as Data
    }
}

struct ImageModelCamera: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage
}

struct VideoModelCamera: Identifiable, Hashable {
    let id = UUID()
    var video: Data
    var thumbnail: UIImage
}

class MediaViewModel : ObservableObject {
    
    @Published var imagesCamera = [ImageModelCamera]()
    @Published var videosCamera = [VideoModelCamera]()
    
    @Published var images : [ImageModel] = [ImageModel]()
    @Published var videos: [VideoModel] = [VideoModel]()
    
    @Published var image : UIImage?
    @Published var sourceType: Int = 0
    @Published var showImagePicker: Bool = false
    @Published var askForCameraOrGallery: Bool = false
    @Published var showImageScanner : Bool = false
    @Published var loginShowImageScannner : Bool = false
    @Published var imagesIsOk = true
    @Published var showImagePickerNew = false
    
    func toggleElement(elementId: UUID) {
        let index = images.firstIndex(where: { $0.id == elementId })
        images[index!].selected.toggle()
    }
    
    func toggleVideoElement(elementId: UUID) {
        let index = videos.firstIndex(where: { $0.id == elementId })
        videos[index!].selected.toggle()
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                thumbnail = result!
        })
        return thumbnail
    }
    
    func fetchImages() {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20
        let reqImage = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let reqVideo = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        DispatchQueue.main.async {
//        DispatchQueue.global(qos: .background).async {
            
//            reqImage.enumerateObjects { (asset, _, _) in
//                let options = PHImageRequestOptions()
//                options.isSynchronous  = true
//                PHCachingImageManager.default().requestImage(for: asset, targetSize: .init(), contentMode: .default, options: options) { (image, _) in
//                    if image != nil {
//                        print(image!)
//                        self.images.append(ImageModel(image: image!, type: "image"))
//                    }
//                }
//            }
            
            reqImage.enumerateObjects { (phAsset, _, _) in
                let options = PHImageRequestOptions()
                options.isSynchronous  = true
                
                phAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                  if let input = eidtingInput, let imgURL = input.fullSizeImageURL {
                    self.images.append(ImageModel(assetURL: imgURL, thumbnail: self.getAssetThumbnail(asset: phAsset)))
                  }
                }
                
//                PHCachingImageManager.default().requestImage(for: phAsset, targetSize: .init(), contentMode: .default, options: options) { (asset, _) in
//                    self.images.append(ImageModel(assetURL: asset?.imageAsset., thumbnail: self.getAssetThumbnail(asset: phAsset)))
//                }
            }
            
            reqVideo.enumerateObjects { (phAsset, _, _) in
                let options = PHImageRequestOptions()
                options.isSynchronous  = true
                
                PHCachingImageManager.default().requestAVAsset(forVideo: phAsset, options: nil) {(asset, audioMix, info) in
                    if let asset = asset as? AVURLAsset {
                        self.videos.append(VideoModel(assetURL: asset.url, thumbnail: self.getAssetThumbnail(asset: phAsset)))
                    }
                }
            }
            
        }
    }
}
