import SwiftUI

struct ListCommentsDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var mediaVM: MediaViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    
    let selection : Int
    @Binding var show : Bool
    
    var body: some View {
        List {
            ForEach(0..<self.remarksVM.comments[self.selection].comments.count, id: \.self) { x in
                Button(action: {
                    self.remarksVM.selectedComment = self.remarksVM.comments[self.selection].comments[x]
                    self.mediaVM.savedPDF = PDF(name: "", data: Data(), isArchive: false)
                    self.show = false
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("\(self.remarksVM.comments[self.selection].comments[x])")
                        .frame(height: 34)
                }
            }.onAppear {
                self.remarksVM.bereich = self.remarksVM.comments[self.selection].title
            }
        }.navigationBarTitle("Kommentare", displayMode: .inline)
    }
}
