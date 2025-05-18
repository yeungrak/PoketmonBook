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
    let poketmonSubject = BehaviorSubject(value: [PoketmonListResult]())
    
    func fetchPokemonList(limit: Int, offset: Int) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            poketmonSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: {[weak self] (pokemonListResponse: PoketmonListResponse) in
                self?.poketmonSubject.onNext(pokemonListResponse.results)
            }, onFailure: { [weak self] error in
                self?.poketmonSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
