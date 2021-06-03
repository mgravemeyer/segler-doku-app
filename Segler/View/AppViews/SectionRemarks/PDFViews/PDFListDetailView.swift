import SwiftUI
import PDFKit

struct PDFListDetailView: View {
    @EnvironmentObject var mediaVM: MediaViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    var selectedPDF: PDF
    @State var saveState = false
    @Binding var show: Bool
    
    var body: some View {
        let pdf = PDFDetailUIView(selectedPDF: selectedPDF, saveState: $saveState, mediaVM: _mediaVM)
        return ZStack {
            pdf
                .environmentObject(mediaVM)
                .navigationBarTitle("\(checkForName(name: selectedPDF.name)) \(selectedPDF.isArchive ? " - \(selectedPDF.pdfName ?? "")" : "")", displayMode: .inline)
                .navigationBarItems(trailing: Button("Speichern", action: {
                    pdf.savePDF()
                    if selectedPDF.isArchive {
                        mediaVM.savedPDF.name = selectedPDF.name
                        mediaVM.savedPDF.isArchive = true
                        mediaVM.savedPDF.time = selectedPDF.time!
                        mediaVM.savedPDF.pdfName = selectedPDF.pdfName!
                    } else {
                        mediaVM.savedPDF.name = selectedPDF.name
                        mediaVM.savedPDF.isArchive = false
                        mediaVM.savedPDF.time = nil
                        mediaVM.savedPDF.pdfName = nil
                    }
                    remarksVM.selectedComment = ""
                    print(mediaVM.savedPDF)
                    saveState = true
                    self.show = false
                })).zIndex(0)
            VStack {
                Spacer()
                HStack {
                    
//                    Button {
//                        pdf.back()
//                    } label: {
//                        ZStack {
//                            Image(systemName: "arrowshape.turn.up.left").zIndex(1)
//                            RoundedRectangle(cornerRadius: 20).frame(width: 80, height: 40).foregroundColor(Color.seglerRed).zIndex(0)
//                        }
//                    }.zIndex(100)
//
//                    Button {
//                        pdf.forward()
//                    } label: {
//                        ZStack {
//                            Image(systemName: "arrowshape.turn.up.right").zIndex(1)
//                            RoundedRectangle(cornerRadius: 20).frame(width: 80, height: 40).foregroundColor(Color.seglerRed).zIndex(0)
//                        }
//                    }.zIndex(100)
                    
                }.padding(.bottom, 10)
            }
        }
    }
}

struct PDFEditDetailView: View {
    
    @EnvironmentObject var mediaVM: MediaViewModel
    @State var saveState = false
    
    var body: some View {
        let pdf = PDFDetailUIView(selectedPDF: mediaVM.savedPDF, saveState: $saveState, mediaVM: _mediaVM)
        return ZStack {
            pdf
            .environmentObject(mediaVM)
                .navigationBarTitle("\(checkForName(name: mediaVM.savedPDF.name)) \(mediaVM.savedPDF.isArchive ? " - \(mediaVM.savedPDF.pdfName ?? "")" : "")", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern", action: {
                pdf.savePDF()
                saveState = true
            }))
            VStack {
                Spacer()
                HStack {
                    
//                    Button {
//                        pdf.back()
//                    } label: {
//                        ZStack {
//                            Image(systemName: "arrowshape.turn.up.left").zIndex(1)
//                            RoundedRectangle(cornerRadius: 20).frame(width: 80, height: 40).foregroundColor(Color.seglerRed).zIndex(0)
//                        }
//                    }.zIndex(100)
//                    
//                    Button {
//                        pdf.forward()
//                    } label: {
//                        ZStack {
//                            Image(systemName: "arrowshape.turn.up.right").zIndex(1)
//                            RoundedRectangle(cornerRadius: 20).frame(width: 80, height: 40).foregroundColor(Color.seglerRed).zIndex(0)
//                        }
//                    }.zIndex(100)
                    
                }.padding(.bottom, 10)
            }
        }
    }
}
