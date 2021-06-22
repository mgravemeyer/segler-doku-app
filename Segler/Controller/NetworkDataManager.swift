import Foundation
import NMSSH
import ProgressHUD
import AVKit
import SwiftUI

//to:do handles currently network stuff and also perparing data to be send. could be later splitted up to data and a seperate network manager.
class NetworkDataManager {
    
    var filenameIfNotTransmit = String()
    
    var tmpTransferedImages = [Int]()
    
    var tmpTransferedVideos = [Int]()
    
    var pdfNumber = -1
    
    static let shared = NetworkDataManager()
    
    var config: Data?
    var protokolle: [NMSFTPFile]?
    
    var session: NMSFTP?
    
    func connect(host: String, username: String, password: String, isInit: Bool) -> Bool {
        if (session != nil) {
            if session!.isConnected {
                session!.disconnect()
            }
        }
        let connection = NMSSHSession.init(host: host, andUsername: username)
        connection.connect()
        if connection.isConnected {
            connection.authenticate(byPassword: password)
            if connection.isAuthorized {
                self.session = NMSFTP(session: connection)
                self.session!.connect()
                if isInit {
                    config = self.session!.contents(atPath: "config/config.json")
                    protokolle = self.session!.contentsOfDirectory(atPath: "protokolle")!
                }
                return true
            } else { return false }
        } else { return false }
    }
    
