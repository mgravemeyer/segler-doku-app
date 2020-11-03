import SwiftUI
import ProgressHUD
import Photos

struct NavigationConfigurator: UIViewControllerRepresentable {
    
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}

struct Divider_custom: View {
    
    let seglerColor: Color = Color(red: 232/255, green: 232/255, blue: 232/255)
    
    var body: some View {
        Image("Keyboard")
        .resizable()
            .frame(width: 0, height: 10)
            .listRowBackground(seglerColor)
    }
}

struct Add_View: View {
    
    let colors = ColorSeglerViewModel()
    
    @ObservedObject var settingsVM : SettingsViewModel
    @ObservedObject var userVM : UserViewModel
    @ObservedObject var mediaVM : MediaViewModel
    @ObservedObject var remarksVM : RemarksViewModel
    @ObservedObject var orderVM : OrderViewModel

    @State var keyboardIsShown = false

    var body: some View {
            ZStack {
                NavigationView {
                    ZStack {
                        Group {
                            ZStack {
                                List {
                                    SectionOrder(orderVM : self.orderVM, mediaVM : self.mediaVM)
                                        .accentColor(colors.color)
                                        .frame(height: 34)
                                    SectionRemarks(remarksVM : self.remarksVM)
                                        .frame(height: 34)
                                    SectionFreeTextField(remarksVM: self.remarksVM)
                                    SectionBilder(mediaVM : self.mediaVM)
                                }.environment(\.defaultMinListRowHeight, 8).zIndex(0)
                                VStack {
                                    Spacer()
                                    SaveButton(settingsVM: self.settingsVM, mediaVM: self.mediaVM, orderVM: self.orderVM, remarksVM: self.remarksVM, userVM: self.userVM).zIndex(100)
                                }
                            }
                        .navigationBarItems(leading:(
                        HStack {
                            NavigationLink(destination: Settings_View(settingsVM: self.settingsVM, userVM: self.userVM, mediaVM: self.mediaVM, remarksVM: self.remarksVM, orderVM: self.orderVM)) {
                                Image(systemName: "gear").font(.system(size: 25))
                            }
                            if !settingsVM.useFixedUser {
                                NavigationLink(destination: Webview(url: "\(settingsVM.helpURL)").navigationBarTitle("Hilfe")) {
                                    Image(systemName: "questionmark.circle").font(.system(size: 25))
                                }
                            }
                        }
                        ), trailing:
                            (
                        HStack {
                            Button(action: {
                            self.userVM.username = ""
                            self.userVM.loggedIn = false
                            self.orderVM.machineName = ""
                            self.orderVM.orderNr = ""
                            self.orderVM.orderPosition = ""
                            self.mediaVM.images.removeAll()
                            self.remarksVM.selectedComment = ""
                            self.remarksVM.additionalComment = ""
                            self.orderVM.orderNrIsOk = true
                            self.remarksVM.commentIsOk = true
                            self.mediaVM.imagesIsOk = true
                            }, label: {
                                if settingsVM.useFixedUser {
                                    Text("")
                                } else {
                                    Image(systemName: "xmark").font(.system(size: 25))
                                }
                            })
                            if settingsVM.useFixedUser {
                                NavigationLink(destination: Webview(url: "\(settingsVM.helpURL)").navigationBarTitle("Hilfe")) {
                                    Image(systemName: "questionmark.circle").font(.system(size: 25))
                                }
                            }
                        }
                        )
//                            Button(action: {}, label: {Image(systemName: "gear")})
                        ).navigationBarTitle(settingsVM.useFixedUser ? Text("\(settingsVM.userUsername)") : Text("\(userVM.username)"), displayMode: .inline)
                        }
                    }
                }
                .sheet(isPresented: self.$mediaVM.showImagePickerNew) {
                    ImageSelectionModal(mediaVM: self.mediaVM)
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                        self.keyboardIsShown = true
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                        self.keyboardIsShown = false
                    }
                }.accentColor(Color.white).navigationViewStyle(StackNavigationViewStyle())
                if self.mediaVM.showImagePicker {
                    ImagePicker(mediaVM : self.mediaVM)
                }
                if self.mediaVM.showImageScanner {
                    BarcodeScannerSegler(userVM: self.userVM,sourceType: 0,mediaVM: self.mediaVM, orderVM: self.orderVM)
                }
            }
            .onAppear() {
            self.remarksVM.getJSON(session: self.settingsVM.ip, username: self.settingsVM.serverUsername, password: self.settingsVM.serverPassword)
        }
    }
}

