import SwiftUI

struct PDFListView: View {

    @ObservedObject var settingsVM: SettingsViewModel

    var body: some View {
        List {
            ForEach(settingsVM.pdfs, id: \.self) {
                NavigationLink($0.name.dropLast(4), destination: PDFListDetailView(settingsVM: self.settingsVM, selectedPDF: $0, pdfDetailUIView: PDFDetailUIView(selectedPDF: $0))).frame(height: 34)
            }
        }
    }
}
