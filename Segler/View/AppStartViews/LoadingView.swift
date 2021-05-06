import SwiftUI
import ProgressHUD

struct LoadingView: View {
    @Binding var appIsReady: Bool
    var body: some View {
        VStack {
            Image("Segler")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
                .offset(y: -140)
        }.onAppear {
            ProgressHUD.colorSpinner(UIColor.seglerRed)
            ProgressHUD.show("Verbinde...")
        }.onDisappear {
            if appIsReady {
                ProgressHUD.showSuccess("Verbunden")
            } else {
                ProgressHUD.showError("Fehler beim Verbinden")
            }
        }
    }
}
