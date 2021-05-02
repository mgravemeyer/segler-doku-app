import SwiftUI

struct ImagePreviewView: View {
    
    @EnvironmentObject var mediaVM: MediaViewModel
    
    @State var imageObject : ImageModel
    @State var showSheet = false
    @State var id : UUID
    
    var body: some View {
        Button(action: {
            self.showSheet = !self.showSheet
        }) {
            ZStack {
                Rectangle().frame(width: 100, height: 100).background(Color.black).opacity(0.3).zIndex(2)
                Text("Foto").fontWeight(.bold).zIndex(1)
                Image(uiImage: imageObject.thumbnail).renderingMode(.original).resizable().frame(width: 100, height: 100).scaledToFill().zIndex(0)
            }
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Anzeigen - Löschen"), buttons: [
                    ActionSheet.Button.default(Text("Bild anzeigen"), action: {
                        self.toggleShowImage()
                    }),
                    ActionSheet.Button.destructive(Text("Bild löschen"), action: {
                        self.toggle(id: self.id)
                    }),
                    ActionSheet.Button.cancel()
                ])
            }
        }
    }
    func toggleShowImage() {
        mediaVM.showImage.toggle()
        mediaVM.selectedImage = UIImage(data: (imageObject.fetchImage()))
    }
    func toggle(id: UUID) {
        if let index = mediaVM.images.firstIndex(where: {$0.id == id}) {
            mediaVM.images[index].selected.toggle()
        }
    }
}
