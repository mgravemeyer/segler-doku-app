import SwiftUI

struct SectionImageViewView: View {
    
    @EnvironmentObject var mediaVM : MediaViewModel
    
    var body: some View {

            ScrollView(.horizontal) {
                HStack {
                    EmptyImageButtonView().accentColor(Color.seglerRed).padding(.leading, 15)
                        if mediaVM.getNumberOfImages()>0 {
                            ForEach((0...mediaVM.highestOrderNumber).reversed(), id:\.self) { i in
                                ForEach(mediaVM.images, id:\.self) { image in
                                    if image.selected && image.order == i {
                                        ImagePreviewView(imageObject: image,id: image.id)
                                    }
                                }
                                ForEach(mediaVM.imagesCamera, id:\.self) { image in
                                    if image.order == i  {
                                        ImageCameraPreviewView(imageObject: image,id: image.id)
                                    }
                                }
                                ForEach(mediaVM.videos, id:\.self) { video in
                                    if video.selected && video.order == i {
                                        VideoPreviewView(videoObject: video, id: video.id)
                                    }
                                }
                                ForEach(mediaVM.videosCamera, id:\.self) { video in
                                    if video.order == i {
                                        VideoCameraPreviewView(videoObject: video, id: video.id)
                                    }
                                }
                            }
                        } else {
                                ForEach(mediaVM.images, id:\.self) { image in
                                    ImagePreviewView(imageObject: image,id: image.id)
                                }
                                ForEach(mediaVM.imagesCamera, id:\.self) { image in
                                    ImageCameraPreviewView(imageObject: image,id: image.id)
                                }
                                ForEach(mediaVM.videos, id:\.self) { video in
                                    VideoPreviewView(videoObject: video, id: video.id)
                                }
                                ForEach(mediaVM.videosCamera, id:\.self) { video in
                                    VideoCameraPreviewView(videoObject: video, id: video.id)
                                }
                        }
                }
            }.padding(.horizontal, -15).listRowBackground(self.mediaVM.imagesIsOk ? Color.white : Color.seglerRowWarning)
    }
}
