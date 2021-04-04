import SwiftUI

struct PDFListDetailView: View {
    
    init(pdfDetailUIView: PDFDetailUIView, name: String) {
        self.pdfDetailUIView = pdfDetailUIView
        self.name = name
    }
    
    let pdfDetailUIView: PDFDetailUIView
    let name: String
    
    @EnvironmentObject var pdfMediaVM: PDFMediaViewModel
    
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
