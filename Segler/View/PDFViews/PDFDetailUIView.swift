import SwiftUI
import PDFKit

struct PDFDetailUIView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedPDF: $selectedPDF, saveState: $saveState, settingsVM: _settingsVM)
    }
    

    @State var pdfView = PDFView()

    @Binding var selectedPDF: PDF
    
    @Binding var saveState: Bool
    
    @ObservedObject var settingsVM: SettingsViewModel
    
    class Coordinator: NSObject, PDFViewDelegate {

        @Binding var selectedPDF: PDF
        
        @Binding var saveState: Bool
        
        @ObservedObject var settingsVM: SettingsViewModel

        init(selectedPDF: Binding<PDF>, saveState: Binding<Bool>, settingsVM: ObservedObject<SettingsViewModel>) {
            _selectedPDF = selectedPDF
            _saveState = saveState
            _settingsVM = settingsVM
        }
        
        
    }
    
    init(selectedPDF: Binding<PDF>, saveState: Binding<Bool>, settingsVM: ObservedObject<SettingsViewModel>) {
        _selectedPDF = selectedPDF
        _saveState = saveState
        _settingsVM = settingsVM
    }

    func makeUIView(context: Context) -> PDFView {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        pdfView.autoScales = false
        pdfView.document = PDFDocument(data: selectedPDF.data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        
        if saveState {
            savePDF()
            print(settingsVM.savedPDF)
            
        }
        
    }

    func savePDF() {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = pdfView.document?.dataRepresentation()
        else {
                print("error while saving or finding files")
                return
            }
        print("new data: \(String(describing: pdfView.document!.dataRepresentation()))")
        settingsVM.savedPDF.data = data
        settingsVM.selectedPDF.name = "test"
        saveState = false
        let fileURL = url.appendingPathComponent("\(UUID().uuidString).pdf")
        do {
            try data.write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
