import SwiftUI

struct ErrorView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var orderVM : OrderViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    
    var body: some View {
        VStack {
            Image("Error").resizable().frame(width: 200, height: 200)
            Text("Konnte keine Verbindung zum Server herstellen.").fontWeight(.bold)
            Button(action: {
                self.settingsVM.ip = ""
                self.settingsVM.serverPassword = ""
                self.settingsVM.serverUsername = ""
            }) {
                Text("Zurück")
            }
        }.offset(y: -50)
    }
}
