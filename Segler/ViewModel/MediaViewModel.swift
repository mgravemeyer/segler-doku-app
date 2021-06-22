import Foundation
import UIKit
import Photos
import SwiftUI

class MediaViewModel : ObservableObject {

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
    
    func loadArchivePDFs() {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
                print("error while saving or finding files")
                return
            }
        do {
            var fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                
                print(file)
                
                var pdfName = String()
                var found = false
                
                for c in file.lastPathComponent.reversed() {
                    if c == "+" {
                        print("FOUND: \(pdfName)")
                        found = true
                        break
                    } else {
                        pdfName.append(c)
                    }
                }
                
                if !found {
                    pdfName = ""
                }
                
                var fileString = Substring()
                
                if !found {
                    fileString = file.lastPathComponent.dropLast(4)
                } else {
                    fileString = file.lastPathComponent.dropLast(5 + (pdfName.count))
                }
                
//                var start = Substring.Index(encodedOffset: 0)
//                var end = Substring.Index(encodedOffset: 0)
                
                var finalString = Substring()
                
                finalString = fileString.dropFirst(9)

//                let range = start..<end
                let dateAndTimeAsString = finalString
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = .current
                dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
                let dateAndTime = dateFormatter.date(from: String(dateAndTimeAsString))
                
//                if dateAndTime != nil {
                if dateAndTime != nil {
                    if found {

                    archive.append(PDF(name: String(fileString), data: try Data(contentsOf: file), time: dateAndTime, isArchive: true, pdfName: String(pdfName.reversed())))
                    } else {
                        archive.append(PDF(name: String(fileString), data: try Data(contentsOf: file), time: dateAndTime, isArchive: true, pdfName: "Nicht erkannt"))
                    }
                }
//                }
                pdfName = ""
            }
            
            archive = archive.sorted(by: { $0.time!.compare($1.time!) == .orderedDescending })
            
            if fileURLs.count > 20 {
                for i in 0...(fileURLs.count - 21) {
                    try FileManager.default.removeItem(at: fileURLs[i])
                }
            }
        } catch {
            print("erroror")
            print(error.localizedDescription)
        }
    }
    
    func loadPDFs() {
        loadArchivePDFs()
        loadServerPDFs()
    }
    
    func loadServerPDFs() {
        for pdf in decoderPDFs(jsonData: NetworkDataManager.shared.config!)! {
            let pdf = NetworkDataManager.shared.loadPDF(name: pdf.name, filename: pdf.datei)
            pdfs.append(PDF(name: pdf.name, data: pdf.data, isArchive: false))
        }
    }
    
    func returnActiveMediaCount() -> Int {
        return returnVideoCount() + returnImageCount()
    }
    
    func returnImageCount() -> Int {
        var count = 0
        for image in images {
            if image.selected {
                count += 1
            }
        }
        count += imagesCamera.count
        return count
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
    
    func getNumberOfMedia() -> Int {
        return imagesCamera.count + videosCamera.count + images.count + videos.count
    }
    
    func getNumberOfMediaWithPDF() -> Int {
        
        var pdfSelected = 0
        
        if savedPDF.name != "" {
            pdfSelected = 1
        }
        
        print("pdf \(savedPDF.name) img \(returnImageCount()) video \(returnVideoCount()) pdf \(pdfSelected)")
        
        
        return returnImageCount() + returnVideoCount() + pdfSelected
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
    @Published var savedPDF = PDF(name: "", data: Data(), isArchive: false)
    @Published var pdfs = [PDF]()
    @Published var selectedPDF = PDF(name: "", data: Data(), isArchive: false)
    
    @Published var qualityPicture = NSNumber()
    @Published var qualityVideo = NSNumber()
    
    @Published var lastTransmitNotSuccessfull = false
    
    @Published var transmitCount = 0
    
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
    
    func loadQuality() {
        let decoder = JSONDecoder()
        do {
            let mediaQualityModel = try decoder.decode(MediaQualityModel.self, from: NetworkDataManager.shared.config!)
            
            if UIDevice.current.name.contains("iPhone") {
                qualityPicture = NSNumber(value: Double(mediaQualityModel.Qp_iPhone)!)
                qualityVideo = NSNumber(value: Double(mediaQualityModel.Qv_iPhone)!)
            } else
            if UIDevice.current.name.contains("iPod touch") {
                qualityPicture = NSNumber(value: Double(mediaQualityModel.Qp_iPod)!)
                qualityVideo = NSNumber(value: Double(mediaQualityModel.Qv_iPod)!)
            } else
            
            if UIDevice.current.name.contains("iPad") {
                qualityPicture = NSNumber(value: Double(mediaQualityModel.Qp_iPad)!)
                qualityVideo = NSNumber(value: Double(mediaQualityModel.Qv_iPad)!)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
