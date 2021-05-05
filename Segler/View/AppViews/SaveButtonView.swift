import SwiftUI
import ProgressHUD

struct SaveButtonView: View {
    
    @EnvironmentObject var settingsVM : SettingsViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var orderVM : OrderViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State var showReport = false
    @State var isInProgress = false
    @State var keyboardIsShown = false

    var body: some View {
        HStack {
            Button(action: {
                typealias ThrowableCallback = () throws -> Bool
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                NetworkDataManager.shared.sendToFTP(mediaVM: mediaVM, userVM: userVM, orderVM: orderVM, remarksVM: remarksVM, true) { (error) -> Void in
                    if error != nil {
                        ProgressHUD.showError("Daten ungültig")
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
        }.frame(height: 50).background(Color.seglerRed)
        .sheet(isPresented: $showReport) {
            ReportModalView(showReport: self.$showReport)
        }
    }
}
