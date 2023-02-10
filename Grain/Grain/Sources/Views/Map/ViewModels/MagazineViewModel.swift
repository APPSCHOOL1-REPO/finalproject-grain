//
//  CommunityViewModel.swift
//  Grain
//
//  Created by 박희경 on 2023/01/20.
//

import Foundation
import Combine
import FirebaseFirestore
import UIKit


final class MagazineViewModel: ObservableObject {
    
    var subscription = Set<AnyCancellable>()
    
    @Published var magazines = [MagazineDocument]()
    @Published var updateMagazineData : MagazineDocument?
    
    var fetchMagazineSuccess = PassthroughSubject<(), Never>()
    var insertMagazineSuccess = PassthroughSubject<(), Never>()
    var updateMagazineSuccess = PassthroughSubject<(), Never>()
    
    // MARK: 메거진 데이터 가져오기 메소드
    func fetchMagazine() {
        MagazineService.getMagazine()
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (data: MagazineResponse) in
                self.magazines = data.documents
                self.fetchMagazineSuccess.send()
            }.store(in: &subscription)
        
    }
    
    // MARK: 메거진 데이터 업로드 메소드 (MagazineAddView에서 사용)
    /// 해당 메거진 게시물 Data를 MagazineFields 구조체 형식으로 넣어주고, 게시글의 이미지배열은 따로 UIImage배열로 넣어줍니다.
    /// 이렇게 호출해주면 새로운 메거진 게시물이 업로드 됩니다.
    func insertMagazine(data: MagazineFields, images: [UIImage]) {
        MagazineService.insertMagazine(data: data, images: images)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (data: MagazineDocument) in
                print(" gmadfsdfs: \(data)")
                self.insertMagazineSuccess.send()
                print("id: \(data.name)")
            }.store(in: &subscription)
    }
    
    // MARK: 메거진 데이터 전체 업데이트 메소드(MagazineEditView에서 사용)
    /// 사용방법:  원래 데이터 수정해서  MagazineDocument형식으로 data 에 넣고, docID에는 메거진 id 넣어서 updateMagazine 호출.
    /// ex) 메거진 게시물 수정하기 - title, content 수정해서 update
    func updateMagazine(data: MagazineDocument, docID: String){
        MagazineService.updateMagazine(data: data, docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (data: MagazineDocument) in
                self.fetchMagazineSuccess.send()
            }.store(in: &subscription)
    }
    
    // MARK: 매거진 좋아요 수 업데이트 메소드(사용자가 해당 매거진 게시글에 좋아요 눌렀을때 유저정보 수정과 동시에 이 메거진의 좋아요수도 같이 업데이트할때 사용)
    /// 사용방법:  원래 데이터 수정해서  MagazineDocument형식으로 data 에 넣고, docID에는 메거진 id 넣어서 updateMagazine 호출.
    /// ex)  원래 좋아요 수 + 1해서 num에 string 타입으로 넣어주고 , docID에는 AuthID 넣어줌.
    func updateMagazine(num: String, docID: String){
        MagazineService.updateMagazineLikedNum(num: num, docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (data: MagazineDocument) in
                self.fetchMagazineSuccess.send()
            }.store(in: &subscription)
    }
    
    
    // MARK: 매거진 삭제 메소드(MagazineDetailView에서 게시물 삭제시 사용)
    /// 해당 메거진 게시물의 docID를 넣어주고 호출하면 그 게시물이 삭제됩니다.
    func deleteMagazine(docID: String) {
        MagazineService.deleteMagazine(docID: docID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            } receiveValue: { (data: MagazineDocument) in
                self.fetchMagazineSuccess.send()
            }.store(in: &subscription)
    }
    
    // MARK: update -> Firebase Store SDK 사용
    func updateMagazineSDK(updateDocument: String, updateKey: String, updateValue: String, isArray: Bool) async {
        let db = Firestore.firestore()
        
        let documentRef = db.collection("Magazine").document("\(updateDocument)")
        
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
    
    func nearbyPostsFilter(magazineData: [MagazineDocument],nearbyPostsArr: [String]) -> [MagazineDocument] {
        // 데이터를 담아서 반환해줌! -> nearbyPostArr을 ForEach를 돌려서 뷰를 그려줄 생각
        var nearbyPostFilterArr: [MagazineDocument] = []
        /// 배열 값부터 for in문 반복한 이유로는 magazines보다 무조건 데이터가 적을 것이고 찾는 데이터가 magazines 앞쪽에 있다면 좋은 효율을 낼수 있을거 같아 이렇게 배치!
        //        이거 넣었더니 터짐
        for arrData in nearbyPostsArr{
            for magazineIdValue in magazineData{
                if arrData == magazineIdValue.fields.id.stringValue{
                    nearbyPostFilterArr.append(magazineIdValue)
                    continue
                }
            }
        }
        return nearbyPostFilterArr
    }
    
    // 유저가 포스팅한 매거진 필터링
    func userPostsFilter(magazineData: [MagazineDocument], userPostedArr: [String]) -> [MagazineDocument] {
        // 데이터를 담아서 반환해줌! -> nearbyPostArr을 ForEach를 돌려서 뷰를 그려줄 생각
        var userPostFilterArr: [MagazineDocument] = []
        /// 배열 값부터 for in문 반복한 이유로는 magazines보다 무조건 데이터가 적을 것이고 찾는 데이터가 magazines 앞쪽에 있다면 좋은 효율을 낼수 있을거 같아 이렇게 배치!
//        이거 넣었더니 터짐
        for arrData in userPostedArr{
            for magazineIdValue in magazineData{
                if arrData == magazineIdValue.fields.id.stringValue{
                    userPostFilterArr.append(magazineIdValue)
                    continue
                }
            }
        }
        return userPostFilterArr
    }
    
    // 유저가 저장한 매거진 필터링
    func userBookmarkedPostsFilter(magazineData: [MagazineDocument], userBookmarkedPostedArr: [String]) -> [MagazineDocument] {
        // 데이터를 담아서 반환해줌! -> nearbyPostArr을 ForEach를 돌려서 뷰를 그려줄 생각
        var userBookmarkedPostFilterArr: [MagazineDocument] = []
        /// 배열 값부터 for in문 반복한 이유로는 magazines보다 무조건 데이터가 적을 것이고 찾는 데이터가 magazines 앞쪽에 있다면 좋은 효율을 낼수 있을거 같아 이렇게 배치!
//        이거 넣었더니 터짐
        for arrData in userBookmarkedPostedArr{
            for magazineIdValue in magazineData{
                if arrData == magazineIdValue.fields.id.stringValue{
                    userBookmarkedPostFilterArr.append(magazineIdValue)
                    continue
                }
            }
        }
        return userBookmarkedPostFilterArr
    }
    
}


