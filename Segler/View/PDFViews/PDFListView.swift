import SwiftUI

struct PDFListView: View {

    @ObservedObject var settingsVM: SettingsViewModel
    
    var body: some View {
        List {
            ForEach(settingsVM.pdfs, id: \.self) {
                NavigationLink($0.name, destination: PDFListDetailView(settingsVM: self.settingsVM, selectedPDF: $0))
                    .frame(height: 34)
            }.navigationTitle("Protokolle")
//            NavigationLink("saved pdf", destination: PDFListDetailView(settingsVM: self.settingsVM, selectedPDF: settingsVM.savedPDF))
//                .frame(height: 34)
        }
    }
}
