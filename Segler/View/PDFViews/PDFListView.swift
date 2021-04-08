import SwiftUI

struct PDFListView: View {

    @Environment(\.presentationMode) var presentationMode
    @State var show = true
    @ObservedObject var settingsVM: SettingsViewModel
    
    var body: some View {
        List {
            ForEach(settingsVM.pdfs, id: \.self) {
                NavigationLink($0.name, destination: PDFListDetailView(settingsVM: self.settingsVM, selectedPDF: $0, show: self.$show))
                    .frame(height: 34)
            }.navigationTitle("Protokolle").onAppear{
                if self.show != true {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
//            NavigationLink("saved pdf", destination: PDFListDetailView(settingsVM: self.settingsVM, selectedPDF: settingsVM.savedPDF))
//                .frame(height: 34)
        }
    }
}
