import SwiftUI

struct ImageView: View {
    
    @EnvironmentObject var mediaVM : MediaViewModel
    @State var index: Int
    @State var showSheet = false
    
    var body: some View {
        Button(action: {
            self.showSheet = !self.showSheet
        }) {
            Image(uiImage: self.mediaVM.images[self.index].thumbnail).renderingMode(.original).scaledToFit().frame(width: 120, height: 120)
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                    ActionSheet(title: Text("Bild löschen"), message: Text("Wirklich Bild löschen?"), buttons: [
                        ActionSheet.Button.default(Text("Ja"), action: {
                        }),
                        ActionSheet.Button.cancel()
                    ])
            }
        }
    }
    func delete(at index: Int) {
        self.mediaVM.images.remove(at: index)
    }
}
