import SwiftUI

struct ImageCameraPreviewView: View {
    
    @EnvironmentObject var mediaVM: MediaViewModel
    
    @State var imageObject : ImageModelCamera
    @State var showSheet = false
    @State var id : UUID
    
    var body: some View {
        Button(action: {
            self.showSheet = !self.showSheet
        }) {
            ZStack {
                Rectangle().frame(width: 100, height: 100).background(Color.black).opacity(0.3).zIndex(2)
                Text("Foto").fontWeight(.bold).zIndex(1)
                Image(uiImage: imageObject.image).renderingMode(.original).resizable().frame(width: 100, height: 100).scaledToFill().zIndex(0)
            }
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Anzeigen - Löschen"), buttons: [
                    ActionSheet.Button.default(Text("Bild anzeigen"), action: {
                        toggleShowImage()
                    }),
                    ActionSheet.Button.destructive(Text("Bild löschen"), action: {
                        self.deleto(id: self.id)
                    }),
                    ActionSheet.Button.cancel()
                ])
            }
        }
    }
    func toggleShowImage() {
        mediaVM.showImage.toggle()
        mediaVM.selectedImage = UIImage(data: (imageObject.image.jpegData(compressionQuality: 1)!))
    }
    func deleto(id: UUID) {
        if let index = mediaVM.imagesCamera.firstIndex(where: {$0.id == id}) {
            mediaVM.imagesCamera.remove(at: index)
        }
    }
}
