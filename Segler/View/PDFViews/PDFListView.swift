import SwiftUI

struct PDFListView: View {

    @ObservedObject var settingsVM: SettingsViewModel

    var body: some View {
        List {
            ForEach(settingsVM.pdfs, id: \.self) {
                NavigationLink($0.name, destination: PDFListDetailView(pdfDetailUIView: PDFDetailUIView(selection: settingsVM.selectedPDF)))
//                PDFListRowView(selectedPDF: $0)
            }
        }
    }
}
//
//struct PDFListRowView: View {
//
//    let selectedPDF: PDF
//
//    var body: some View {
//        HStack {
//            NavigationLink(String(name).dropLast(4), destination: PDFListDetailView(pdfDetailUIView: PDFDetailUIView(selection: name), name: name))
//            Button("Delete") {
//                pdfMediaVM.deletePDFFileManager(selection: name)
//            }
//        }
//    }
//}
//
//struct PDFListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PDFListView()
//    }
//}
