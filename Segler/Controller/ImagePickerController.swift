import SwiftUI

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
        vc.sourceType = mediaVM.sourceType == 1 ? .photoLibrary : .camera
        
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiimage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            mediaVM.image = uiimage
            mediaVM.images.append(ImageModel(image: uiimage))
            mediaVM.showImagePicker = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            mediaVM.showImagePicker = false
        }
    }
}
