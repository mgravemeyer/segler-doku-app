import SwiftUI

struct SectionOrder: View {

    let colors = ColorSeglerViewModel()
    @EnvironmentObject var orderVM : OrderViewModel
    @EnvironmentObject var mediaVM : MediaViewModel
    
    var body: some View {
                HStack {
                    TextField("Auftrags-Nr", text: $orderVM.orderNr)
                        .frame(width: UIScreen.main.bounds.width - 70)
                        .disableAutocorrection(true)
                        .keyboardType(.numbersAndPunctuation)
                    Button(action: {
                        UIApplication.shared.endEditing()
                        self.mediaVM.showImageScanner = true
                    }) {
                        Image("QR-Icon")
                        .resizable()
                        .frame(width: 33, height: 33)
                        .foregroundColor(self.colors.color)
                    }.buttonStyle(BorderlessButtonStyle()).zIndex(1000000)
                }.listRowBackground(self.orderVM.orderNrIsOk ? colors.correctRowColor : colors.warningRowColor)
                TextField("Auftrags-Position", text: $orderVM.orderPosition)
                    .keyboardType(.numbersAndPunctuation)
                    .listRowBackground(self.orderVM.orderPositionIsOk ? colors.correctRowColor : colors.warningRowColor)
                .disableAutocorrection(true).accentColor(colors.color)
    }
}
