import SwiftUI

struct PDFListView: View {

    @Environment(\.presentationMode) var presentationMode
    @Binding var show: Bool
    @EnvironmentObject var mediaVM: MediaViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var remarksVM: RemarksViewModel
    
    var body: some View {
        List {
            ForEach(mediaVM.pdfs, id: \.self) {
                NavigationLink($0.name, destination: PDFListDetailView(selectedPDF: $0, show: self.$show))
                    .frame(height: 34)
            }
            HStack {
                Image(systemName: "archivebox.fill")
                Text("Archiv - - - - - - - - - - - - - -")
            }.foregroundColor(Color.gray)
            ForEach(mediaVM.archive, id: \.self) { pdf in
                    NavigationLink(
                        destination: PDFListDetailView(selectedPDF: pdf, show: self.$show),
                        label: {
                            VStack(alignment: .leading) {
                                Text("Auftrag: \(checkForName(name: pdf.name))")
                                if pdf.pdfName != nil {
                                    Text("Protokoll: \(pdf.pdfName!)")
                                }
                                if pdf.time != nil {
                                    Text("Datum: \(loadDate(date: pdf.time!))")
                                }
                            }
                        })
                    .frame(height: 45).foregroundColor(Color.gray)
            }.navigationTitle("Protokolle").onAppear{
                if self.show != true {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }.listStyle(PlainListStyle())
    }
}

func loadDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy - hh:mm"
    return dateFormatter.string(from: date)
}

func checkForName(name: String) -> String {
    
    let underscoreCount =  name.components(separatedBy:"_")
    
    if (underscoreCount.count-1 == 3) {
    
    let startNr = name.index(name.startIndex, offsetBy: 0)
    let endNr = name.index(name.endIndex, offsetBy: -19)
    let rangeNr = startNr..<endNr
    
    let startPos = name.index(name.startIndex, offsetBy: 6)
    let endPos = name.index(name.endIndex, offsetBy: -16)
    let rangePos = startPos..<endPos
    
    let stringNr = name[rangeNr]
    let stringPos = name[rangePos]
    
    return "\(String(stringNr)).\(String(stringPos))"
        
    } else {
        return name
    }
}
