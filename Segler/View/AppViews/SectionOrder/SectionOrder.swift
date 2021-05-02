import SwiftUI

struct SectionOrder: View {
    
    @EnvironmentObject var orderVM : OrderViewModel
    
    @Binding var showBarcodeScannerView: Bool
    
    var body: some View {
                HStack {
                    TextField("Auftrags-Nr", text: $orderVM.orderNr)
                        .frame(width: UIScreen.main.bounds.width - 70)
                        .disableAutocorrection(true)
                        .keyboardType(.numbersAndPunctuation)
                    Button(action: {
                        UIApplication.shared.endEditing()
                        self.showBarcodeScannerView = true
                    }) {
                        Image("QR-Icon")
                        .resizable()
                        .frame(width: 33, height: 33)
                        .foregroundColor(Color.seglerRed)
                    }.buttonStyle(BorderlessButtonStyle()).zIndex(1000000)
                }.listRowBackground(self.orderVM.orderNrIsOk ? Color.white : Color.seglerRowWarning)
                TextField("Auftrags-Position", text: $orderVM.orderPosition)
                    .keyboardType(.numbersAndPunctuation)
                    .listRowBackground(self.orderVM.orderPositionIsOk ? Color.white : Color.seglerRowWarning)
                    .disableAutocorrection(true)
    }
}
