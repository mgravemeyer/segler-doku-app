import SwiftUI
import PDFKit

struct PDFDetailUIView: UIViewRepresentable {

    init(selectedPDF: PDF) {
        self.selectedPDF = selectedPDF
        pdfView.autoScales = false
    }

    let pdfView = PDFView()

    let selectedPDF: PDF

    func makeUIView(context: Context) -> PDFView {
        print(selectedPDF.name.dropLast(4))
        pdfView.document = PDFDocument(data: selectedPDF.data)
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
