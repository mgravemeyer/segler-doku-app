import SwiftUI

struct PhotoDetail: View {
    
    @EnvironmentObject var mediaVM : MediaViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Button(action: {
                        mediaVM.showImage = false
                        mediaVM.showVideo = false
                    }, label: {
                        ZStack {
                            Color.gray.frame(width: geometry.size.width - 20, height: 40).padding(.leading, 0).cornerRadius(10).zIndex(1)
                            Text("Anzeige schließen").foregroundColor(Color.white).zIndex(50000)
                        }
                    }).zIndex(1)
                    if mediaVM.selectedImage!.size.width > mediaVM.selectedImage!.size.height {
                        Image(uiImage: mediaVM.selectedImage!).resizable().aspectRatio(contentMode: .fit).rotationEffect(.degrees(-90))
                            .frame(maxWidth: geometry.size.width - 20, maxHeight: geometry.size.height - 150, alignment: .center)
                            .frame(width: geometry.size.width - 20, height: geometry.size.height - 150)
                            .scaleEffect(CGSize(width: 1.4, height: 1.4))
                    } else {
                        Image(uiImage: mediaVM.selectedImage!).resizable().scaledToFit().frame(width: geometry.size.width - 20, height: geometry.size.height - 150)
                    }
                    
                }.padding(.top, geometry.size.height/2 - 350).zIndex(1)
                    Color.white.opacity(1).zIndex(-100)
            }
        }.zIndex(100)
    }
}
