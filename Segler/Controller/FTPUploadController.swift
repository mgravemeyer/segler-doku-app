import Foundation
import CFNetwork
import ProgressHUD
import NMSSH
import Combine
import SwiftUI
import AVKit

extension Dictionary {
    init(_ keyValuePairs: [(Key, Value)]) {
        self.init(minimumCapacity: keyValuePairs.count)

        for (key, value) in keyValuePairs {
            self[key] = value
        }
    }
}

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}

struct FTPUploadController {
    
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var mediaVM: MediaViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    func createJSON(bereich: String, meldungstyp: String, freitext: String, user: String) -> Data? {
        
        let keyValuePairs = [
            ("Bereich", "\(bereich)"),
            ("Meldungstyp", "\(meldungstyp)"),
            ("Freitext", "\(freitext)"),
            ("User", "\(user)"),
            ("AppVersion", Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String),
            ("Geraet", UIDevice.current.name)
        ]
        
        let dict = Dictionary(keyValuePairs)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
                return jsonData as Data
        } catch _ {
            return nil
        }
    }

    func authenticate() -> Bool  {
        var bool: Bool = false
        let session = NMSSHSession.init(host: "\(settingsVM.ip)", andUsername: "\(settingsVM.serverUsername)")
        session.connect()
        if session.isConnected {
            session.authenticate(byPassword: "\(settingsVM.serverPassword)")
            if session.isAuthorized {
                bool = true
            }
        } else {
            ProgressHUD.showError(" ")
            bool = false
        }
        return bool
    }
    
    class VideoCompress {
        
        @EnvironmentObject var settingsVM: SettingsViewModel
//
//        init() {
//
//            let number = 2000
//
////            if UIDevice.current.name.contains("iPhone") {
////                let number = Int(settingsVM.projectedValue.qv_iPhone.wrappedValue)
////                bitrate = NSNumber(value: number!)
////            } else
////            if UIDevice.current.name.contains("iPod touch") {
////                let number = Int(settingsVM.projectedValue.qv_iPod.wrappedValue)
////                bitrate = NSNumber(value: number!)
////            } else
////            if UIDevice.current.name.contains("iPad") {
////                let number = Int(settingsVM.projectedValue.qv_iPad.wrappedValue)
////                bitrate = NSNumber(value: number!)
////            }
//            bitrate = mediaVM.
//        }
        
        
        
        var bitrate: NSNumber = 50000
        
        func compressFile(urlToCompress: URL, outputURL: URL, completion:@escaping (URL)->Void) {
            
            var assetWriter:AVAssetWriter?
            var assetReader:AVAssetReader?
            
            var audioFinished = false
            var videoFinished = false
            
            let asset = AVAsset(url: urlToCompress);

            do{
                assetReader = try AVAssetReader(asset: asset)
            } catch {
                assetReader = nil
            }
            
            guard let reader = assetReader else {
                fatalError("Could not initalize asset reader probably failed its try catch")
            }
            
            let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
            let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
            
            let videoReaderSettings: [String:Any] =  [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32ARGB ]
                // ADJUST BIT RATE OF VIDEO HERE
                let videoSettings:[String:Any] = [
                    AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:self.bitrate],
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoHeightKey: videoTrack.naturalSize.height,
                    AVVideoWidthKey: videoTrack.naturalSize.width
                ]
            
            let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader.canAdd(assetReaderVideoOutput){
                reader.add(assetReaderVideoOutput)
            }else{
                fatalError("Couldn't add video output reader")
            }
            if reader.canAdd(assetReaderAudioOutput){
                reader.add(assetReaderAudioOutput)
            }else{
                fatalError("Couldn't add audio output reader")
            }
            
            let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
            let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
                 videoInput.transform = videoTrack.preferredTransform
            
            let videoInputQueue = DispatchQueue(label: "videoQueue")
                let audioInputQueue = DispatchQueue(label: "audioQueue")
                do {
                    assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
                } catch {
                    assetWriter = nil
                }
                guard let writer = assetWriter else {
                    fatalError("assetWriter was nil")
                }
            
            writer.shouldOptimizeForNetworkUse = false
                writer.add(videoInput)
                writer.add(audioInput)
                writer.startWriting()
                reader.startReading()
            writer.startSession(atSourceTime: CMTime.zero)
            
            let closeWriter:()->Void = {
                if (audioFinished && videoFinished) {
                    assetWriter?.finishWriting(completionHandler: {
                        completion((assetWriter?.outputURL)!)
                    })
                    assetReader?.cancelReading()
                } else {
                    print("NOT FINISHED STOP")
                }
            }
            
            audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
                while(audioInput.isReadyForMoreMediaData){
                    let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                    if (sample != nil){
                        audioInput.append(sample!)
                    }else{
                        audioInput.markAsFinished()
                        DispatchQueue.main.async {
                            audioFinished = true
                            closeWriter()
                        }
                        break;
                    }
                }
            }
            videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
                //request data here
                while(videoInput.isReadyForMoreMediaData){
                    let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                    if (sample != nil){
                        videoInput.append(sample!)
                    }else{
                        videoInput.markAsFinished()
                        DispatchQueue.main.async {
                            videoFinished = true
                            closeWriter()
                        }
                        break;
                    }
                }
            }
        }
    }
    
    func someAsyncFunction(_ shouldThrow: Bool, completion: @escaping(String?) -> ()) {
        
        var remarksVM = RemarksViewModel()
        
//        print(settingsVM.savedPDF)
        
        var finishedPhotoArray = [Data]()
        var finishedVideoArray = [Data]()
        
        var errorMessage = "Fehler: \n"
        var error = false
        
        var orderNrCheck = false
        var orderPositionCheck = false
        
//        var imagesCheck = false
//        var commentCheck = false
        
        var jsonObject = Data()
        
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        let convertedDate = dateFormatter.string(from: date)
        
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HHmmss"
        let convertedDateTime = dateFormatter.string(from: date)

        ProgressHUD.show()
        
        let session = NMSSHSession.init(host: "\(self.settingsVM.ip)", andUsername: "\(self.settingsVM.serverUsername)")
        session.connect()
        session.authenticate(byPassword: "\(self.settingsVM.serverPassword)")

                //CHECK orderNr for Valid Numbers
                for char in self.orderViewModel.orderNr {
                    if char.isNumber {
                        orderNrCheck = true
//                        self.orderViewModel.orderNrIsOk = true
                    } else {
                        orderNrCheck = false
//                        self.orderViewModel.orderNrIsOk = false
                        break
                    }
                }
                
                if self.orderViewModel.orderNrIsOk && self.orderViewModel.orderNr.count == 5 {
                    orderNrCheck = true
//                    self.orderViewModel.orderNrIsOk = true
                } else {
                    orderNrCheck = false
//                    self.orderViewModel.orderNrIsOk = false
                }
                
                if self.orderViewModel.orderPositionIsOk && self.orderViewModel.orderPosition.count == 3 || self.orderViewModel.orderPosition.count == 2 || self.orderViewModel.orderPosition.count == 1 {
                    for char in self.orderViewModel.orderPosition {
                        if char.isNumber {
//                            self.orderViewModel.orderPositionIsOk = true
                            orderPositionCheck = true
                        } else {
//                            self.orderViewModel.orderPositionIsOk = false
                            orderPositionCheck = false
                            break
                        }
                    }
                } else {
                    orderPositionCheck = false
//                    self.orderViewModel.orderPositionIsOk = false
                }
                
                if remarksVM.selectedComment == "" && mediaVM.savedPDF.name == ""  {
                    error = true
//                    commentCheck = false
//                    remarksVM.commentIsOk = false
                    errorMessage = errorMessage + "Kein Kommentar ausgewählt! \n"
                }
//                else {
////                    commentCheck = true
////                    remarksVM.commentIsOk = true
//                }
                
                if !orderNrCheck {
                    error = true
                    orderNrCheck = false
//                    self.orderViewModel.orderNrIsOk = false
                    errorMessage = errorMessage + "Keine/Falsche Auftrags-Nr! \n"
                } else {
                    orderNrCheck = true
//                    self.orderViewModel.orderNrIsOk = true
                }
                
                if !orderPositionCheck {
                    error = true
//                    self.orderViewModel.orderPositionIsOk = false
                    orderPositionCheck = false
                    errorMessage = errorMessage + "Keine/Falsche Positions-Nr! \n"
                } else {
                    orderPositionCheck = true
//                    self.orderViewModel.orderPositionIsOk = true
                }
                    
//                for image in mediaVM.images {
//                    if image.selected {
//                        let image = UIImage(data: image.fetchImage())
//                        if UIDevice.current.name.contains("iPhone") {
//                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPhone.floatValue)))!)
//                        } else
//                        if UIDevice.current.name.contains("iPod touch") {
//                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPod.floatValue)))!)
//                        } else
//                        if UIDevice.current.name.contains("iPad") {
//                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPad.floatValue)))!)
//                        } else {
//                            finishedPhotoArray.append((image?.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPod.floatValue)))!)
//                        }
//                    }
//                }
//            
//                for image in mediaVM.imagesCamera {
//                    if UIDevice.current.name.contains("iPhone") {
//                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPhone.floatValue)))!)
//                    } else
//                    if UIDevice.current.name.contains("iPod touch") {
//                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPod.floatValue)))!)
//                    } else
//                    if UIDevice.current.name.contains("iPad") {
//                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPad.floatValue)))!)
//                    } else {
//                        finishedPhotoArray.append((image.image.jpegData(compressionQuality: CGFloat(settingsVM.qp_iPod.floatValue)))!)
//                    }
//                }
                
                let group = DispatchGroup()
        
                let videoCompress = VideoCompress()
                
                for video in mediaVM.videosCamera {
                    group.enter()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                    let date = Date()
                    let documentsPath = NSTemporaryDirectory()
                    let outputPath = "\(documentsPath)/\(formatter.string(from: date))\(video.id).mp4"
                    let newOutputUrl = URL(fileURLWithPath: outputPath)
                    var videoData = Data()
                    videoCompress.compressFile(urlToCompress: video.url, outputURL: newOutputUrl) { (URL) in
                        videoData = try! NSData(contentsOf: newOutputUrl, options: .mappedIfSafe) as Data
                        finishedVideoArray.append(videoData as Data)
                        group.leave()
                    }
                }

                for video in mediaVM.videos {
                    if video.selected {
                        print(video)
                        group.enter()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                        let date = Date()
                        let documentsPath = NSTemporaryDirectory()
                        let outputPath = "\(documentsPath)/\(formatter.string(from: date))\(video.id).mp4"
                        print(outputPath)
                        let newOutputUrl = URL(fileURLWithPath: outputPath)
                        print(newOutputUrl)
                        var videoData = Data()
                        print("VIDEO DATA: \(video.fetchVideo())")
                        Thread.printCurrent()
                        videoCompress.compressFile(urlToCompress: video.assetURL, outputURL: newOutputUrl) { (URL) in
                            videoData = try! NSData(contentsOf: newOutputUrl, options: .mappedIfSafe) as Data
                            finishedVideoArray.append(videoData as Data)
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    
                    if finishedPhotoArray.isEmpty && finishedVideoArray.isEmpty && mediaVM.savedPDF.name == "" {
                    error = true
//                    imagesCheck = false
                    errorMessage = errorMessage + "Kein Bild/Video ausgewählt! \n"
                }
//                else {
//                    imagesCheck = true
////                    self.mediaVM.imagesIsOk = true
//                }
                
                if error {
                    completion(errorMessage)
                }
                        
                    //setting up json file
                    if self.settingsVM.useFixedUser {
                        if mediaVM.savedPDF.name != "" {
                            jsonObject = self.createJSON(bereich: "Protokoll", meldungstyp: String(mediaVM.savedPDF.name), freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                        } else {
                            jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.settingsVM.userUsername)!
                        }
                    } else {
                        if mediaVM.savedPDF.name != "" {
                            jsonObject = self.createJSON(bereich: "Protokoll", meldungstyp: String(mediaVM.savedPDF.name), freitext: remarksVM.additionalComment, user: self.userVM.username)!
                        } else {
                            jsonObject = self.createJSON(bereich: "\(remarksVM.bereich)", meldungstyp: "\(remarksVM.selectedComment)", freitext: remarksVM.additionalComment, user: self.userVM.username)!
                        }
                    }
            
            DispatchQueue.main.async {
            let sftpsession = NMSFTP(session : session)
            sftpsession.connect()
                print("CONNECTION ESTABLISHED!")
                if sftpsession.isConnected && !error {
                        
                    var counter = 0

//                    if !finishedPhotoArray.isEmpty {
//                        print("IF SCHLEIFE IST OK")
//                        print("TRANSFERDATA: \(finishedPhotoArray)")
                        for photoData in finishedPhotoArray {
                            sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").json")
                            sftpsession.writeContents(photoData, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").jpg")
                            counter += 1
                        }
//                    }
                    if !finishedVideoArray.isEmpty {
                        for videoData in finishedVideoArray {
                            sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").json")
                            sftpsession.writeContents(videoData, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").mp4")
                            counter += 1
                        }
                    }
                    
                    print(mediaVM.savedPDF)
                    
                    if mediaVM.savedPDF.name != "" {
                        print(mediaVM.savedPDF.data)
                        print("SENT!")
                        sftpsession.writeContents(jsonObject, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").json")
                        sftpsession.writeContents(mediaVM.savedPDF.data, toFileAtPath: "\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").pdf")
                        
                        guard
                            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                        else {
                                print("error while saving or finding files")
                                return
                            }
                        let fileURL = url.appendingPathComponent("\("\(self.orderViewModel.orderNr)_\(self.orderViewModel.orderPosition)_\(convertedDate)_\(convertedDateTime)_\(counter)").pdf")
                        do {
                            try mediaVM.savedPDF.data.write(to: fileURL)
                        } catch {
                            print(error.localizedDescription)
                        }
                        counter += 1
                    }
                    
                    mediaVM.selectedPhotoAmount = 0
                    mediaVM.selectedVideoAmount = 0
                    completion(nil)
                } else {
                    print("ERROR ÜBERTRAGUNG")
                }
            }
            }
        
    }
}
