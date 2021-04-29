import SwiftUI
import AVKit

struct VideoDetail: View {
    
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
                    ZStack {
                        if resolutionSizeForLocalVideo(url: mediaVM.selectedVideo!)!.width > resolutionSizeForLocalVideo(url: mediaVM.selectedVideo!)!.height {
                            AVPlayerView(videoURL: $mediaVM.selectedVideo, frameWidth: geometry.size.width - 20, frameHeight: geometry.size.height - 150, rotation: 270).frame(width: geometry.size.width - 20, height: geometry.size.height - 150)
                        } else {
                            AVPlayerView(videoURL: $mediaVM.selectedVideo, frameWidth: geometry.size.width - 20, frameHeight: geometry.size.height - 150, rotation: 0).frame(width: geometry.size.width - 20, height: geometry.size.height - 150)
                        }
                    }
                }.padding(.top, geometry.size.height/2 - 350).zIndex(1)
                Color.white.opacity(1).zIndex(-100)
            }
        }.zIndex(100)
    }
}

func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
    guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
    let size = track.naturalSize.applying(track.preferredTransform)
    return CGSize(width: abs(size.width), height: fabs(size.height))
}
