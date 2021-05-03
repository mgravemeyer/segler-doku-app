import SwiftUI

struct SectionFreeTextFieldView: View {
    
    @EnvironmentObject var remarksVM : RemarksViewModel
    
    var body: some View {
        HStack {
            if #available(iOS 14.0, *) {
                ZStack(alignment: .leading) {
                    if remarksVM.additionalComment == "" {
                        Text("Freitext").zIndex(2).foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                    }
                    TextEditor(text: $remarksVM.additionalComment)
                        .padding(.leading, -5)
                        .zIndex(1)
                        .accentColor(Color.seglerRed)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .lineLimit(nil)
                    Text(remarksVM.additionalComment).opacity(0).padding(.all, 10)
                }
            } else {
                TextField("Freitextfeld", text: $remarksVM.additionalComment)
                .frame(width: 200)
                    .accentColor(Color.seglerRed)
                .keyboardType(.alphabet)
                .disableAutocorrection(true)
                .lineLimit(nil)
            }
            if remarksVM.additionalComment != "" {
                Button(action: {
                    self.remarksVM.additionalComment = ""
                }) {
                    Image("Delete")
                        .renderingMode(.template)
                        .offset(x: 2)
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(Color.seglerRed)
                }.buttonStyle(BorderlessButtonStyle()).frame(width: 30)
            }
        }
    }
}
