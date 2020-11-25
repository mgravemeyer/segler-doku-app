import Foundation
import UIKit
import Photos
import SwiftUI

struct VideoModel: Identifiable, Hashable {
    let id = UUID()
    var selected = false
    var assetURL: URL
    var thumbnail: UIImage
    var order: Int
    var orientation: String
    
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
    var order: Int
    var orientation: String
    
    func fetchImage() -> Data {
            let photo = try? NSData(contentsOf: assetURL, options: .mappedIfSafe)
            return photo! as Data
    }
}

struct ImageModelCamera: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage
    var order: Int
    var orientation: String
}

struct VideoModelCamera: Identifiable, Hashable {
    let id = UUID()
    var url: URL
    var video: Data
    var thumbnail: UIImage
    var order: Int
    var orientation: String
}

class MediaViewModel : ObservableObject {
    
    var highestOrderNumber = 0
    
    @Published var showVideo: Bool = false
    @Published var showImage: Bool = false
    
    @Published var selectedImage: UIImage?
    @Published var selectedVideo: URL?
    
    func getOrderNumber() -> Int {
        highestOrderNumber += 1
        return highestOrderNumber
    }
    
    func getNumberOfImages() -> Int {
        return imagesCamera.count + videosCamera.count + images.count + videos.count
    }
    
    @Published var selectedPhotoAmount = 0
    @Published var selectedVideoAmount = 0
    
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
        images[index!].order = getOrderNumber()
    }
    
    func toggleVideoElement(elementId: UUID) {
        let index = videos.firstIndex(where: { $0.id == elementId })
        videos[index!].selected.toggle()
        videos[index!].order = getOrderNumber()
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
    
    func fetchMedia() {
        
        let fetchOptionsPhoto = PHFetchOptions()
        fetchOptionsPhoto.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptionsPhoto.fetchLimit = 12 + selectedPhotoAmount
        
        let fetchOptionsVideo = PHFetchOptions()
        fetchOptionsVideo.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptionsVideo.fetchLimit = 12 + selectedVideoAmount
        
        let reqImage = PHAsset.fetchAssets(with: .image, options: fetchOptionsPhoto)
        let reqVideo = PHAsset.fetchAssets(with: .video, options: fetchOptionsVideo)

            reqImage.enumerateObjects { (phAsset, _, _) in
                let options = PHImageRequestOptions()
                options.isSynchronous  = true
                
                phAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                  if let input = eidtingInput, let imgURL = input.fullSizeImageURL {
                    
                    var isAlreadyInArray = false
                    
                    for image in self.images {
                        if image.assetURL == imgURL {
                            isAlreadyInArray = true
                        }
                    }
                    
                    if !isAlreadyInArray {
                        self.images.append(ImageModel(assetURL: imgURL, thumbnail: self.getAssetThumbnail(asset: phAsset), order: self.getOrderNumber(), orientation: "horizontal"))
                    }
                  }
                }
                
            reqVideo.enumerateObjects { (phAsset, _, _) in
                let options = PHImageRequestOptions()
                options.isSynchronous  = true
                
                PHCachingImageManager.default().requestAVAsset(forVideo: phAsset, options: nil) {(asset, audioMix, info) in
                    if let asset = asset as? AVURLAsset {
                        
                        var isAlreadyInArray = false
                        
                        for video in self.videos {
                            if video.assetURL == asset.url {
                                isAlreadyInArray = true
                            }
                        }
                        
                        if !isAlreadyInArray {
                            self.videos.append(VideoModel(assetURL: asset.url, thumbnail: self.getAssetThumbnail(asset: phAsset), order: self.getOrderNumber(), orientation: "horizontal"))
                        }
                    }
                }
            }
        }
    }
}
