import SwiftUI

struct ImageSelectionModal: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var mediaVM : MediaViewModel
    let columns = [
            GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Bilder").foregroundColor(Color.black).fontWeight(.bold).font(.title)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(mediaVM.images, id: \.self) { image in
                                Button(action: {
                                    mediaVM.toggleElement(elementId: image.id)
                                }, label: {
                                    ZStack {
                                        if image.selected {
                                            Image(systemName: "checkmark")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.white)
                                                .frame(width: 20, height: 20)
                                                .zIndex(2)
                                            Rectangle()
                                                .foregroundColor(Color.black).opacity(0.5)
                                                .frame(width: 80, height: 80)
                                                .zIndex(1)
                                        }
                                        Image(uiImage: image.thumbnail)
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .zIndex(0)
                                    }
                                }).buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    Button("Lade mehr Fotos") {
                        mediaVM.selectedPhotoAmount += 12
                        mediaVM.fetchMedia()
                    }.foregroundColor(Color.blue)
                    Text("Videos").foregroundColor(Color.black).fontWeight(.bold).font(.title)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(mediaVM.videos, id: \.self) { video in
                            if mediaVM.returnVideoCount() > 2 {
                                if video.selected {
                                    Button(action: {
                                        mediaVM.toggleVideoElement(elementId: video.id)
                                    }, label: {
                                        ZStack {
                                            if video.selected {
                                                Image(systemName: "checkmark")
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .foregroundColor(Color.white)
                                                    .frame(width: 20, height: 20)
                                                    .zIndex(2)
                                                Rectangle()
                                                    .foregroundColor(Color.black).opacity(0.5)
                                                    .frame(width: 80, height: 80)
                                                    .zIndex(1)
                                            }
                                            Image(uiImage: video.thumbnail)
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                                .zIndex(0)
                                        }
                                    }).buttonStyle(BorderlessButtonStyle())
                                } else {
                                    Image(uiImage: video.thumbnail)
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .zIndex(0)
                                }
                            } else {
                                Button(action: {
                                    mediaVM.toggleVideoElement(elementId: video.id)
                                }, label: {
                                    ZStack {
                                        if video.selected {
                                            Image(systemName: "checkmark")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.white)
                                                .frame(width: 20, height: 20)
                                                .zIndex(2)
                                            Rectangle()
                                                .foregroundColor(Color.black).opacity(0.5)
                                                .frame(width: 80, height: 80)
                                                .zIndex(1)
                                        }
                                        Image(uiImage: video.thumbnail)
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .zIndex(0)
                                    }
                                }).buttonStyle(BorderlessButtonStyle())
                                
                            }
                        }
                    }
                    Button("Lade mehr Videos") {
                        mediaVM.selectedVideoAmount += 12
                        mediaVM.fetchMedia()
                    }.foregroundColor(Color.blue).padding(.bottom, 100)
                }.padding(.vertical, 15).padding(.horizontal, 15)
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        
                    }, label: {
                        Text("")
                    }), trailing:
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Fertig")
                    })).navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Fotos und Videos")
        }
        .accentColor(Color.white)
    }
}
