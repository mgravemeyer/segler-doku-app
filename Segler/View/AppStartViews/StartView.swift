import SwiftUI
import ProgressHUD

struct AppStart: View {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.seglerRed
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    @State var appIsReady: Bool = false
    
    @State var isLoading: Bool = true
    
    //CREATING ALL DATA MODULES FOR THE VIEWS
    @StateObject var userVM = UserViewModel()
    @StateObject var settingsVM = SettingsViewModel()
    @StateObject var mediaVM = MediaViewModel()
    @StateObject var orderVM = OrderViewModel()
    @StateObject var remarksVM = RemarksViewModel()
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView(appIsReady: self.$appIsReady)
            } else {
                if self.appIsReady && userVM.loggedIn {
                    AppView()
                        .onAppear {
                            self.settingsVM.loadJSON()
                            self.remarksVM.loadJSON()
                            self.mediaVM.loadPDFs()
                            self.mediaVM.loadQuality()
                        }
                } else if self.appIsReady {
                    LoginView()
                } else {
                    SetupView(appIsReady: $appIsReady)
                }
            }
        }
        .onAppear(perform: {
            DispatchQueue.global(qos: .userInitiated).async {
                if(
                    UserDefaults.standard.string(forKey: "ip") != nil &&
                    UserDefaults.standard.string(forKey: "serverUsername") != nil &&
                    UserDefaults.standard.string(forKey: "serverPassword") != nil
                ){
                    self.appIsReady = NetworkDataManager.shared.connect(
                        host: UserDefaults.standard.string(forKey: "ip")!,
                        username: UserDefaults.standard.string(forKey: "serverUsername")!,
                        password: UserDefaults.standard.string(forKey: "serverPassword")!,
                        isInit: true)
                    self.isLoading = false
                } else {
                    self.appIsReady = false
                    self.isLoading = false
                }
            }
        })
        .accentColor(Color.seglerRed)
        .environmentObject(userVM)
        .environmentObject(settingsVM)
        .environmentObject(mediaVM)
        .environmentObject(orderVM)
        .environmentObject(remarksVM)
    }
}
