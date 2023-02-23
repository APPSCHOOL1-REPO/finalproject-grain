//
//  CommunityRowView.swift
//  Grain
//
//  Created by 박희경 on 2023/01/18.
//

import SwiftUI
//import FirebaseFirestore  /// PodFile - Firebase SDK 제거 -> 필요시 사용하기  ( 2022.02.22 / 정훈 )
import Kingfisher
/*
 id:String
 category: Int
 userId: String
 image: [String]
 title: string
 
 location: String
 content: string
 createdAt: TimeStamp
 */

struct CommunityRowView: View {
    
    @StateObject var commentVm: CommentViewModel = CommentViewModel()
    var tagColor: String {
        switch community.fields.state.stringValue {
        case "모집중", "판매중", "Tip":
            return "#F8BC24"
        case "모집완료", "판매완료":
            return "#A0A0A0"
        default:
            return "F8BC24"
        }
    }
    
    var tagNameColor: String {
        switch community.fields.state.stringValue {
        case "모집중", "판매중", "Tip":
            return "#616161"
        case "모집완료", "판매완료":
            return "#FFFFFF"
        default:
            return "616161"
        }
    }
    
    var community: CommunityDocument
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                KFImage(URL(string: community.fields.image.arrayValue.values[0].stringValue) ?? URL(string:"https://cdn.travie.com/news/photo/202108/21951_11971_5847.jpg"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: Screen.maxWidth*0.27, height: Screen.maxWidth*0.27)
                    .clipped()
                    .padding(.horizontal, 13)
                    //.padding(.top, 5)
                
                VStack {
                    VStack(alignment: .leading){
                        //MARK: 게시글 태그
                        HStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 45, height: 25)
                                .foregroundColor(Color(hex: "F58800"))
                                .overlay{
                                    Text("\(community.fields.category.stringValue)")
                                        .foregroundColor(.white)
                                        .bold()
                                        .font(.caption)
                                }
                                
                                .padding(.leading, -3)
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 45, height: 25)
                                .foregroundColor(Color(hex: tagColor))
                                .overlay{
                                    Text(community.fields.state.stringValue)
                                        .foregroundColor(Color(hex: tagNameColor))
                                        .bold()
                                        .font(.caption)
                                }
                                .padding(.leading, 3)
                        } // hstack
                        .padding(.top, 4)
                       // .padding(.vertical, 3)
                        
                       // Spacer()
                        
                        //MARK: 게시글 제목
                        Text("\(community.fields.title.stringValue)")
                            .font(.callout)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .frame(height: 45)
                            .padding(.top, -2)
                            
    //                        .padding(.bottom, 3)
                        
                        // Spacer()
                        
                        HStack {
                            // String.toDate(community.createTime)
                            Text(community.createdDate?.renderTime() ?? "")
                            Spacer()
                            Image(systemName: "text.bubble")
                            Text("\(commentVm.comment.count)")
                                    .padding(.leading, -5)
                        }
                        .padding(.bottom, 4)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        //.padding(.trailing, 10)
                    }
                    .frame(height: 100)
                    .padding(.trailing, 13)
                    .padding(.leading, -3)
                }//vstack
            }
            Divider()
                .padding(.top, 5)
            
        }
        .padding(.top, 5)
        .onAppear{
            commentVm.fetchComment(collectionName: "Community",
                                   collectionDocId: community.fields.id.stringValue)
            commentVm.sortByRecentComment()
        }
    }
}

//struct CommunityRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunityRowView(community: CommunityDocument(name: "abc", fields: CommunityFields(title: CommunityCategory(stringValue: "임시 타이틀입니다 줄을 길게 해볼거에요 라인리미트를 2줄로 할거거덩요"), category: CommunityCategory(stringValue: "매칭중"), content: CommunityCategory(stringValue: "content"), profileImage: CommunityCategory(stringValue: "test"), nickName: CommunityCategory(stringValue: "han"), image: CommunityImage(arrayValue: CommunityArrayValue(values: [CommunityCategory(stringValue: "abc")])), userID: CommunityCategory(stringValue: "seungsoo"), id: CommunityCategory(stringValue: "123")), createTime: "2023-02-03", updateTime: "방금"))
//    }
//}

