import SwiftUI
import PDFKit

struct PDFDetailUIView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedPDF: selectedPDF, saveState: $saveState, pdfView: $pdfView)
    }

    @State var pdfView = PDFView()

    var selectedPDF: PDF
    
    @Binding var saveState: Bool
    
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    class Coordinator: NSObject, PDFViewDelegate {
        
        @Binding var pdfView: PDFView

        var selectedPDF: PDF
        
        @Binding var saveState: Bool
        
        @EnvironmentObject var settingsVM: SettingsViewModel

        init(selectedPDF: PDF, saveState: Binding<Bool>, pdfView: Binding<PDFView>) {
            self.selectedPDF = selectedPDF
            _saveState = saveState
            _pdfView = pdfView
        }
        
    }
    
    init(selectedPDF: PDF, saveState: Binding<Bool>) {
        self.selectedPDF = selectedPDF
        _saveState = saveState
//        pdfView.document = PDFDocument(data: selectedPDF.data)
    }
    


    func makeUIView(context: Context) -> PDFView {
        
        pdfView.document = PDFDocument(data: selectedPDF.data)
        
        pdfView.displayMode = .singlePage
        
        UITextField.appearance().tintColor = .black
//
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        pdfView.autoScales = true
        
        return pdfView
    }
    
    @State fileprivate var shouldDismiss = false

    func updateUIView(_ uiView: PDFView, context: Context) {
        if saveState {
            context.environment.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func forward() {
        pdfView.goToNextPage(nil)
    }
    
    func back() {
        pdfView.goToPreviousPage(nil)
    }

    func savePDF() {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = pdfView.document?.dataRepresentation()
        else {
                print("error while saving or finding files")
                return
            }
        print("new data: \(String(describing: data))")
        settingsVM.savedPDF.data = data
        settingsVM.savedPDF.name = selectedPDF.name
        saveState = false
//        let fileURL = url.appendingPathComponent("\(UUID().uuidString).pdf")
//        do {
//            try data.write(to: fileURL)
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
}
