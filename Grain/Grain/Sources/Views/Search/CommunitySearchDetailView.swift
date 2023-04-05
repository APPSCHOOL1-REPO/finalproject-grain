//
//  CommunitySearchDetailView.swift
//  Grain
//
//  Created by 조형구 on 2023/02/07.
//

import SwiftUI
import Kingfisher

struct CommunitySearchDetailView: View {
    @ObservedObject var communtyViewModel: CommunityViewModel = CommunityViewModel()
    
    @State private var isBookMarked: Bool = false
    @State private var isliked: Bool = false
    @State private var comment: String = ""
    @State private var isHiddenComment: Bool = true
    
    @FocusState private var textFieldFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    let community: CommunityDocument
    
    func errorImage() -> String{
        var https : String = "https://"
        if let infolist = Bundle.main.infoDictionary {
            if let url = infolist["ThumbnailImageError"] as? String {
                https += url
            }
        }
        return https
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("커뮤니티")
                        }
                        .padding(.horizontal, 10)
                    })
                    .accentColor(.black)
                    
                    //MARK: 게시글(디테일뷰) 제목
                    VStack(alignment: .leading) {
                        Text("\(community.fields.title.stringValue)")
                            .multilineTextAlignment(.leading)
                            .font(.title)
                            .bold()
             
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    
                    TabView {
                        KFImage(URL(string: community.fields.image.arrayValue.values[0].stringValue) ?? URL(string: errorImage()))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Screen.maxWidth, height: Screen.maxHeight * 0.3)                        
                    } //이미지 뷰
                    .tabViewStyle(.page)
                    .frame(height: Screen.maxHeight * 0.3)
                    
                    //MARK: 작성자 정보
                    HStack {
                        ProfileImage(imageName: community.fields.profileImage.stringValue)
                        Text(community.fields.nickName.stringValue)
                            .font(.title3)
                            .bold()
                    }
                    .padding(.horizontal, 10)
                    
                    Text(community.fields.content.stringValue)
                        .padding(.horizontal, 10)
                    
                    HStack {
                        Button{
                            isliked.toggle()
                        } label: {
                            if isliked {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            } else {
                                Image(systemName: "heart")
                                    .foregroundColor(.black)
                                    .font(.title2)
                            }
                        }

                        Button {
                            //댓글 입력 키보드 팝업
                            isHiddenComment.toggle()
                            textFieldFocused = true
                        } label: {
                            Image(systemName: "message")
                                .font(.title3)
                                .foregroundColor(.black)
                        }

                        //MARK: 북마크 버튼
                        Button {
                            isBookMarked.toggle()
                        } label: {
                            Image(systemName: isBookMarked ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        
                        

                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 1)
                } // top vstack
            } //scroll view
            
            //MARK: 댓글입력 창
            if !isHiddenComment {
                HStack {
                    TextField("댓글을 입력해주세요", text: $comment)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .focused($textFieldFocused)
                        .onSubmit {
                            self.hideKeyboard()
                            isHiddenComment = true
                            comment = ""
                        }
                    
                    Spacer()
                    
                    Button {
                        // 댓글추가 동작 함수
                        self.hideKeyboard()
                        isHiddenComment = true
                        comment = ""
                    } label: {
                        Image(systemName: "paperplane")
                            .foregroundColor(.blue)
                            .font(.title3)
                            .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            self.hideKeyboard()
            isHiddenComment = true
            comment = ""
        }
    }
}

//struct CommunitySearchDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunitySearchDetailView(community: CommunityDocument(name: "승수", fields: CommunityFields(title: CommunityCategory(stringValue: "임시 제목"), category: CommunityCategory(stringValue: "클래스"), content: CommunityCategory(stringValue: "가나다라마바사아자차카타파하갸냐댜랴먀뱌샤야쟈챠캬탸퍄햐 거너더러머버서어저처커터퍼허 겨녀뎌려며벼셔여져쳐켜텨벼혀"), profileImage: CommunityCategory(stringValue: "test"), nickName: CommunityCategory(stringValue: "seungsoo"), image: CommunityImage(arrayValue: CommunityArrayValue(values: [CommunityCategory(stringValue: "abc")])), userID: CommunityCategory(stringValue: "클래스"), id: CommunityCategory(stringValue: "han")), createTime: "2023-02-03", updateTime: "지금"))
//    }
//}
