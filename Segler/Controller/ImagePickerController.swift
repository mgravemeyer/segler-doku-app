import SwiftUI
import AVFoundation
import MobileCoreServices

struct ImagePicker: UIViewControllerRepresentable {

    @ObservedObject var mediaVM : MediaViewModel

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
        
        let vc = UIImagePickerController()
        vc.allowsEditing = false
        vc.sourceType = .camera
        vc.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        vc.videoQuality = .typeHigh
        
        let previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        vc.delegate = context.coordinator
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        @ObservedObject var mediaVM : MediaViewModel
        
        init(mediaVM : ObservedObject<MediaViewModel>) {
            _mediaVM = mediaVM
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as! NSString
            
            if mediaType.isEqual(to: kUTTypeImage as String) {
                let uiimage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                mediaVM.imagesCamera.append(ImageModelCamera(image: uiimage, order: mediaVM.getOrderNumber()))
            } else {
                let url: URL = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as! URL
                let chosenVideo = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as! URL
                let videoData = try! Data(contentsOf: chosenVideo, options: [])
                let thumbnail = url.generateThumbnail()
                mediaVM.videosCamera.append(VideoModelCamera(video: videoData, thumbnail: thumbnail, order: mediaVM.getOrderNumber()))
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
