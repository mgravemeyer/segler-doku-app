import SwiftUI

struct SectionRemarks: View {
    
    @EnvironmentObject var remarksVM : RemarksViewModel
    @State var isVisible = Bool()
    @EnvironmentObject var mediaVM: MediaViewModel
    
    let colors = ColorSeglerViewModel()
    @State var editViewVisible = false
    
    var body: some View {
        
        
        if mediaVM.savedPDF.name == "" {
            NavigationLink(destination: ListCommentsView(show: true)) {
                    if remarksVM.selectedComment == "" {
                        Text("Kommentar").foregroundColor(.gray)
                    } else {
                        Text("\(remarksVM.selectedComment)")
                    }
                }.listRowBackground(self.remarksVM.commentIsOk ? colors.correctRowColor : colors.warningRowColor)
        } else {
            HStack {
                NavigationLink(destination: ListCommentsView(show: true)) {
                    Text(mediaVM.savedPDF.name)
                }
                NavigationLink(destination: PDFEditDetailView(saveState: false), isActive: $editViewVisible) { EmptyView() }.frame(width: 0).hidden().labelsHidden().buttonStyle((BorderlessButtonStyle())).zIndex(-100000).disabled(true)
                Button(action: {
                    editViewVisible.toggle()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(colors.color)
                        .buttonStyle(BorderlessButtonStyle())
                }.buttonStyle(BorderlessButtonStyle()).frame(width: 30).frame(height: 30)
            }
        }
    }
}