import WebKit
struct Webview: UIViewRepresentable {
    
    let url : String
    
    func makeUIView(context: Context) -> WKWebView {
        
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        
        let request = URLRequest(url: url)
        let wkWebview = WKWebView()
        wkWebview.load(request)
        return wkWebview
        
    }
    
    func updateUIView(_ uiView: Webview.UIViewType, context: UIViewRepresentableContext<Webview>) {
        
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct BottomPadding: View {
    var body: some View {
        Image("Keyboard")
        .resizable()
            .frame(width: UIScreen.screenWidth, height: 200).blur(radius: 7)
    }
}

struct SectionOrder: View {

    let colors = ColorSeglerViewModel()
    @ObservedObject var orderVM : OrderViewModel
    @ObservedObject var mediaVM : MediaViewModel
    
    var body: some View {
                HStack {
                    TextField("Auftrags-Nr", text: $orderVM.orderNr)
                        .frame(width: UIScreen.main.bounds.width - 70)
                        .disableAutocorrection(true)
                        .keyboardType(.numbersAndPunctuation)
                    Button(action: {
                        UIApplication.shared.endEditing()
                        self.mediaVM.showImageScanner = true
                    }) {
                        Image("QR-Icon")
                        .resizable()
                        .frame(width: 33, height: 33)
                        .foregroundColor(self.colors.color)
                    }.buttonStyle(BorderlessButtonStyle()).zIndex(1000000)
                }.listRowBackground(self.orderVM.orderNrIsOk ? colors.correctRowColor : colors.warningRowColor)
                TextField("Auftrags-Position", text: $orderVM.orderPosition)
                    .keyboardType(.numbersAndPunctuation)
                    .listRowBackground(self.orderVM.orderPositionIsOk ? colors.correctRowColor : colors.warningRowColor)
                .disableAutocorrection(true).accentColor(colors.color)
    }
}

struct SectionRemarks: View {
    
    @ObservedObject var remarksVM : RemarksViewModel
    @State var isVisible = Bool()
    
    let colors = ColorSeglerViewModel()
    
    var body: some View {

            NavigationLink(destination: listComments(remarksVM: self.remarksVM, show: true)) {
                if remarksVM.selectedComment == "" {
                    Text("Kommentar").foregroundColor(.gray)
                } else {
                    Text("\(remarksVM.selectedComment)")
                }
            }.listRowBackground(self.remarksVM.commentIsOk ? colors.correctRowColor : colors.warningRowColor)

    }
}

struct SectionFreeTextField: View {
    
    @ObservedObject var remarksVM : RemarksViewModel
    
    let colors = ColorSeglerViewModel()
    
    var body: some View {
        HStack {
            if #available(iOS 14.0, *) {
                ZStack(alignment: .leading) {
                    if remarksVM.additionalComment == "" {
                        Text("Freitext").zIndex(2).foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                    }
                    TextEditor(text: $remarksVM.additionalComment)
                        .padding(.leading, -5)
                        .zIndex(1)
                        .accentColor(colors.color)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .lineLimit(nil)
                    Text(remarksVM.additionalComment).opacity(0).padding(.all, 10)
                }
            } else {
                TextField("Freitextfeld", text: $remarksVM.additionalComment)
                .frame(width: 200)
                .accentColor(colors.color)
                .keyboardType(.alphabet)
                .disableAutocorrection(true)
                .lineLimit(nil)
            }
            if remarksVM.additionalComment != "" {
                Button(action: {
                    self.remarksVM.additionalComment = ""
                }) {
                    Image("Delete")
                        .renderingMode(.template)
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(self.colors.color)
                }.buttonStyle(BorderlessButtonStyle()).frame(width: 30)
            }
        }
    }
}

struct listComments: View {
    
    @ObservedObject var remarksVM : RemarksViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var show : Bool
    
