//
//  DetailViewModel.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation
import RxSwift

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    let poketmonSubject = BehaviorSubject<PoketmonDetail?>(value: nil)
    var poketmonId:Int = 0
    func fetchPoketmonDetail () {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(poketmonId)/") else {
            poketmonSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: {[weak self] (detail: PoketmonDetail) in
                self?.poketmonSubject.onNext(detail)
            }, onFailure: { [weak self] error in
                self?.poketmonSubject.onError(error)
            }).disposed(by: disposeBag)
    }
}
