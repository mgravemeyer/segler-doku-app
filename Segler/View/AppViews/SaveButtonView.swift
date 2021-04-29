import SwiftUI
import ProgressHUD

struct SaveButtonView: View {
    
    @EnvironmentObject var settingsVM : SettingsViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var orderVM : OrderViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State var showReport = false
    
    let colors = ColorSeglerViewModel()
    
    @State var isInProgress = false
//    lazy var connection = FTPUploadController(mediaVM: self.mediaVM)
    
    var connection: FTPUploadController {
        return FTPUploadController()
    }
    
    @State var keyboardIsShown = false

    var body: some View {
        HStack {
            Button(action: {
                typealias ThrowableCallback = () throws -> Bool
                self.connection.someAsyncFunction(true) { (error) -> Void in
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
            reportModal(showReport: self.$showReport)
        }
    }
}