    var body: some View {

            List {
                ForEach(0..<self.remarksVM.comments.count, id: \.self) { x in
                    NavigationLink(destination: listCommentsDetail(selection: x, remarksVM: self.remarksVM, show: self.$show)) {
                        Text("\(self.remarksVM.comments[x].title)")
                            .frame(height: 34)
                    }
                }
//                Button(action: {
//                    self.remarksVM.selectedComment = ""
//                    self.remarksVM.secondHirarActive = false
//                    self.presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Keinen Kommentar").foregroundColor(.red)
//                        .frame(height: 34)
//                }
            }.navigationBarTitle("Kategorien", displayMode: .inline).onAppear{
                if self.show != true {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.onAppear {
                
        }
    }
}

struct listCommentsDetail: View {
    let selection : Int
    @ObservedObject var remarksVM : RemarksViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var show : Bool
    
    var body: some View {
        List {
            ForEach(0..<self.remarksVM.comments[self.selection].comments.count, id: \.self) { x in
                Button(action: {
                    self.remarksVM.selectedComment = self.remarksVM.comments[self.selection].comments[x]
                    self.show = false
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("\(self.remarksVM.comments[self.selection].comments[x])")
                        .frame(height: 34)
                }
            }.onAppear {
                self.remarksVM.bereich = self.remarksVM.comments[self.selection].title
            }
        }.navigationBarTitle("Kommentare", displayMode: .inline)
    }
}


struct SaveButton: View {
    
    @ObservedObject var settingsVM : SettingsViewModel
    @ObservedObject var mediaVM : MediaViewModel
    @ObservedObject var orderVM : OrderViewModel
    @ObservedObject var remarksVM : RemarksViewModel
    @ObservedObject var userVM : UserViewModel
    @State var showReport = false
    
    let colors = ColorSeglerViewModel()
    
    @State var isInProgress = false
//    lazy var connection = FTPUploadController(mediaVM: self.mediaVM)
    
    var connection: FTPUploadController {
        return FTPUploadController(settingsVM: settingsVM, mediaVM: mediaVM, orderViewModel: self.orderVM, userVM: self.userVM)
    }
    
    @State var keyboardIsShown = false

    var body: some View {
        HStack {
            Button(action: {
                typealias ThrowableCallback = () throws -> Bool
                self.connection.someAsyncFunction(remarksVM: self.remarksVM, true) { (error) -> Void in
                    if error != nil {
                        ProgressHUD.showError(error)
                        return
                    } else {
                        ProgressHUD.showSuccess("Hochgeladen")
                        self.showReport = true
                        return
                    }
                }
            }) {
                Text("Abschicken  ")
                    .font(.headline)
                    .foregroundColor(Color.white)
            }.padding(.leading, 14)
            Spacer()
            if keyboardIsShown {
                Button(action: {
                    UIApplication.shared.endEditing()
                }) {
                    Image(systemName: "keyboard.chevron.compact.down")
    //                Text("Abschicken")
                        .font(.headline)
                        .foregroundColor(Color.white)
                }.padding(.trailing, 14)
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                self.keyboardIsShown = true
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                self.keyboardIsShown = false
            }
    }.frame(height: 50).background(colors.color)
        .sheet(isPresented: $showReport) {
            reportModal(showReport: self.$showReport, settingsVM: self.settingsVM, mediaVM: self.mediaVM, orderVM: self.orderVM, remarksVM: self.remarksVM)
        }
    }
}

struct ImageSelectionModal: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var mediaVM : MediaViewModel
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
//                            if image.type == "image" {
                                Button(action: {
                                    mediaVM.toggleElement(elementId: image.id)
                //                        mediaVM.images[image.].selected.toggle()
                //                     $0.selected.toggle()
                //                     image.selected.toggle()
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
//                            }
                        }
                    }
                    Text("Videos").foregroundColor(Color.black).fontWeight(.bold).font(.title)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(mediaVM.videos, id: \.self) { video in
//                            if image.type == "video" {
                                Button(action: {
                                    mediaVM.toggleVideoElement(elementId: video.id)
                                    print("Toggled: \(video)")
                //                        mediaVM.images[image.].selected.toggle()
                //                     $0.selected.toggle()
                //                     image.selected.toggle()
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
//                            }
                        }
                    }
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

struct reportModal: View {
    
    @Binding var showReport : Bool
    @ObservedObject var settingsVM : SettingsViewModel
    @ObservedObject var mediaVM : MediaViewModel
    @ObservedObject var orderVM : OrderViewModel
    @ObservedObject var remarksVM : RemarksViewModel
    
    var body: some View {
            List {
                Text("Abgeschickt!").foregroundColor(Color.black).fontWeight(.bold).font(.largeTitle)
                Text("Auftrags-Nr: \(orderVM.orderNr)").frame(height: 34)
                Text("Auftrags-Position: \(orderVM.orderPosition)").frame(height: 34)
                Text("Freitext: \(remarksVM.additionalComment)").frame(height: 34)
                Text("Kommentar: \(remarksVM.selectedComment)").frame(height: 34)
                HStack {
                    ForEach(self.mediaVM.images, id: \.id) { image in
                        if image.selected {
                            testImageViewSmallWithoutDelete(mediaVM: self.mediaVM, imageObject: image,id: image.id)
                        }
                    }
                    ForEach(self.mediaVM.videos, id: \.id) { video in
                        if video.selected {
                            testVideoViewSmallWithoutDelete(mediaVM: self.mediaVM, videoObject: video,id: video.id)
                        }
                    }
                }
                Button(action: {
                    deleteMedia()
                }) {
                    Text("Schließen").frame(height: 34)
                }
            }.padding(.top, 40).onDisappear {
                deleteMedia()
            }
    }
    
    func deleteMedia() {
        self.showReport = false
        self.orderVM.machineName = ""
        self.orderVM.orderNr = ""
        self.orderVM.orderPosition = ""
        self.mediaVM.images.removeAll()
        self.mediaVM.videos.removeAll()
        self.remarksVM.selectedComment = ""
        self.remarksVM.additionalComment = ""
        self.orderVM.orderNrIsOk = true
        self.remarksVM.commentIsOk = true
        self.mediaVM.imagesIsOk = true
        self.showReport = false
        self.mediaVM.fetchImages()
    }

}

struct CheckBevoreSendView: View {
    var body: some View {
        Text("Bitte eingaben überprüfen")
    }
}

struct PhotoCaptureView: View {
    
    @State var noPhotosTaken: CGFloat = 0
    @Binding var showImagePicker: Bool
    @Binding var image: Image?
    
    var body: some View {
        Text("HI")
//        ImagePicker(isShown: $showImagePicker, image: $image)
    }
}

//KEYBOARD HIDING
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SectionBilder: View {
    
    let colors = ColorSeglerViewModel()
    @ObservedObject var mediaVM : MediaViewModel
    
    var body: some View {

            ScrollView(.horizontal) {
                HStack {
                    if mediaVM.images.isEmpty {
                        EmptyImgButton(mediaVM : self.mediaVM).accentColor(self.colors.color).padding(.leading, 15)
                    } else {
                        EmptyImgButton(mediaVM : self.mediaVM).accentColor(self.colors.color).padding(.leading, 15)
//                        ForEach((0..<self.mediaVM.images.count).reversed(), id: \.self) { x in
//                            ImageView(mediaVM: self.mediaVM, index: x)
////                            Image(uiImage: self.mediaVM.images[x]).renderingMode(.original).resizable().frame(width: 200, height: 200)
//                        }
                        ForEach(self.mediaVM.imagesCamera.reversed(), id: \.id) { image in
                            testImageCameraView(mediaVM: self.mediaVM, imageObject: image,id: image.id)
                        }
                        ForEach(self.mediaVM.images, id: \.id) { image in
                            if image.selected {
                                testImageView(mediaVM: self.mediaVM, imageObject: image,id: image.id)
                            }
                        }
                        ForEach(self.mediaVM.videos, id: \.id) { video in
                            if video.selected {
                                testVideoView(mediaVM: self.mediaVM, videoObject: video, id: video.id)
                            }
                        }
                    }
                }
            }.padding(.horizontal, -15).listRowBackground(self.mediaVM.imagesIsOk ? colors.correctRowColor : colors.warningRowColor)
    }
}

    struct testImageViewSmall: View {
        
        @ObservedObject var mediaVM: MediaViewModel
        @State var imageObject : ImageModel
        @State var showSheet = false
        @State var id : UUID
        
        var body: some View {
            Button(action: {
                self.showSheet = !self.showSheet
            }) {
                ZStack {
                    Rectangle().background(Color.gray)
                        .frame(width: 80, height: 80)
                        .opacity(1)
                        .zIndex(1)
                    Image(uiImage: imageObject.thumbnail).renderingMode(.original)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .zIndex(0)
                    .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                        ActionSheet(title: Text("Bild löschen"), message: Text("Wirklich Bild löschen?"), buttons: [
                            ActionSheet.Button.default(Text("Ja"), action: {
                                self.deleto(id: self.id)
    //                            self.mediaVM.images.remove(at: imageObject.)
    //                            self.delete(at:self.$mediaVM.images.firstIndex(where: { $0.id == imageObject.id })!)
    //                          self.mediaVM.images.remove(at: self.index)
                            }),
                            ActionSheet.Button.cancel()
                        ])
                    }
                }
            }
        }
        func deleto(id: UUID) {
            if let index = mediaVM.images.firstIndex(where: {$0.id == id}) {
                mediaVM.images.remove(at: index)
            }
//            for x in 0..<self.mediaVM.images.count {
//                if mediaVM.images[x].id == self.imageObject.id {
//                    mediaVM.images.remove(at: x)
//                }
//            }
        }
//        func delete(at index: UUID) {
//            self.mediaVM.images.remove(at: index)
//        }
    }

    struct testVideoViewSmallWithoutDelete: View {
        
        @ObservedObject var mediaVM: MediaViewModel
        @State var videoObject : VideoModel
        @State var showSheet = false
        @State var id : UUID
        
        var body: some View {
            Button(action: {
                self.showSheet = !self.showSheet
            }) {
                Image(uiImage: videoObject.thumbnail).renderingMode(.original).resizable().frame(width: 80, height: 80)
            }
        }
    //        func delete(at index: UUID) {
    //            self.mediaVM.images.remove(at: index)
    //        }
    }


    struct testImageViewSmallWithoutDelete: View {
        
        @ObservedObject var mediaVM: MediaViewModel
        @State var imageObject : ImageModel
        @State var showSheet = false
        @State var id : UUID
        
        var body: some View {
            Button(action: {
                self.showSheet = !self.showSheet
            }) {
                Image(uiImage: imageObject.thumbnail).renderingMode(.original).resizable().frame(width: 80, height: 80)
            }
        }
//        func delete(at index: UUID) {
//            self.mediaVM.images.remove(at: index)
//        }
    }

struct testImageCameraView: View {
    
    @ObservedObject var mediaVM: MediaViewModel
    @State var imageObject : ImageModelCamera
    @State var showSheet = false
    @State var id : UUID
    
    var body: some View {
        Button(action: {
            self.showSheet = !self.showSheet
        }) {
            Image(uiImage: imageObject.image).renderingMode(.original).resizable().frame(width: 100, height: 100).scaledToFill()
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Bild löschen"), message: Text("Wirklich Bild löschen?"), buttons: [
                    ActionSheet.Button.default(Text("Ja"), action: {
                        self.deleto(id: self.id)
//                            self.mediaVM.images.remove(at: imageObject.)
//                            self.delete(at:self.$mediaVM.images.firstIndex(where: { $0.id == imageObject.id })!)
//                          self.mediaVM.images.remove(at: self.index)
                    }),
                    ActionSheet.Button.cancel()
                ])
            }
        }
    }
    func deleto(id: UUID) {
        if let index = mediaVM.imagesCamera.firstIndex(where: {$0.id == id}) {
            mediaVM.imagesCamera.remove(at: index)
        }
}

    
    struct testImageView: View {
        
