import SwiftUI

struct AppStart: View {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        if(
            UserDefaults.standard.string(forKey: "ip") != nil &&
            UserDefaults.standard.string(forKey: "ip") != nil &&
            UserDefaults.standard.string(forKey: "ip") != nil
        ){
            self.appIsReady = NetworkDataManager.shared.connect(
                host: UserDefaults.standard.string(forKey: "ip")!,
                username: UserDefaults.standard.string(forKey: "serverUsername")!,
                password: UserDefaults.standard.string(forKey: "serverPassword")!)
        }
    }
    
    @State var appIsReady = false
    
    //CREATING ALL DATA MODULES FOR THE VIEWS
    @StateObject var userVM = UserViewModel()
    @StateObject var settingsVM = SettingsViewModel()
    @StateObject var mediaVM = MediaViewModel()
    @StateObject var orderVM = OrderViewModel()
    @StateObject var remarksVM = RemarksViewModel()
    
    var body: some View {
        Group {
            if appIsReady && userVM.loggedIn {
               AppView()
           } else if appIsReady {
                UserLogin()
            } else {
                SetupView()
            }
        }.accentColor(Color.seglerRed)
        .environmentObject(userVM)
        .environmentObject(settingsVM)
        .environmentObject(mediaVM)
        .environmentObject(orderVM)
        .environmentObject(remarksVM)
    }
}
