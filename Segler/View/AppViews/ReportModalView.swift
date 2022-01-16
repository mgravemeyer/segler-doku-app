import SwiftUI

struct ReportModalView: View {
    
    @EnvironmentObject var settingsVM : SettingsViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var orderVM : OrderViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    
    @Binding var showReport : Bool
    
    var body: some View {
            List {
                Text("Abgeschickt!").foregroundColor(Color.black).fontWeight(.bold).font(.largeTitle)
                Text("Auftrags-Nr: \(orderVM.orderNr)").frame(height: 34)
                Text("Auftrags-Position: \(orderVM.orderPosition)").frame(height: 34)
                if remarksVM.selectedComment != "" && mediaVM.savedPDF.name == "" {
                    Text("Kommentar: \(remarksVM.selectedComment)").frame(height: 34)
                }
                if mediaVM.savedPDF.name != "" {
                    Text("Protokoll: \(mediaVM.savedPDF.name)")
                }
                if !mediaVM.images.isEmpty || !mediaVM.imagesCamera.isEmpty || !mediaVM.videos.isEmpty || !mediaVM.videosCamera.isEmpty {
                    HStack {
                        ForEach((0...mediaVM.highestOrderNumber).reversed(), id:\.self) { i in
                            ReportModalImageRendererView(i: i)
                            ReportModalVideoRendererView(i: i)
                        }
                    }
                }
                if remarksVM.additionalComment != "" {
                    Text("Freitext: \(remarksVM.additionalComment)").frame(height: 34)
                }
                Button(action: {
                    deleteMedia()
                }) {
                    Text("Schließen").frame(height: 34).foregroundColor(Color.blue)
                }
            }.listStyle(PlainListStyle()).padding(.top, 40).onDisappear {
                deleteMedia()
            }
    }
    
    func deleteMedia() {
        self.showReport = false
        self.orderVM.orderNr = ""
        self.orderVM.orderPosition = ""
        self.mediaVM.images.removeAll()
        self.mediaVM.videos.removeAll()
        self.mediaVM.imagesCamera.removeAll()
        self.mediaVM.videosCamera.removeAll()
        self.remarksVM.selectedComment = ""
        self.remarksVM.additionalComment = ""
        self.orderVM.orderNrIsOk = true
        self.remarksVM.commentIsOk = true
        self.mediaVM.imagesIsOk = true
        self.showReport = false
        self.mediaVM.savedPDF = PDF(name: "", data: Data(), isArchive: false)
    }

}

struct ReportModalImageRendererView: View {
    @EnvironmentObject var mediaVM : MediaViewModel
    var i: Int;
    
    var body: some View {
        ForEach(mediaVM.images, id:\.self) { image in
            if image.selected && image.order == i {
                Image(uiImage: image.thumbnail).renderingMode(.original).resizable().frame(width: 80, height: 80)
            }
        }
        ForEach(mediaVM.imagesCamera, id:\.self) { image in
            if image.order == i {
                Image(uiImage: image.image).renderingMode(.original).resizable().frame(width: 80, height: 80)
            }
        }
    }
}

struct ReportModalVideoRendererView: View {
    @EnvironmentObject var mediaVM : MediaViewModel
    var i: Int;
    
    var body: some View {
        ForEach(mediaVM.videos, id:\.self) { video in
            if video.selected && video.order == i {
                Image(uiImage: video.thumbnail).renderingMode(.original).resizable().frame(width: 80, height: 80)
            }
        }
        ForEach(mediaVM.videosCamera, id:\.self) { video in
            if video.order == i {
                Image(uiImage: video.thumbnail).renderingMode(.original).resizable().frame(width: 80, height: 80)
            }
        }
    }
}
