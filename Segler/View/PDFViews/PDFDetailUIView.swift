import SwiftUI
import PDFKit

struct PDFDetailUIView: UIViewRepresentable {

    init(selectedPDF: PDF) {
        self.selectedPDF = selectedPDF
        pdfView.autoScales = true
    }

    let pdfView = PDFView()

    let selectedPDF: PDF

    func makeUIView(context: Context) -> PDFView {
        let fileURL = Bundle.main.url(forResource: "samplePdf", withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {

    }

    func savePDF() {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = pdfView.document!.dataRepresentation()
        else {
                print("error while finding files")
                return
            }
        let fileURL = url.appendingPathComponent("\(UUID().uuidString).pdf")
        do {
            try data.write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}
