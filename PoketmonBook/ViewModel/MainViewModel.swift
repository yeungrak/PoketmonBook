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
    let pokemonSubject = BehaviorSubject(value: [PokemonListResult]())
    
    func fetchPokemonList(limit: Int, offset: Int) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            pokemonSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: {[weak self] (pokemonListResponse: PokemonListResponse) in
                self?.pokemonSubject.onNext(pokemonListResponse.results)
            }, onFailure: { [weak self] error in
                self?.pokemonSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
