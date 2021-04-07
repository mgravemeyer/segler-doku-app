import SwiftUI

struct PDFListDetailView: View {
    
    @ObservedObject var settingsVM: SettingsViewModel
    let pdfDetailUIView: PDFDetailUIView
    
    var body: some View {
        VStack {
            pdfDetailUIView
            Button("Save") {
                pdfDetailUIView.savePDF()
            }
            .navigationBarTitle("\(settingsVM.selectedPDF)".dropLast(4), displayMode: .inline)
        }
    }
}
