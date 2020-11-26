import SwiftUI
import CoreData
import ProgressHUD

struct SetupView: View {
    @ObservedObject var settingsVM : SettingsViewModel
    @ObservedObject var remarksVM : RemarksViewModel
    @ObservedObject var mediaVM = MediaViewModel()
    @ObservedObject var orderVM = OrderViewModel()
    @ObservedObject var userVM = UserViewModel()
    
    @State var value : CGFloat = -30
    var body: some View {
            VStack {
                Image("Segler")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 280)
                .padding(Edge.Set.bottom, 20)
//              Text("Gerät registrieren").bold().font(.title)
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

                //GETTING DEVICE ID AND DISPLAY AS TEXT
//                Text("\(UIDevice.current.identifierForVendor!)")
//                .font(.subheadline)
//                .padding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0))

                Button(action: {
                    let connection = FTPUploadController(settingsVM: self.settingsVM, mediaVM: self.mediaVM, orderViewModel: self.orderVM, userVM: self.userVM)
                    if connection.authenticate() {
                        ProgressHUD.showSuccess("Verbunden")
                        self.settingsVM.saveServerSettings()
                        self.settingsVM.deviceIsSettedUp()
                        self.settingsVM.getJSON()
                        self.remarksVM.getJSON(session: self.settingsVM.ip, username: self.settingsVM.serverUsername, password: self.settingsVM.serverPassword)
                    } else {
                        ProgressHUD.showError("Keine Verbindung mit diesem Netzwerk möglich")
                        self.settingsVM.deviceIsNotSettedUp()
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
