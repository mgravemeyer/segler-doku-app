import SwiftUI
import PDFKit

struct PDFListDetailView: View {
    
    @ObservedObject var settingsVM: SettingsViewModel
    let selectedPDF: PDF
    let pdfDetailUIView: PDFDetailUIView
    
    var body: some View {
        VStack {
            pdfDetailUIView
            Button("Save") {
                pdfDetailUIView.savePDF()
            }
            .navigationBarTitle("\(settingsVM.selectedPDF.name)".dropLast(4), displayMode: .inline)
        }.onAppear {
            settingsVM.selectedPDF = selectedPDF
        }
    }
}