        @ObservedObject var mediaVM: MediaViewModel
        @State var imageObject : ImageModel
        @State var showSheet = false
        @State var id : UUID
        
        var body: some View {
            Button(action: {
                self.showSheet = !self.showSheet
            }) {
                Image(uiImage: imageObject.thumbnail).renderingMode(.original).resizable().frame(width: 100, height: 100).scaledToFill()
                .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                    ActionSheet(title: Text("Bild löschen"), message: Text("Wirklich Bild löschen?"), buttons: [
                        ActionSheet.Button.default(Text("Ja"), action: {
                            self.deleto(id: self.id)
//                            self.mediaVM.images.remove(at: imageObject.)
//                            self.delete(at:self.$mediaVM.images.firstIndex(where: { $0.id == imageObject.id })!)
//                          self.mediaVM.images.remove(at: self.index)
                        }),
                        ActionSheet.Button.cancel()
                    ])
                }
            }
        }
        func deleto(id: UUID) {
            if let index = mediaVM.images.firstIndex(where: {$0.id == id}) {
                mediaVM.images.remove(at: index)
            }
//            for x in 0..<self.mediaVM.images.count {
//                if mediaVM.images[x].id == self.imageObject.id {
//                    mediaVM.images.remove(at: x)
//                }
//            }
        }
//        func delete(at index: UUID)
//            self.mediaVM.images.remove(at: index)
//        }
    }

struct testVideoView: View {

