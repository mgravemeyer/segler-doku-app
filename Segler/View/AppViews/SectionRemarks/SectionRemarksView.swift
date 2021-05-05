import SwiftUI

struct SectionRemarksView: View {
    
    @EnvironmentObject var remarksVM : RemarksViewModel
    @State var isVisible = Bool()
    @EnvironmentObject var mediaVM: MediaViewModel
    
    @State var editViewVisible = false
    
    var body: some View {
        
        
        if mediaVM.savedPDF.name == "" {
            NavigationLink(destination: ListCommentsView(show: true)) {
                    if remarksVM.selectedComment == "" {
                        Text("Kommentar oder Protokoll").foregroundColor(.gray)
                    } else {
                        Text("\(remarksVM.selectedComment)")
                    }
            }.listRowBackground(self.remarksVM.commentIsOk ? Color.white : Color.seglerRowWarning)
        } else {
            HStack {
                VStack {
                    Divider().offset(y: -7).ignoresSafeArea(.keyboard, edges: .trailing)
                        NavigationLink(destination: ListCommentsView(show: true)) {
                        Text(mediaVM.savedPDF.name)
                    }
                }
                NavigationLink(destination: PDFEditDetailView(saveState: false), isActive: $editViewVisible) { EmptyView() }.frame(width: 0).hidden().labelsHidden().buttonStyle((BorderlessButtonStyle())).zIndex(-100000).disabled(true)
                Button(action: {
                    editViewVisible.toggle()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.seglerRed)
                        .buttonStyle(BorderlessButtonStyle())
                }.buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}
