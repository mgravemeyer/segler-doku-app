import SwiftUI

struct ListCommentsView: View {
    
    @EnvironmentObject var remarksVM : RemarksViewModel
    @Environment(\.presentationMode) var presentationMode
    
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
            }.navigationBarTitle("Kategorien", displayMode: .inline).listStyle(PlainListStyle()).onAppear{
                if self.show != true {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
    }
}
