import SwiftUI
import PDFKit

struct PDFListDetailView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var remarksVM : RemarksViewModel
    var selectedPDF: PDF
    @State var saveState = false
    @Binding var show: Bool
    
    var body: some View {
        let pdf = PDFDetailUIView(selectedPDF: selectedPDF, saveState: $saveState, settingsVM: self._settingsVM)
        return ZStack {
            pdf
                .navigationBarTitle("\(selectedPDF.name)", displayMode: .inline)
                .navigationBarItems(trailing: Button("Speichern", action: {
                    pdf.savePDF()
                    settingsVM.savedPDF.name = "\(selectedPDF.name)"
                    remarksVM.selectedComment = ""
                    print(settingsVM.savedPDF)
                    saveState = true
                    show = false
                })).zIndex(0)
            VStack {
                Spacer()
                HStack {
                    
                    Button {
                        pdf.back()
                    } label: {
                        ZStack {
                            Image(systemName: "arrowshape.turn.up.left").zIndex(1)
                            RoundedRectangle(cornerRadius: 20).frame(width: 80, height: 40).foregroundColor(ColorSeglerViewModel().color).zIndex(0)
                        }
                    }.zIndex(100)
                    
                    Button {
                        pdf.forward()
                    } label: {
                        ZStack {
                            Image(systemName: "arrowshape.turn.up.right").zIndex(1)
                            RoundedRectangle(cornerRadius: 20).frame(width: 80, height: 40).foregroundColor(ColorSeglerViewModel().color).zIndex(0)
                        }
                    }.zIndex(100)
                    
                }.padding(.bottom, 10)
            }
        }
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
