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
    //중복 호출을 막기 위한 로딩 상태 플래그
    private var isLoading = false
    private var offset = 0
    private let limit = 20
    
    
    let poketmonList = BehaviorSubject<[PoketmonListResult]>(value: [])
    
    func loadMorePoketmons() {
        
        //로딩 중이면 중복 요청 방지 아닌 경우에 로딩 시작
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
                
                /// 새 포켓몬 이어붙이기
                /// 받아온 포켓몬을 기존 배열 리스트에 이어붙임
                self.poketmons += data.results
                ///다음 요청을 위해 offset 증가
                /// ex) offset = 0 이면 리밋이 20이니까
                ///  다음 요청에는 offset = 20이됌
                self.offset += self.limit
                self.poketmonList.onNext(self.poketmons)
                //데이터를 다 받으면 로딩 완료표시 = false
                self.isLoading = false
                
            }, //실패시
                onFailure: { [weak self] error in
                self?.poketmonList.onError(error)
                self?.isLoading = false
            })
            .disposed(by: disposeBag)
    }
}
