import SwiftUI
import ProgressHUD
import Photos
import AVKit

struct AppView: View {
    
    @EnvironmentObject var settingsVM : SettingsViewModel
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    @EnvironmentObject var orderVM : OrderViewModel

    @State var keyboardIsShown = false
    
    var body: some View {
            ZStack {
                NavigationView {
                    ZStack {
                        Group {
                            ZStack {
                                if mediaVM.showVideo {
                                    VideoDetail()
                                        .onAppear {
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                }
                                if mediaVM.showImage {
                                    if mediaVM.selectedImageNeedsAjustment {
                                        PhotoDetail()
                                            .onAppear {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }
                                    }
                                }
                                List {
                                    SectionOrder()
                                        .frame(height: 34)
                                    SectionRemarks()
                                        .frame(height: 34)
                                    SectionFreeTextField()
                                    SectionImageViewView()
                                    if !(settingsVM.errorsJSON.isEmpty) {
                                        Image("Warning").resizable().frame(width: 50, height: 50)
                                        ForEach(settingsVM.errorsJSON, id: \.self) { error in
                                            Text(error).foregroundColor(Color.red)
                                        }
                                    }
                                }.environment(\.defaultMinListRowHeight, 8).zIndex(0)
                                VStack {
                                    Spacer()
                                    SaveButtonView().zIndex(100)
                                }
                            }
                        .navigationBarItems(leading:(
                        HStack {
                            NavigationLink(destination: Settings_View()) {
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
                        ).navigationBarTitle(settingsVM.useFixedUser ? Text("\(settingsVM.userUsername)") : Text("\(userVM.username)"), displayMode: .inline)
                        }
                    }
                }
                .sheet(isPresented: self.$mediaVM.showImagePickerNew) {
                    ImageSelectionModal()
                    .onAppear {
                        mediaVM.fetchMedia()
                    }
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
                    ImagePicker()
                }
                if self.mediaVM.showImageScanner {
                    BarcodeScannerSegler(sourceType: 0)
                }
            }
            .onAppear() {
            self.remarksVM.getJSON(session: self.settingsVM.ip, username: self.settingsVM.serverUsername, password: self.settingsVM.serverPassword)
        }
    }
}
