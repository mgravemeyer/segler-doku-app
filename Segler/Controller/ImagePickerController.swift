import SwiftUI
import AVFoundation
import MobileCoreServices

struct MediaPickerView: UIViewControllerRepresentable {

    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var mediaVM : MediaViewModel

    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    func makeCoordinator() -> Coordinator {
        Coordinator(mediaVM : _mediaVM)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let screenSize = UIScreen.main.bounds.size
        let cameraAspectRatio: Float = 4.0 / 3.0
        let imageWidth = floorf(Float(screenSize.width) * cameraAspectRatio)
        let scale: Float = ceilf((Float(screenSize.height) / imageWidth) * 10.0) / 10.0
        
        
        let vc = UIImagePickerController()
        vc.allowsEditing = false
        vc.sourceType = .camera
        vc.cameraViewTransform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale));
        if mediaVM.returnVideoCount() > 2 {
            vc.mediaTypes = [kUTTypeImage as String]
        } else {
            vc.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        }
        vc.videoQuality = .typeHigh
        
//        if UIDevice.current.name.contains("iPhone") {
//            if settingsVM.qv_iPhone.floatValue > 0.7 {
//                print("Nutze gute Qualität!")
//                vc.videoQuality = .typeHigh
//            } else if settingsVM.qv_iPhone.floatValue > 0.3 {
//                print("Nutze mittlere Qualität!")
//                vc.videoQuality = .typeMedium
//            } else {
//                print("Nutze low Qualität!")
//                vc.videoQuality = .type640x480
//            }
//        } else
//        if UIDevice.current.name.contains("iPod touch") {
//            if settingsVM.qv_iPod.floatValue > 0.7 {
//                vc.videoQuality = .typeHigh
//            } else if settingsVM.qv_iPod.floatValue > 0.3 {
//                vc.videoQuality = .typeMedium
//            } else {
//                vc.videoQuality = .type640x480
//            }
//
//        } else
//        if UIDevice.current.name.contains("iPad") {
//            if settingsVM.qv_iPad.floatValue > 0.7 {
//                vc.videoQuality = .typeHigh
//            } else if settingsVM.qv_iPad.floatValue > 0.3 {
//                vc.videoQuality = .typeMedium
//            } else {
//                vc.videoQuality = .type640x480
//            }
//
//        }
        
        let previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        vc.delegate = context.coordinator
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                // we got back an error!
                let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            } else {
                let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            }
        }
        
        @EnvironmentObject var mediaVM : MediaViewModel
        
        var assetWriter:AVAssetWriter?
         var assetReader:AVAssetReader?
         let bitrate:NSNumber = NSNumber(value:250000)
        
        init(mediaVM : EnvironmentObject<MediaViewModel>) {
            _mediaVM = mediaVM
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as! NSString
            
            if mediaType.isEqual(to: kUTTypeImage as String) {
                let uiimage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                UIImageWriteToSavedPhotosAlbum(uiimage, nil, nil, nil)
                mediaVM.imagesCamera.append(ImageModelCamera(image: uiimage, order: mediaVM.getOrderNumber()))
            } else {
                let url: URL = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as! URL
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
                let videoData = try! Data(contentsOf: url, options: [])
                let thumbnail = url.generateThumbnail()
                var orientation = ""
                if thumbnail.size.width > thumbnail.size.height {
                    orientation = "horizontal"
                } else if thumbnail.size.width < thumbnail.size.height {
                    orientation = "vertical"
                } else {
                    orientation = "quadratisch"
                }
                mediaVM.videosCamera.append(VideoModelCamera(url: url, video: videoData, thumbnail: thumbnail, order: mediaVM.getOrderNumber(), orientation: orientation))
            }
            mediaVM.showImagePicker = false
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            mediaVM.showImagePicker = false
        }
    }
}

private extension URL {
    
    func generateThumbnail() -> UIImage {
        let asset = AVAsset(url: self)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = 0
        let imageRef = try? generator.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: imageRef!)
        return thumbnail
    }
    
}