    @ObservedObject var mediaVM: MediaViewModel
    @State var videoObject : VideoModel
    @State var showSheet = false
    @State var id : UUID
    
    var body: some View {
        Button(action: {
            self.showSheet = !self.showSheet
        }) {
            Image(uiImage: videoObject.thumbnail).renderingMode(.original).resizable().frame(width: 100, height: 100).scaledToFill()
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Bild löschen"), message: Text("Wirklich Bild löschen?"), buttons: [
                    ActionSheet.Button.default(Text("Ja"), action: {
                        self.deleto(id: self.id)
                    }),
                    ActionSheet.Button.cancel()
                ])
            }
        }
    }
    func deleto(id: UUID) {
        if let index = mediaVM.videos.firstIndex(where: {$0.id == id}) {
            mediaVM.videos.remove(at: index)
        }
    }
}

struct ImageView: View {
    
    @ObservedObject var mediaVM : MediaViewModel
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
//                            self.delete(at: self.$mediaVM.firstIndex(where: {index}))
//                            self.delete(at:self.mediaVM.firstIndex(where: { $0.id == music.id })!)
//                          self.mediaVM.images.remove(at: self.index)
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

struct EmptyImgButton: View {
    
    @ObservedObject var mediaVM : MediaViewModel
    
    @State var showSheet = false
    
