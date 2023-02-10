//
//  UserViewModel.swift
//  Grain
//
//  Created by 박희경 on 2023/01/23.
//


import Foundation
import Combine
import FirebaseFirestore


final class UserViewModel: ObservableObject {
    
    var subscription = Set<AnyCancellable>()
    
    @Published var users = [UserDocument]()
    // 현재 유저 데이터 값
    @Published var currentUsers : CurrentUserFields?
    
    // 유저가 포스팅한 매거진 id 담는 배열
    @Published var currentUserStringValue: [CurrentUserStringValue] = [] // 변환만 하기 위해
    @Published var userPostedMagazine : [String] = [] //string값만
    @Published var cameraList: [String] = []
    @Published var lensList: [String] = []
    @Published var filmList: [String] = []
    
    // 유저가 저장한 매거진 id 담는 배열
    @Published var currentUserBookmarkedStringValue: [CurrentUserStringValue] = [] // 변환만 하기 위해
    @Published var userBookmarkedMagazine : [String] = [] //string값만
    @Published var likedMagazineIdArr : [String] = [] //string값만
    
    
    // 유저가 저장한 커뮤니티
    @Published var userBookmarkedCommunity : [String] = [] //string값만
    @Published var likedCommunityIdArr : [String] = [] // -> DB에서 만들어야됨
    
