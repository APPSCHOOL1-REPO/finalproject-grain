import SwiftUI

struct MagazineDetailView: View {
    var data : MagazineDocument
    var body: some View {
        ScrollView {
             VStack{
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 40)
                            VStack(alignment: .leading) {
                                Text(data.fields.nickName.stringValue)
                                    .bold()
                                HStack {
                                    Text("1분전")
                                    Spacer()
                                    Text(data.fields.customPlaceName.stringValue)
                                }
                                .font(.caption)
                            }
                            Spacer()
                        }
                        .padding()
                        Divider()
                            .frame(maxWidth: Screen.maxWidth * 0.9)
                            .background(Color.black)
                            .padding(.top, -5)
                            .padding(.bottom, -10)
                        
                        //            Image("line")
                        //                .resizable()
                        //                .frame(width: Screen.maxWidth, height: 0.3)
                        TabView{
                            ForEach(1..<4, id: \.self) { i in
                                Image("\(i)")
                                    .resizable()
                                    .frame(width: Screen.maxWidth, height: Screen.maxWidth * 0.6)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(maxHeight: Screen.maxHeight * 0.27)
                        .padding()
                }
                .frame(minHeight: 350)
                 
                 LazyVStack(pinnedViews: [.sectionHeaders]) {
                     Section(header: Header(data: data) ){
                         VStack {
                             Text(data.fields.content.stringValue)
                                 .padding(.vertical, -5)
                                 .padding()
                                 .foregroundColor(Color.textGray)
                         }
                     }
                 }
                 Spacer()
            }
        }
        .padding(.top, 1)
    }
}
struct Header: View {
    var data : MagazineDocument
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(data.fields.title.stringValue)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            Spacer()
            Divider()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 56)
        .background(Rectangle().foregroundColor(.white))
    }
}
//struct MagazineDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            MagazineDetailView()
//        }
//
//    }
//}
