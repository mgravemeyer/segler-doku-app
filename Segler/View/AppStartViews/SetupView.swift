import SwiftUI
import CoreData
import ProgressHUD

struct SetupView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    @State var value : CGFloat = -30
    var body: some View {
            VStack {
                Image("Segler")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 280)
                .padding(Edge.Set.bottom, 20)

                TextField("Server / Hostname", text: $settingsVM.ip)
                .padding()
                .background(Color(red: 241/255, green: 241/255, blue: 241/255))
                .cornerRadius(4.0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
    
                TextField("Benutzername", text: $settingsVM.serverUsername)
                .padding()
                .background(Color(red: 241/255, green: 241/255, blue: 241/255))
                .cornerRadius(4.0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))

                SecureField("Passwort", text: $settingsVM.serverPassword)
                .padding()
                .background(Color(red: 241/255, green: 241/255, blue: 241/255))
                .cornerRadius(4.0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                
                Button(action: {
                    let connection = FTPUploadController()
                    if connection.authenticate() {
                        ProgressHUD.showSuccess("Verbunden")
                        self.settingsVM.saveServerSettings()
                    } else {
                        ProgressHUD.showError("Keine Verbindung mit diesem Netzwerk möglich")
                    }
                }) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Registrieren").foregroundColor(Color.white).bold()
                        Spacer()
                    }
                }.padding().background(Color.green).cornerRadius(4.0)
            }.padding().offset(y: self.value).animation(.spring()).onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                    let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = -value.height+120
                    self.value = height
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                    _ = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height : CGFloat = -30
                    self.value = height
                }
        }
    }
}