    var fetchUsersSuccess = PassthroughSubject<(), Never>()
    var fetchCurrentUsersSuccess = PassthroughSubject<(), Never>()
    var insertUsersSuccess = PassthroughSubject<(), Never>()
    var updateUsersArraySuccess = PassthroughSubject<(), Never>()
    var updateUsersStringSuccess = PassthroughSubject<(), Never>()
    var updateUsersProfileSuccess = PassthroughSubject<(), Never>()
    var deleteUsersSuccess = PassthroughSubject<(), Never>()
    
    
    func fetchUser() {
        UserService.getUser()
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: UserResponse) in
                self.users = data.documents
                self.fetchUsersSuccess.send()
            }.store(in: &subscription)
    }
    
    func fetchCurrentUser(userID: String) {
        UserService.getCurrentUser(userID: userID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: CurrentUserResponse) in
                self.currentUsers = data.fields
                
                
                //                            print(" 확인 \(data.createTime)") -> 시간 값 나중에 써먹을수 있을듯
                //                 user가 포스팅한 매거진 필터링
                
                
                self.currentUserStringValue.append(contentsOf: data.fields.postedMagazineID.arrayValue.values)
                for i in self.currentUserStringValue{
                    self.userPostedMagazine.append(i.stringValue)
                }
                
                for i in self.currentUsers?.myCamera.arrayValue.values ?? [] {
                    self.cameraList.append(i.stringValue)
                }
                for i in self.currentUsers?.myLens.arrayValue.values ?? [] {
                    self.lensList.append(i.stringValue)
                }
                for i in self.currentUsers?.myFilm.arrayValue.values ?? [] {
                    self.filmList.append(i.stringValue)
                }
                self.currentUserBookmarkedStringValue.append(contentsOf: data.fields.bookmarkedMagazineID.arrayValue.values)
                for i in self.currentUserBookmarkedStringValue{
                    self.userBookmarkedMagazine.append(i.stringValue)
                }
                
                for i in data.fields.likedMagazineID.arrayValue.values{
                    self.likedMagazineIdArr.append(i.stringValue)
                }
                //                 저장한 커뮤니티 북마크
                for i in data.fields.bookmarkedCommunityID.arrayValue.values{
                    self.userBookmarkedCommunity.append(i.stringValue)
                    print(i.stringValue)
                }
                //                 저장한 커뮤니티 좋아요
                //                for i in data.fields.likedCommunityID.arrayValue.values{
                //                    self.likedCommunityIdArr.append(i.stringValue)
                //                }
                
                self.fetchCurrentUsersSuccess.send()
            }.store(in: &subscription)
    }
    
    // MARK: - 유저 프로필 업데이트 메소드 (nickName, introduce, profileImage 업데이트할때 ProfileEditView에서 사용)
    /// ex) profileImage :프로필 UIImage를 UIImage 타입 그대로 배열에 넣어서 넘겨줍니다, 또 nickName, introduce, docID는 그대로 String 타입으로 넘겨주면 자동으로 update 될겁니다.
    func updateCurrentUserProfile(profileImage: [UIImage], nickName: String, introduce: String, docID: String) {
        UserService.updateCurrentUserProfile(profileImage: profileImage, nickName: nickName, introduce: introduce, docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: UserDocument) in
                self.updateUsersProfileSuccess.send()
            }.store(in: &subscription)
    }
    
    // MARK: - 유저정보 업데이트 메소드 (string 배열 타입값 업데이트할때 사용 )
    /// 좋아요누른 게시글 , 저장한 게시글, 저장한 커뮤니티글, 내 장비정보(카메라, 렌즈, 필름), 내가 올린 메거진, 커뮤니티 게시글 업데이트 할때 사용하면 됩니다.
    /// ex) type: likedMagazineId , string: ["1234", "45346346", "56456456"], docID: 현재로그인한유저아이디 -> 유저가 좋아요누른 메거진 아이디 리스트 배열을 ["1234", "45346346", "56456456"] 로 바꾸겠다. !!!
    func updateCurrentUserArray(type: String, arr: [String], docID: String){
        UserService.updateCurrentUserArray(type: type, arr: arr, docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: UserDocument) in
                self.updateUsersArraySuccess.send()
            }.store(in: &subscription)
    }
    
    
    // MARK: - 유저정보 업데이트 메소드 (string 타입값 업데이트할때 사용)
    /// 이 메소드는 지금 필요할지 모르겠지만 일단 만듬.
    /// ex) type: id , string: "1234", docID: 현재로그인한유저아이디 -> 유저의  id 를 1234로 바꾸겠댜!!!
    func updateCurrentUserString(type: String, string: String, docID: String) {
        UserService.updateCurrentUserString(type: type, string: string, docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: UserDocument) in
                self.updateUsersStringSuccess.send()
            }.store(in: &subscription)
    }
    
    
    // MARK: - 유저정보 삭제 메소드 (유저 탈퇴시 사용)
    func deleteUser(docID: String) {
        UserService.deleteUser(docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: UserDocument) in
                self.deleteUsersSuccess.send()
            }.store(in: &subscription)
    }
    
    func updateUserUsingSDK(updateDocument: String, updateKey: String, updateValue: String, isArray: Bool) async {
        let db = Firestore.firestore()
        let documentRef = db.collection("User").document("\(updateDocument)")
        if isArray{
            do{
                try? await documentRef.updateData(
                    [
                        "\(updateKey)": FieldValue.arrayUnion(["\(updateValue)"])
                    ]
                )
            }catch let error {
                print("Error updating document: \(error)")
            }
        }else{
            do{
                try? await documentRef.updateData(
                    [
                        "\(updateKey)" : "\(updateValue)"
                    ]
                )
            }catch let error {
                print("Error updating document: \(error)")
            }
        }
    }
    
    func deleteUserUsingSDK(updateDocument: String, deleteKey: String, deleteIndex: String, isArray: Bool) async {
        let db = Firestore.firestore()
        let documentRef = db.collection("User").document("\(updateDocument)")
        if isArray{
            do{
                try? await documentRef.updateData(
                    [
                        "\(deleteKey)": FieldValue.arrayRemove([
                            "\(deleteIndex)"
                        ])
                    ]
                )
            }catch let error {
                print("Error updating document: \(error)")
            }
        }else{
            do{
                try? await documentRef.updateData(
                    [
                        "\(deleteKey)" : FieldValue.delete()
                    ]
                )
            }catch let error {
                print("Error updating document: \(error)")
            }
        }
    }
    
    
}

