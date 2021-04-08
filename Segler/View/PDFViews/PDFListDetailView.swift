import SwiftUI
import PDFKit

struct PDFListDetailView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    var selectedPDF: PDF
    @State var saveState = false
    @Binding var show: Bool
    
    var body: some View {
        let pdf = PDFDetailUIView(selectedPDF: selectedPDF, saveState: $saveState, settingsVM: self._settingsVM)
        pdf
            .navigationBarTitle("\(selectedPDF.name)", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern", action: {
                pdf.savePDF()
                settingsVM.savedPDF.name = "\(selectedPDF.name)"
                saveState = true
                show = false
            }))
    }
}

struct PDFEditDetailView: View {
    
    @ObservedObject var settingsVM: SettingsViewModel
    @State var saveState = false
    
    var body: some View {
        let pdf = PDFDetailUIView(selectedPDF: settingsVM.savedPDF, saveState: $saveState, settingsVM: self._settingsVM)
        pdf
            .navigationBarTitle("\(settingsVM.savedPDF.name)", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern", action: {
                pdf.savePDF()
                saveState = true
            }))
    }
}
