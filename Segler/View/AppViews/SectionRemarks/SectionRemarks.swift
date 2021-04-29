import SwiftUI

struct SectionRemarks: View {
    
    @EnvironmentObject var remarksVM : RemarksViewModel
    @State var isVisible = Bool()
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    let colors = ColorSeglerViewModel()
    @State var editViewVisible = false
    
    var body: some View {
        
        
        if settingsVM.savedPDF.name == "" {
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
                    Text(settingsVM.savedPDF.name)
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

struct ListCommentsView: View {
    
    @EnvironmentObject var remarksVM : RemarksViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var settingsVM: SettingsViewModel
    let colors = ColorSeglerViewModel()
    @State var editViewVisible = false
    @State var fakeBool = false
    
    @State var show = true
    
    var body: some View {

            List {
                ForEach(0..<self.remarksVM.comments.count, id: \.self) { x in
                    NavigationLink(destination: ListCommentsDetailView(selection: x, show: self.$show)) {
                        Text("\(self.remarksVM.comments[x].title)")
                            .frame(height: 34)
                    }
                }
                NavigationLink(destination: PDFListView(show: $show)) {
                    HStack {
                        Image(systemName: "newspaper.fill")
                        Text("Protokoll")
                    }.frame(height: 34)
                }.frame(height: 34)
            }.navigationBarTitle("Kategorien", displayMode: .inline).onAppear{
                if self.show != true {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.onAppear {
                
        }
    }
}

struct ListCommentsDetailView: View {
    let selection : Int
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var remarksVM : RemarksViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var show : Bool
    
    var body: some View {
        List {
            ForEach(0..<self.remarksVM.comments[self.selection].comments.count, id: \.self) { x in
                Button(action: {
                    self.remarksVM.selectedComment = self.remarksVM.comments[self.selection].comments[x]
                    self.settingsVM.savedPDF = PDF(name: "", data: Data())
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