    func sendToFTP(settingsVM: SettingsViewModel, mediaVM: MediaViewModel, userVM: UserViewModel, orderVM: OrderViewModel, remarksVM: RemarksViewModel, _ shouldThrow: Bool, completion: @escaping(String?) -> ()) {

        if !checkIfDataIsCorrect(mediaVM: mediaVM, orderVM: orderVM, remarksVM: remarksVM) {
            if filenameIfNotTransmit == "" {
                filenameIfNotTransmit = generateDataName(orderVM: orderVM)
            }
            var json = Data()
            if mediaVM.savedPDF.name != "" {
                json = generatePDFJSON(userVM: userVM, remarksVM: remarksVM, mediaVM: mediaVM)!
            } else {
                json = generateJSON(userVM: userVM, remarksVM: remarksVM)!
            }
            ProgressHUD.show()
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                
                var conError: String?
                
                if self.connect(host: settingsVM.ip, username: settingsVM.serverUsername, password: settingsVM.serverPassword, isInit: false) {
                    
                    print("hier con")
                    
                    if !self.sendPhotos(data: self.prepImagesData(mediaVM: mediaVM), json: json) {
                        conError = "conError"
                    }
                    print("go to next step")
                    if !self.sendVideos(data: self.prepVideosData(mediaVM: mediaVM), json: json) {
                        conError = "conError"
                    }
                    if mediaVM.savedPDF.name != "" {
                        if (!self.sendPDF(isArchive: mediaVM.savedPDF.isArchive , archiveName: mediaVM.savedPDF.pdfName ,mediaVM: mediaVM, pdfData: mediaVM.savedPDF.data, jsonData: json)) {
                            conError = "conError"
                        }
                    }
                    ProgressHUD.show()
                    
                    print("tmpImages\(tmpTransferedImages) tmpVideos\(tmpTransferedVideos) \(counter)")
                    
                    if self.tmpTransferedImages.count > 0 {
                        for count in self.tmpTransferedImages {
                            if self.session!.fileExists(atPath: "\(filenameIfNotTransmit)_\(count).jpg") {
                                self.session!.removeFile(atPath: "\(filenameIfNotTransmit)_\(count).jpg")
                            }
                            if !self.session!.moveItem(atPath: "tmp_upload/\(filenameIfNotTransmit)_\(count).jpg", toPath: "\(filenameIfNotTransmit)_\(count).jpg") {
                                conError = "conError"
                            }
                            
                        }
                    }
                    
                    if self.tmpTransferedVideos.count > 0 {
                        for count in self.tmpTransferedVideos {
                            print("MOVE VIDEO")
                            if self.session!.fileExists(atPath: "\(filenameIfNotTransmit)_\(count).mp4") {
                                self.session!.removeFile(atPath: "\(filenameIfNotTransmit)_\(count).mp4")
                            }
                            if !self.session!.moveItem(atPath: "tmp_upload/\(filenameIfNotTransmit)_\(count).mp4", toPath: "\(filenameIfNotTransmit)_\(count).mp4") {
                                print("tmp_upload/\(filenameIfNotTransmit)_\(count).mp4")
                                print("\(filenameIfNotTransmit)_\(count).mp4")
                                print("ERROR")
                                conError = "conError"
                            }
                        }
                    }
                    
                    if (pdfNumber > -1) {
                        if !self.session!.moveItem(atPath: "tmp_upload/\(filenameIfNotTransmit)_\(pdfNumber).pdf", toPath: "\(filenameIfNotTransmit)_\(pdfNumber).pdf") {
                            conError = "conError"
                        }
                    }
                    
                    for count in (0...counter - 1) {
                        if !self.session!.moveItem(atPath: "tmp_upload/\(filenameIfNotTransmit)_\(count).json", toPath: "\(filenameIfNotTransmit)_\(count).json") {
                            conError = "conError"
                        }
                    }
                    
                    self.pdfNumber = -1
                    self.counter = 0
                    self.tmpTransferedVideos.removeAll()
                    self.tmpTransferedImages.removeAll()
                    if conError == nil {
                        self.filenameIfNotTransmit = ""
                    }
                    completion(conError)
                    
                } else {
                    self.counter = 0
                    self.tmpTransferedVideos.removeAll()
                    self.tmpTransferedImages.removeAll()
                    conError = "conError"
                    completion(conError)
                }
            }
        } else {
            counter = 0
            self.tmpTransferedVideos.removeAll()
            self.tmpTransferedImages.removeAll()
            completion("dataError")
        }
    }
    
    func loadPDF(name: String, filename: String) -> PDF {
        let content = session!.contents(atPath: "protokolle/\(filename).pdf")
        return PDF(name: name, data: content!, isArchive: false)
    }
    
    func checkIfDataIsCorrect(mediaVM: MediaViewModel, orderVM: OrderViewModel, remarksVM: RemarksViewModel) -> Bool {
        
        var error = ""
        
        //check orderNumber
        if (orderVM.orderNr.count == 5) {
            for char in orderVM.orderNr {
                if !char.isNumber {
                    error += "Falsche Auftrags-Nr \n"
                    orderVM.orderNrIsOk = false
                    break
                } else {
                    orderVM.orderNrIsOk = true
                }
            }
        } else {
            error += "Falsche Auftrags-Nr \n"
            orderVM.orderNrIsOk = false
        }
        
        //check orderPosition
        if (orderVM.orderPosition.count > 0 && orderVM.orderPosition.count < 4) {
            for char in orderVM.orderPosition {
                if !char.isNumber {
                    error += "Falsche Positions-Nr \n"
                    orderVM.orderPositionIsOk = false
                    break
                } else {
                    orderVM.orderPositionIsOk = true
                }
            }
        } else {
            print(orderVM.orderPosition)
            error += "Falsche Positions-Nr \n"
            orderVM.orderPositionIsOk = false
        }
        
        if (remarksVM.selectedComment == "" && mediaVM.savedPDF.name == "") {
            error += "Keinen Kommentar ausgewählt \n"
            remarksVM.commentIsOk = false
        } else {
            remarksVM.commentIsOk = true
        }
        
        if !(mediaVM.returnActiveMediaCount() > 0) {
            mediaVM.imagesIsOk = false
            error += "Kein Bild oder Video ausgewählt \n"
        } else {
            mediaVM.imagesIsOk = true
        }
        
        print(error)
        
        if (error == "") {
            ProgressHUD.showError(error)
            return false
        } else {
            return true
        }
        
    }
    
    private func prepImagesData(mediaVM: MediaViewModel) -> [Data] {
        var data = [Data]()
        for image in mediaVM.images {
            print("i: \(image)")
            if image.selected {
                let uIImage = UIImage(data: image.fetchImage())
                data.append((uIImage?.jpegData(compressionQuality: CGFloat(truncating: mediaVM.qualityPicture)))!)
            }
        }
        for image in mediaVM.imagesCamera {
            print("iC: \(image)")
            data.append(image.image.jpegData(compressionQuality: CGFloat(truncating: mediaVM.qualityPicture))!)
        }
        return data
    }
    
    private func prepVideosData(mediaVM: MediaViewModel) -> [Data] {
        var data = [Data]()
        let group = DispatchGroup()
        let documentsPath = NSTemporaryDirectory()
        
        print("prepd video")

        for video in mediaVM.videos {
            if video.selected {
                group.enter()
                let outputURL = URL(fileURLWithPath: "\(documentsPath)\(UUID())\(video.id).mp4")
                compressVideo(urlToCompress: video.assetURL, outputURL: outputURL, mediaVM: mediaVM)  { URL in
                    let videoData = try! NSData(contentsOf: outputURL, options: .mappedIfSafe) as Data
                    data.append(videoData)
                    group.leave()
                }
            }
        }
        group.wait()
        for video in mediaVM.videosCamera {
            group.enter()
            let outputURL = URL(fileURLWithPath: "\(documentsPath)\(UUID())\(video.id).mp4")
            compressVideo(urlToCompress: video.url, outputURL: outputURL, mediaVM: mediaVM)  { URL in
                let videoData = try! NSData(contentsOf: outputURL, options: .mappedIfSafe) as Data
                data.append(videoData)
                group.leave()
            }
        }
        group.wait()
        return data
    }
    
    var counter = 0
    
    private func sendPhotos(data: [Data], json: Data) -> Bool {
        print("ich sende fotos")
        print(data.count)
        if data.count > 0 {
            for (index, photo) in data.enumerated() {
                ProgressHUD.show("Foto \(index+1) von \(data.count)")
                if (!self.session!.writeContents(json, toFileAtPath: "tmp_upload/\(filenameIfNotTransmit)_\(counter).json")) {
                    return false
                }
                if (!self.session!.writeContents(photo, toFileAtPath: "tmp_upload/\(filenameIfNotTransmit)_\(counter).jpg")) {
                    return false
                }
                tmpTransferedImages.append(counter)
                counter += 1
            }
        }
        return true
    }
     
    private func sendVideos(data: [Data], json: Data) -> Bool {
        if data.count > 0 {
            for (index, video) in data.enumerated() {
                ProgressHUD.show("Video \(index+1) von \(data.count)")
                if (!self.session!.writeContents(json, toFileAtPath: "tmp_upload/\(filenameIfNotTransmit)_\(counter).json")) {
                    return false
                }
                if (!self.session!.writeContents(video, toFileAtPath: "tmp_upload/\(filenameIfNotTransmit)_\(counter).mp4")) {
                    return false
                }
                tmpTransferedVideos.append(counter)
                counter += 1
            }
        }
        return true
    }
    
    private func sendPDF(isArchive: Bool, archiveName: String? ,mediaVM: MediaViewModel, pdfData: Data, jsonData: Data) -> Bool {
        ProgressHUD.show("Protokoll wird hochgeladen")
        if (!self.session!.writeContents(jsonData, toFileAtPath: "tmp_upload/\(filenameIfNotTransmit)_\(counter).json")) {
            return false
        }
        if (!self.session!.writeContents(pdfData, toFileAtPath: "tmp_upload/\(filenameIfNotTransmit)_\(counter).pdf")) {
            return false
        } else {
            pdfNumber = counter
        }
        counter += 1
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
                print("error while saving or finding files")
                return false
            }
        
        var fileURL = URL(string: "")
        
        //is archive
        if isArchive {
            if archiveName != nil {
                fileURL = url.appendingPathComponent("\(filenameIfNotTransmit).pdf+\(archiveName!)")
            } else {
                fileURL = url.appendingPathComponent("\(filenameIfNotTransmit).pdf")
            }
            mediaVM.archive.insert(PDF(name: filenameIfNotTransmit, data: pdfData, time: Date(), isArchive: true, pdfName: mediaVM.savedPDF.pdfName), at: 0)
        } else {
            fileURL = url.appendingPathComponent("\(filenameIfNotTransmit).pdf+\(mediaVM.savedPDF.name)")
            print("saved pdf name: \(mediaVM.savedPDF.pdfName)")
            mediaVM.archive.insert(PDF(name: filenameIfNotTransmit, data: pdfData, time: Date(), isArchive: true, pdfName: mediaVM.savedPDF.name), at: 0)
        }
        
        do {
            try pdfData.write(to: fileURL!)
        } catch {
            print(error.localizedDescription)
        }
        return true
    }
    
    private func generateDataName(orderVM: OrderViewModel) -> String {
        return ("\(orderVM.orderNr)_\(orderVM.orderPosition)_\(getDate())_\(getTime())")
    }
    
    private func getDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: currentDate)
    }
    
    private func getTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HHmmss"
        return dateFormatter.string(from: currentDate)
    }
    
    private func generateJSON(userVM: UserViewModel, remarksVM: RemarksViewModel) -> Data? {
        
        let keyValuePairs = [
            ("Bereich", "\(remarksVM.bereich)"),
            ("Meldungstyp", "\(remarksVM.selectedComment)"),
            ("Freitext", "\(remarksVM.additionalComment)"),
            ("User", "\(userVM.username)"),
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
    
    private func generatePDFJSON(userVM: UserViewModel, remarksVM: RemarksViewModel, mediaVM: MediaViewModel) -> Data? {
        
        var keyValuePairs = [
            ("Bereich", ""),
            ("Meldungstyp", ""),
            ("Freitext", ""),
            ("User", ""),
            ("AppVersion", ""),
            ("Geraet", "")
        ]
        
        if mediaVM.savedPDF.isArchive {
            keyValuePairs = [
                ("Bereich", "Protokoll"),
                ("Meldungstyp", "\(mediaVM.savedPDF.pdfName!)"),
                ("Freitext", "\(remarksVM.additionalComment)"),
                ("User", "\(userVM.username)"),
                ("AppVersion", Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String),
                ("Geraet", UIDevice.current.name)
            ]
        } else {
            keyValuePairs = [
                ("Bereich", "Protokoll"),
                ("Meldungstyp", "\(mediaVM.savedPDF.name)"),
                ("Freitext", "\(remarksVM.additionalComment)"),
                ("User", "\(userVM.username)"),
                ("AppVersion", Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String),
                ("Geraet", UIDevice.current.name)
            ]
        }
        
        let dict = Dictionary(keyValuePairs)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
            return jsonData as Data
        } catch _ {
            return nil
        }
    }
    
    func compressVideo(urlToCompress: URL, outputURL: URL, mediaVM: MediaViewModel, completion:@escaping (URL)->Void) {
        
        let bitrate = mediaVM.qualityVideo
        
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
                AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:bitrate],
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
                //to:do error handling
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
