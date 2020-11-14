import SwiftUI

struct AppStart: View {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
                //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    let seglerColor: Color = Color(red: 200/255, green: 0/255, blue: 0/255)
    
    //CREATING ALL DATA MODULES FOR THE VIEWS
    @ObservedObject var userVM = UserViewModel()
    @ObservedObject var settingsVM = SettingsViewModel()
    @ObservedObject var mediaVM = MediaViewModel()
    @ObservedObject var orderVM = OrderViewModel()
    @ObservedObject var remarksVM = RemarksViewModel()
    
    @State var value : CGFloat = -30
    
    var body: some View {
        Group {
//            if !settingsVM.hasSettedUp {
//                SetupView(settingsVM : self.settingsVM, remarksVM: self.remarksVM, userVM: self.userVM)
//            } else if (userVM.loggedIn && settingsVM.configLoaded && remarksVM.configLoaded) || settingsVM.useFixedUser {
                Add_View(settingsVM: self.settingsVM, userVM: self.userVM, mediaVM: self.mediaVM, remarksVM: self.remarksVM, orderVM: self.orderVM).accentColor(seglerColor)
//            } else if !userVM.loggedIn && !settingsVM.configLoaded && !remarksVM.configLoaded {
//                ErrorView(userVM: self.userVM, settingsVM: self.settingsVM, mediaVM: self.mediaVM, orderVM: self.orderVM, remarksVM: self.remarksVM)
//            } else {
//                UserLogin(userVM: self.userVM, mediaVM: self.mediaVM, orderVM: self.orderVM)
//            }
        }
        .onAppear {
            self.settingsVM.getJSON()
            self.remarksVM.getJSON(session: self.settingsVM.ip, username: self.settingsVM.serverUsername, password: self.settingsVM.serverPassword)
        }
    }
}
