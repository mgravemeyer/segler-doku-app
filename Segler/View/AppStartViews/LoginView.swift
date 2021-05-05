import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    @EnvironmentObject var orderVM : OrderViewModel
    
    @State var value : CGFloat = -30
    
    @State var showBarcodeScannerView = false
    
    var body: some View {
        ZStack {
            VStack {
                Image("Segler")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 280.0)
                .padding(Edge.Set.bottom, 20)
                
                Button(action: {
                    self.showBarcodeScannerView = true
                }) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Anmelden").foregroundColor(Color.white).bold()
                        Spacer()
                    }
                }.padding().background(Color.green).cornerRadius(4.0)
                }.padding().zIndex(0).offset(y: -50)
            if self.showBarcodeScannerView {
                ZStack {
                    BarcodeScannerView(showBarcodeScannerView: self.$showBarcodeScannerView, sourceType: 1)
                    .zIndex(2)
                    Rectangle()
                    .zIndex(1)
                    .foregroundColor(Color.white)
                    Rectangle()
                    .ignoresSafeArea(.all)
                    .zIndex(0)
                    .foregroundColor(Color.seglerRed)
                }.zIndex(1)
            }
        }
    }
}
