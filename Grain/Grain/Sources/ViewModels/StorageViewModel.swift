//
//  StorageViewModel.swift
//  Grain
//
//  Created by 지정훈 on 2023/01/31.
//

import Foundation
import Combine


final class StorageViewModel: ObservableObject {
    
    var subscription = Set<AnyCancellable>()
    
    @Published var storages = [StorageDTO]()
    
    var fetchStorageSuccess = PassthroughSubject<(), Never>()
    var insertStorageSuccess = PassthroughSubject<(), Never>()

    func fetchMagazine() {
        
        MagazineService.getMagazine()
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
        } receiveValue: { (data: StorageResponse) in
            self.storages = data.storages
            self.fetchStorageSuccess.send()
        }.store(in: &subscription)
    }
    
    
}

