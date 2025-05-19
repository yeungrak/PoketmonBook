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
    //UI와 데이터 바인딩을 하기 위해 사용함
    let poketmonSubject = BehaviorSubject<PoketmonDetail?>(value: nil)
    var poketmonId:Int = 0
    //API 요청을 수행하는 함수
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
