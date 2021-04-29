import SwiftUI

struct VideoPreviewView: View {

    @EnvironmentObject var mediaVM: MediaViewModel
    @State var videoObject : VideoModel
    @State var showSheet = false
    @State var id : UUID
    
    var body: some View {
        Button(action: {
            self.showSheet = !self.showSheet
        }) {
            ZStack {
                Rectangle().frame(width: 100, height: 100).background(Color.black).opacity(0.3).zIndex(2)
                Text("Video").fontWeight(.bold).zIndex(1)
                Image(uiImage: videoObject.thumbnail).renderingMode(.original).resizable().frame(width: 100, height: 100).scaledToFill().zIndex(0)
            }
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Anzeigen - Löschen"), buttons: [
                    ActionSheet.Button.default(Text("Video anzeigen"), action: {
                        self.toggleShowImage()
                    }),
                    ActionSheet.Button.destructive(Text("Video löschen"), action: {
                        self.toggle(id: self.id)
                    }),
                    ActionSheet.Button.cancel()
                ])
            }
        }
    }
    func toggleShowImage() {
        mediaVM.showVideo.toggle()
        mediaVM.selectedVideo = videoObject.assetURL
    }
    func toggle(id: UUID) {
        if let index = mediaVM.videos.firstIndex(where: {$0.id == id}) {
            mediaVM.videos[index].selected.toggle()
        }
    }
}
