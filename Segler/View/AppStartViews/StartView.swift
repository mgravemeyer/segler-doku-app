import SwiftUI

struct AppStart: View {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    let seglerColor: Color = Color(red: 200/255, green: 0/255, blue: 0/255)
    
    //CREATING ALL DATA MODULES FOR THE VIEWS
    @StateObject var userVM = UserViewModel()
    @StateObject var settingsVM = SettingsViewModel()
    @StateObject var mediaVM = MediaViewModel()
    @StateObject var orderVM = OrderViewModel()
    @StateObject var remarksVM = RemarksViewModel()
    
    @State var value : CGFloat = -30
    
    var body: some View {
        ZStack {
            if !settingsVM.hasSettedUp {
                SetupView()
            } else if (userVM.loggedIn && settingsVM.configLoaded && remarksVM.configLoaded) || settingsVM.useFixedUser {
                Add_View().accentColor(seglerColor)
            } else if !userVM.loggedIn && !settingsVM.configLoaded && !remarksVM.configLoaded {
                ErrorView()
            } else {
                UserLogin()
            }
        }
        .environmentObject(userVM)
        .environmentObject(settingsVM)
        .environmentObject(mediaVM)
        .environmentObject(orderVM)
        .environmentObject(remarksVM)
//        .onAppear {
//            self.settingsVM.getJSON()
//            self.remarksVM.getJSON(session: self.settingsVM.ip, username: self.settingsVM.serverUsername, password: self.settingsVM.serverPassword)
//        }
    }
}
