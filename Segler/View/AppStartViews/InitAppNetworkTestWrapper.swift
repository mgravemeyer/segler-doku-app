import SwiftUI

struct InitAppNetworkTestWrapper: View {
    
    init() {
        if(
            UserDefaults.standard.string(forKey: "ip") != nil &&
            UserDefaults.standard.string(forKey: "serverUsername") != nil &&
            UserDefaults.standard.string(forKey: "serverPassword") != nil
        ){
            self.appIsReady = NetworkDataManager.shared.connect(
                host: UserDefaults.standard.string(forKey: "ip")!,
                username: UserDefaults.standard.string(forKey: "serverUsername")!,
                password: UserDefaults.standard.string(forKey: "serverPassword")!)
        } else {
            self.appIsReady = false
        }
    }
    
    @State var appIsReady: Bool
    
    var body: some View {
        if appIsReady {
            StartPreApp()
        } else {
            ErrorView()
        }
    }
}