    var color = ColorSeglerViewModel()

//    @Binding var showImagePicker: Bool
//    @Binding var image: UIImage?
//    @Binding var sourceType: Int
    
    var body: some View {
        Group {
            if !UIDevice.current.name.contains("iPod touch") {
                Button(action: {
                    UIApplication.shared.endEditing()
                    self.showSheet = !self.showSheet
                }) {
                    

                    ZStack {
                        Image("Camera")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(color.color)
                            .frame(width: 40, height: 40)
                            .zIndex(1)
                        RoundedRectangle(cornerRadius: CGFloat(3))
                            .foregroundColor(Color.clear)
                            .frame(width: 40, height: 145)
                            .zIndex(0)
                    }
                }
            } else {
                Button(action: {
                    UIApplication.shared.endEditing()
                    self.mediaVM.sourceType = 0
                    self.mediaVM.showImagePicker = !self.mediaVM.showImagePicker
                }) {
                    ZStack {
                        Image("Camera")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(color.color)
                            .frame(width: 40, height: 40)
                            .zIndex(1)
                        RoundedRectangle(cornerRadius: CGFloat(3))
                            .foregroundColor(Color.clear)
                            .frame(width: 40, height: 145)
                            .zIndex(0)
                    }
                }
            }
        }
//        if UIDevice.current.name.contains("iPod touch") {
//
//        }
            .actionSheet(isPresented: self.$showSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Bild hinzufügen"), message: Text("Kamera oder Galerie auswählen"), buttons: [
                    ActionSheet.Button.default(Text("Kamera"), action: {
                        self.mediaVM.sourceType = 0
                        self.mediaVM.showImagePicker = !self.mediaVM.showImagePicker
                    }),
                    ActionSheet.Button.default(Text("Galerie"), action: {
                        self.mediaVM.showImagePickerNew.toggle()
//                        self.mediaVM.sourceType = 1
//                        self.mediaVM.showImagePicker = !self.mediaVM.showImagePicker
                    }),
                    ActionSheet.Button.cancel()
                ])
        }
    }
}
