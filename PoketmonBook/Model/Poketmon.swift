//
//  Poketmon.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation

//포켓몬 리스트를 받아오는 API Model
struct PoketmonListResponse: Codable {
    let count: Int // 총 포켓몬 개수
    let next: String? // 다음 offset
    let previous: String? // 전 offset
    let results: [PoketmonListResult]
}

struct PoketmonListResult: Codable {
    let name: String? // 이름
    let url: String? // url
}

extension PoketmonListResult {
    var imageURL: URL? {
        guard let url = self.url else { return nil }
        // url을 / 기준으로 나눠서 배열을 만든다.
        let parts = url.split(separator: "/")
        // parts.last를 idString에 넣고 id라는 상수에 int로 변환한 idString을 Id에 넣어준다.
        if let idString = parts.last, let id = Int(idString) {
            return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
        }
        // idString을 못얻을경우에 nil 리턴
        return nil
    }
}
