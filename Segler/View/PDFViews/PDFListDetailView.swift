import SwiftUI

struct PDFListDetailView: View {
    
    init(pdfDetailUIView: PDFDetailUIView, name: String) {
        self.pdfDetailUIView = pdfDetailUIView
        self.name = name
    }
    
    @ObservedObjet var settingsVM: SettingsViewModel
    let pdfDetailUIView: PDFDetailUIView
    let name: String
    
    var body: some View {
        VStack {
            pdfDetailUIView
            Button("Save") {
                pdfDetailUIView.savePDF()
                pdfMediaVM.addPDF(name: self.name)
            }
            .navigationBarTitle("\(name)".dropLast(4), displayMode: .inline)
        }
    }
}
