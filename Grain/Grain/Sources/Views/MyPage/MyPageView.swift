//
//  MyPageView.swift
//  Grain
//
//  Created by 한승수 on 2023/01/31.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct MyPageView: View {
    
    // MARK: docID -> 파이어스토어 User -> 문서ID 값 유저마다 고유의 값으로 들어가야 될듯
    
    @StateObject var userVM = UserViewModel()
    @ObservedObject var magazineVM: MagazineViewModel
    var magazineDocument: [MagazineDocument]
    var boomarkedMagazineDocument: [MagazineDocument]
    var bookmarkedCommunityDoument: [CommunityDocument]
    
    @State private var showDevices: Bool = false
    @State private var angle: Double = 0
    //    @State var transitionView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading){
                    HStack{
                        //MARK: 프로필 이미지
                        KFImage(URL(string: userVM.currentUsers?.profileImage.stringValue ?? "") ?? URL(string:"https://cdn.travie.com/news/photo/202108/21951_11971_5847.jpg"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 85, height: 85)
                            .cornerRadius(64)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.1)
                            }
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading){
                            Text(userVM.currentUsers?.nickName.stringValue ?? "123456789101789")
                                .font(.title3)
                                .bold()
                                .padding(.leading, 8)
                                .padding(.bottom, 1)
                            
                            VStack(alignment: .leading){
                                HStack{
                                    Text("매거진")
                                    Text("\(userVM.postedMagazineID.count - 1)")
                                        .padding(.leading, -5)
                                        .bold()
                                }
                                .padding(.leading, 9)
                                .padding(.bottom, 1)
                                .foregroundColor(.textGray)
                                .font(.footnote)
                                
                                HStack{
                                    NavigationLink {
                                        CurrentUserFollowerListView(userVM: userVM)
                                    } label: {
                                        Text("구독자")
                                    }
                                    
                                    Text("\(userVM.follower.count == 1 ? 0 : userVM.follower.count-1)")
                                        .padding(.leading, -5)
                                        .bold()

                                    Text("|")

                                    NavigationLink {
                                        CurrentUserFollowingListView(userVM: userVM)
                                    } label: {
                                        Text("구독중")
                                    }
                                    
                                    Text("\(userVM.following.count == 1 ? 0 : userVM.following.count-1)")
                                        .padding(.leading, -5)
                                        .bold()
                                }
                                .padding(.leading, 9)
                                .font(.footnote)
                                .foregroundColor(.textGray)
                            }
                        }
                        
                    }
                    .padding(.bottom, 15)
                    //                    .padding(.trailing, 30)
                    
                    VStack(alignment: .leading){
                        Text(userVM.currentUsers?.introduce.stringValue ?? "자기 소개를 작성해보세요")
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 5)
                    
                    
                    VStack{
                        Button{
                            showDevices.toggle()
                            //                                transitionView.toggle()
                        } label: {
                            VStack(alignment: .leading){
                                HStack{
                                    Text("장비 정보")
                                        .font(.subheadline)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .rotationEffect(Angle(degrees: self.showDevices ? 90 : 0))
                                        .animation(.linear(duration: self.showDevices ? 0.1 : 0.1), value: showDevices)
                                }
                                .bold()
                                
                                
                                if showDevices {
                                    VStack(alignment: .leading){
                                        userVM.myCamera.count > 1 ? Text("바디 | \(userVM.myCamera[1])") : nil
                                        
                                        userVM.myLens.count > 1 ? Text("렌즈 | \(userVM.myLens[1])") : nil
                                        
                                        userVM.myFilm.count > 1 ? Text("필름 | \(userVM.myFilm[1])") : nil
                                        
                                    }
                                    .font(.subheadline)
                                    .padding(.top, -9)
                                }
                            }
                            .padding(.top, 5)
                        }
                        
                    }
                    .padding(.leading, 5)
                    .padding(.top, -5)
                    .foregroundColor(.textGray)
                    
                    
                }
                .padding(.leading, 20)
                
                Rectangle()
                    .frame(height: 1)
                    .padding(.horizontal, 10)
                    .padding(.top, 5)
                    .foregroundColor(.brightGray)
                MyPageMyFeedView(magazineVM: magazineVM, magazineDocument: magazineDocument)
                //                    .padding(.top, -80)
            }
            .onAppear{
                // MARK: userID에 UserDefaults이용해서 저장
                userVM.fetchUser()
                userVM.fetchCurrentUser(userID: Auth.auth().currentUser?.uid ?? "")
            }
            .onReceive(userVM.fetchUsersSuccess, perform: { newValue in
                // userVM 의 fetchUser가 수행되어 값이 들어왔을때 currentUser의 팔로워, 팔로잉 리스트를 필터링하는 메소드 실행
                /// 희경: onReceive 메소드 사용 이유: fetchUser 메소드와 fetchCurrentUser메소드를 동시에 실행시키면 fetchUser가 완료되기 전에 fetchCurrentUser가 실행되어 filterCurrentUsersFollow가 제대로 수행되지 않음.
                userVM.filterCurrentUsersFollow()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        MyPageOptionView(userVM: userVM, bookmarkedMagazineDocument: boomarkedMagazineDocument, bookmarkedCommunityDoument: bookmarkedCommunityDoument, magazineVM: magazineVM)
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

//struct MyPageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyPageView(magazineDocument: [], boomarkedMagazineDocument: [], bookmarkedCommunityDoument: [])
//    }
//}



// 프로필을 배경으로
//                Image("2")
//                    .resizable()
//                    .frame(width: Screen.maxWidth, height: Screen.maxHeight / 3.5)
//                    .scaledToFit()
//                    .blur(radius: 1)
////                    .edgesIgnoringSafeArea(.top)
//                    .overlay{
//                        VStack(alignment: .leading){
//                            Text("nickNam")
//                                .font(.title)
//                                .bold()
//                            Text("전국을 돌아다니며 사진찍으러 다닙니다 같이 찍어요~!")
////                                .frame(width: Screen.maxWidth / 1.5)
////                                .padding(.trailing, 50)
//
//                            HStack{
//                                Text("팔로우 12213")
//                                Text("|")
//                                Text("팔로워 231")
//                            }
//                        }
//                        .padding(.bottom, 30)
//                        .padding(.trailing, 100)
//                    }.foregroundColor(.white)


//                    ZStack(alignment: .bottomLeading){
//                        Image("3")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(height: Screen.maxHeight / 2.8)
//                            .ignoresSafeArea()
//
//                        VStack{
//                            Text("nickN")
//                                .font(.title)
//                                .bold()
//                                .frame(width: 300)
//                                .padding(.leading, 80)
//
//                            VStack{
//                                Text("전국을 돌아다니며 ")
//                            }
//                            .frame(width: 300)
//                            .padding(.leading, 105)
//                            HStack{
//                                Text("팔로우")
//                                Text("|")
//                                Text("팔로워")
//                            }
//                        }
//                        .frame(width: 200, height: 100)
//                        .padding()
//                    }
//                    .frame(width: Screen.maxWidth, height: Screen.maxHeight / 3)
//                    .foregroundColor(.white)

// 프로필 레이아웃
//                VStack{
//                    HStack{
//                        //MARK: 프로필 이미지
//                        KFImage(URL(string: userVM.currentUsers?.profileImage.stringValue ?? "") ?? URL(string:"https://cdn.travie.com/news/photo/202108/21951_11971_5847.jpg"))
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 85, height: 85)
//                            .cornerRadius(64)
//                            .overlay {
//                                Circle()
//                                    .stroke(lineWidth: 1.2)
//                            }
//                            .padding(.trailing)
//
//                        VStack(alignment: .leading){
//                            Text(userVM.currentUsers?.nickName.stringValue ?? "anna2312312222")
//                                .font(.title3)
//                                .bold()
//                                .padding(.leading, 8)
//                                .padding(.bottom, 5)
//
//                            VStack(alignment: .leading){
//                                Text(userVM.currentUsers?.introduce.stringValue ?? "안녕하세요 사진찍으러 다니는거 좋아합니다! 같이 사진 찍으러 다녀요 잘 부탁드려요 감사합니")
//                                    .font(.subheadline)
//                                    .foregroundColor(.boxGray)
////                                    .lineLimit(3)
//                            }
//                            .padding(.trailing)
//
//                        }
//
//                    }
//                    .padding(.bottom, 15)
////                    .padding(.trailing, 30)
//                    HStack(spacing: 95){
//
//                        VStack{
//                            Text("234")
//                                .foregroundColor(.black)
//                                .bold()
//                                .padding(.bottom, 1)
//                            Text("매거진")
//                                .font(.callout)
//                                .foregroundColor(.boxGray)
//
//                        }
//                        VStack{
//                            Text("2344")
//                            Text("팔로워")
//                        }
//                        VStack{
//                            Text("2344")
//                            Text("팔로잉")
//                        }
//                    }
//
//                    VStack(alignment: .leading){
//
//                        VStack{
//                            Button{
//                                showDevices.toggle()
////                                transitionView.toggle()
//                            } label: {
//                                VStack(alignment: .leading){
//                                    HStack{
//                                        Text("장비 보기")
//                                            .font(.subheadline)
//                                            .bold()
//                                        Image(systemName: "chevron.right")
//                                            .font(.subheadline)
//                                            .rotationEffect(Angle(degrees: self.showDevices ? 90 : 0))
//                                            .animation(.linear(duration: self.showDevices ? 0.1 : 0.1), value: showDevices)
//                                    }
//
//                                    if showDevices {
//                                        VStack(alignment: .leading){
//                                            userVM.myCamera.count > 1 ? Text("바디 | \(userVM.myCamera[1])") : Text("바디 | ㅇㅁㄴㄹㅁㄴㅇㄹㅁㅇㄴㄹㅁ")
//
//                                            userVM.myLens.count > 1 ? Text("렌즈 | \(userVM.myLens[1])") : Text("바디 | ㅇㅁㄴㄹㅁㄴㅇㄹㅁㅇㄴㄹㅁ")
//
//                                            userVM.myFilm.count > 1 ? Text("필름 | \(userVM.myFilm[1])") : Text("바디 | ㅇㅁㄴㄹㅁㄴㅇㄹㅁㅇㄴㄹㅁ")
//
//                                        }
//                                        .font(.subheadline)
//                                        .bold()
//                                        .padding(.top, -5)
//                                    }
//                                }
//                                .padding(.top, 5)
//                            }
//
//                        }
//                        .padding(.leading, 9)
//                        .padding(.top, -5)
//                        .foregroundColor(.textGray)
//
//                    }
//                }
//                .padding(.leading, 20)

//                VStack(alignment: .leading){
//                    HStack{
//                        //MARK: 프로필 이미지
//                        KFImage(URL(string: userVM.currentUsers?.profileImage.stringValue ?? "") ?? URL(string:"https://cdn.travie.com/news/photo/202108/21951_11971_5847.jpg"))
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 85, height: 85)
//                            .cornerRadius(64)
//                            .overlay {
//                                Circle()
//                                    .stroke(lineWidth: 1.2)
//                            }
//                            .padding(.trailing)
//
//                        VStack(alignment: .leading){
//                            Text(userVM.currentUsers?.introduce.stringValue ?? "안녕하세요 사진찍으러 다니는거 좋아합니다! 같이 사진 찍으러 다녀요 잘 부탁드려요 감사합니")
//                                .font(.subheadline)
//                                .lineLimit(3)
//                                .padding(.top, 2)
//                        }
//                    }
//                    .padding(.bottom, 15)
//                    .padding(.trailing, 30)
//
////                    Text("userNickName")
//                    VStack(alignment: .leading){
//                        Text(userVM.currentUsers?.nickName.stringValue ?? "닉네임 없음")
//                            .font(.headline)
//                            .padding(.leading, 8)
//
//                        HStack{
//                            Text("팔로워 123124")
//                            Text("|")
//                            Text("팔로잉 123")
//                        }
//                        .padding(.leading, 9)
//                        .padding(.top, -5)
//                        .font(.footnote)
//                        .foregroundColor(.textGray)
//
//                        VStack{
//                            Button{
//                                showDevices.toggle()
////                                transitionView.toggle()
//                            } label: {
//                                VStack(alignment: .leading){
//                                    HStack{
//                                        Text("장비 보기")
//                                            .font(.subheadline)
//                                            .bold()
//                                        Image(systemName: "chevron.right")
//                                            .font(.subheadline)
//                                            .rotationEffect(Angle(degrees: self.showDevices ? 90 : 0))
//                                            .animation(.linear(duration: self.showDevices ? 0.1 : 0.1), value: showDevices)
//                                    }
//
//                                    if showDevices {
//                                        VStack(alignment: .leading){
//                                            userVM.myCamera.count > 1 ? Text("바디 | \(userVM.myCamera[1])") : nil
//
//                                            userVM.myLens.count > 1 ? Text("렌즈 | \(userVM.myLens[1])") : nil
//
//                                            userVM.myFilm.count > 1 ? Text("필름 | \(userVM.myFilm[1])") : nil
//
//                                        }
//                                        .font(.subheadline)
//                                        .bold()
//                                        .padding(.top, -5)
//                                    }
//                                }
//                                .padding(.top, 5)
//                            }
//
//                        }
//                        .padding(.leading, 9)
//                        .padding(.top, -5)
//                        .foregroundColor(.textGray)
//
//                    }
//                }
//                .padding(.leading, 20)
