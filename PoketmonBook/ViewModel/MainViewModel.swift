//
//  MainViewModel.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation
import RxSwift

class MainViewModel {
    private let disposeBag = DisposeBag()
    
    private var poketmons: [PoketmonListResult] = []
    private var isLoading = false
    private var offset = 0
    private let limit = 20

   
    let poketmonList = BehaviorSubject<[PoketmonListResult]>(value: [])

    func loadMorePoketmons() {
       
        if isLoading { return }
        isLoading = true

        let urlString = "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else {
            poketmonList.onError(NetworkError.invalidUrl)
            return
        }

        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (data: PoketmonListResponse) in
                guard let self = self else { return }
                
                // 새 포켓몬 이어붙이기
                self.poketmons += data.results
                self.offset += self.limit
                self.poketmonList.onNext(self.poketmons)
                self.isLoading = false

            }, onFailure: { [weak self] error in
                self?.poketmonList.onError(error)
                self?.isLoading = false
            })
            .disposed(by: disposeBag)
    }
}
