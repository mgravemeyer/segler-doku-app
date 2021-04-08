import SwiftUI
import PDFKit

struct PDFListDetailView: View {
    
    @ObservedObject var settingsVM: SettingsViewModel
    @State var selectedPDF: PDF
    @State var saveState = false
    
    var body: some View {
        var pdf = PDFDetailUIView(selectedPDF: $selectedPDF, saveState: $saveState, settingsVM: self._settingsVM)
        pdf
        .navigationBarTitle("\(settingsVM.selectedPDF.name)", displayMode: .inline)
//        .onAppear {
//            settingsVM.selectedPDF = selectedPDF
//        }
            .navigationBarItems(trailing: Button("Speichern", action: {
                pdf.savePDF()
            }))
    }
}
