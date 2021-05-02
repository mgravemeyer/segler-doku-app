import Foundation
import UIKit
import Photos
import SwiftUI

class MediaViewModel : ObservableObject {
    
    init() {
        loadServerPDFs()
    }
    
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

    func decoderPDFs(jsonData : Foundation.Data) -> [ResponsePDF]? {
        let decoder = JSONDecoder()
        do {
            let tempPDFs = try decoder.decode(ResponsePDFs.self, from: jsonData)
//            pdfsToSearchOnServer = tempPDFs.pdfs
            return tempPDFs.pdfs
        } catch {
            //to:do error handling
        }
        return nil
    }
    
    func getLocalSavedPDFs() {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
                print("error while saving or finding files")
                return
            }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for url in fileURLs {
                try archive.append(PDF(name: "\((url.lastPathComponent).dropLast(4))", data: Data(contentsOf: url)))
            }
            print(fileURLs)
        } catch {
            print("erroror")
            print(error.localizedDescription)
        }
    }
    
    func loadJSON() {
        getLocalSavedPDFs()
        
    }
    
    func loadServerPDFs() {
        for pdf in decoderPDFs(jsonData: NetworkDataManager.shared.config!)! {
            let pdf = NetworkDataManager.shared.loadPDF(name: pdf.name, filename: pdf.datei)
            pdfs.append(PDF(name: pdf.name, data: pdf.data))
        }
    }
    
    func returnVideoCount() -> Int {
        
        var count = 0
        
        for video in videos {
            if video.selected {
                count += 1
            }
        }
        
        count += videosCamera.count
        
        return count
    }
    
    var highestOrderNumber = 0
    
    @Published private(set) var pdfNameList = [String]()
    
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
    @Published var imagesIsOk = true
    @Published var showImagePickerNew = false
    
    @Published var pdfsToSearchOnServer = [ResponsePDF]()
    @Published var archive = [PDF]()
    @Published var savedPDF = PDF(name: "", data: Data())
    @Published var pdfs = [PDF]()
    @Published var selectedPDF = PDF(name: "", data: Data())
    
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
    
    func loadLocalPDFNames() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: url!, includingPropertiesForKeys: nil)
            for url in urls {
                print(url.lastPathComponent)
                pdfNameList.append(url.lastPathComponent)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addPDF(name: String) {
        self.pdfNameList.append(name)
    }
    
    func deletePDFFileManager(selection: String) {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            print("error while finding file")
            return
        }
        let fileURL = url.appendingPathComponent("\(selection)")
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}
