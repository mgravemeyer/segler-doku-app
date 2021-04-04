//import SwiftUI
//
//struct PDFListView: View {
//    
//    @EnvironmentObject var pdfMediaVM: PDFMediaViewModel
//    
//    var body: some View {
//        ScrollView(.vertical, showsIndicators: true) {
//            VStack {
//                ForEach(pdfMediaVM.pdfNameList, id: \.self) {
//                    PDFListRowView(name: $0)
//                }
//            }
//        }.navigationBarTitle("Stored PDF's List", displayMode: .large)
//    }
//}
//
//struct PDFListRowView: View {
//    
//    let name: String
//    @EnvironmentObject var pdfMediaVM: PDFMediaViewModel
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
