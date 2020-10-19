import SwiftUI

struct UserLogin: View {
    
//    @ObservedObject var keyboard = KeyboardResponder()
    @ObservedObject var userVM : UserViewModel
    @ObservedObject var mediaVM : MediaViewModel
    @ObservedObject var orderVM : OrderViewModel
    
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
//                Button(action: {
//                    self.userVM.loggedIn = true
//                }) {
//                    Text("Ad")
//                }
                    Button(action: {
                        self.mediaVM.loginShowImageScannner = true
//                      self.userVM.loggedIn = true
                    }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Anmelden").foregroundColor(Color.white).bold()
                            Spacer()
                        }
                    }.padding().background(Color.green).cornerRadius(4.0)
                }.padding().zIndex(0).offset(y: -50)
            if self.mediaVM.loginShowImageScannner {
                BarcodeScannerSegler(userVM: self.userVM, sourceType: 1, mediaVM: self.mediaVM, orderVM: self.orderVM).zIndex(1)
            }
        }
    }
}


//        Text("Anmelden").bold().font(.title)
//        TextField("Username", text: $userVM.username)
//            .padding()
//            .background(Color(red: 241/255, green: 241/255, blue: 241/255))
//            .cornerRadius(4.0)
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
//        SecureField("Passwort", text: $userVM.password)
//            .padding()
//            .background(Color(red: 241/255, green: 241/255, blue: 241/255))
//            .cornerRadius(4.0)
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))

                    //DEVICE ID
//                    Text("\(UIDevice.current.identifierForVendor!)")
//                    .font(.subheadline)
//                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0))
