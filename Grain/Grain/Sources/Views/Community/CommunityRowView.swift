//
//  CommunityRowView.swift
//  Grain
//
//  Created by 박희경 on 2023/01/18.
//

import SwiftUI

import Kingfisher

struct CommunityRowView: View {
    @ObservedObject var commentVm: CommentViewModel
    
    @State var opacity: Double = 0.8
    
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
    
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                KFImage(URL(string: community.fields.image.arrayValue.values[0].stringValue) ?? URL(string:"https://cdn.travie.com/news/photo/202108/21951_11971_5847.jpg"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: Screen.maxWidth*0.27, height: Screen.maxWidth*0.27)
                    .clipped()
                    .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                    .padding(.horizontal, 13)
                
                VStack {
                    VStack(alignment: .leading){
                        //MARK: 게시글 태그
                        HStack {
                            
                            Text("\(community.fields.category.stringValue)")
                                .padding(.vertical, 5)
                                .padding(.horizontal, 8)
                                .background(Color(hex: "F58800"))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                .bold()
                                .font(.caption)
                                .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                            
                            Text(community.fields.state.stringValue)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 8)
                                .background(Color(hex: tagColor))
                                .cornerRadius(20)
                                .foregroundColor(Color(hex: tagNameColor))
                                .bold()
                                .font(.caption)
                                .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                        } // hstack
                        .padding(.top, 4)
                
                        //MARK: 게시글 제목
                        Text("\(community.fields.title.stringValue)")
                            .font(.callout)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .padding(.top, -2)
                            .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                            .lineLimit(2)
                            .frame(height: 45)
               
                        HStack {
                            Text(community.createdDate?.renderTime() ?? "")
                                .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                            Spacer()
                            Image(systemName: "text.bubble")
                                .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                            Text("\(commentVm.comment.count)")
                                .setSkeletonView(opacity: opacity, shouldShow: isLoading)
                                    .padding(.leading, -5)
                        }
                        .padding(.bottom, 4)
                        .foregroundColor(.secondary)
                        .font(.caption)
                    }
                    .frame(height: 100)
                    .padding(.trailing, 13)
                    .padding(.leading, -3)
                }//VStack
            }
            Divider()
                .padding(.top, 5)
            
        }
        .padding(.top, 5)
        .onAppear(perform: {
            if isLoading == true {
                withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                    self.opacity = opacity == 0.4 ? 0.8 : 0.4
                }
            }
        })
        .frame(width: Screen.maxWidth, height: Screen.maxHeight * 0.17)
    }
}

//struct CommunityRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunityRowView(community: CommunityDocument(name: "abc", fields: CommunityFields(title: CommunityCategory(stringValue: "임시 타이틀입니다 줄을 길게 해볼거에요 라인리미트를 2줄로 할거거덩요"), category: CommunityCategory(stringValue: "매칭중"), content: CommunityCategory(stringValue: "content"), profileImage: CommunityCategory(stringValue: "test"), nickName: CommunityCategory(stringValue: "han"), image: CommunityImage(arrayValue: CommunityArrayValue(values: [CommunityCategory(stringValue: "abc")])), userID: CommunityCategory(stringValue: "seungsoo"), id: CommunityCategory(stringValue: "123")), createTime: "2023-02-03", updateTime: "방금"))
//    }
//}

