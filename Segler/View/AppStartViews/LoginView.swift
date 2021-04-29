import SwiftUI

struct UserLogin: View {
    
//    @ObservedObject var keyboard = KeyboardResponder()
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var orderVM : OrderViewModel
    
    @State var value : CGFloat = -30
    
    @State var showBarcodeScanner = false
    
    var body: some View {
        ZStack {
            VStack {
                Image("Segler")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 280.0)
                .padding(Edge.Set.bottom, 20)
                
                Button(action: {
                    self.mediaVM.loginShowImageScannner = true

                }) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Anmelden").foregroundColor(Color.white).bold()
                        Spacer()
                    }
                }.padding().background(Color.green).cornerRadius(4.0)
                }.padding().zIndex(0).offset(y: -50)
            if self.mediaVM.loginShowImageScannner {
                BarcodeScannerSegler(sourceType: 1).zIndex(1)
            }
        }
    }
}
