import SwiftUI

struct PDFListView: View {

    @Environment(\.presentationMode) var presentationMode
    @Binding var show: Bool
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var remarksVM: RemarksViewModel
    
    var body: some View {
        List {
            ForEach(settingsVM.pdfs, id: \.self) {
                NavigationLink($0.name, destination: PDFListDetailView(settingsVM: self.settingsVM, remarksVM: self.remarksVM, selectedPDF: $0, show: self.$show))
                    .frame(height: 34)
            }
            HStack {
                Image(systemName: "archivebox.fill")
                Text("Archiv - - - - - - - - - - - - - -")
            }.foregroundColor(Color.gray)
            ForEach(settingsVM.archive, id: \.self) {
                NavigationLink($0.name, destination: PDFListDetailView(settingsVM: self.settingsVM, remarksVM: self.remarksVM, selectedPDF: $0, show: self.$show))
                    .frame(height: 34).foregroundColor(Color.gray)
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
