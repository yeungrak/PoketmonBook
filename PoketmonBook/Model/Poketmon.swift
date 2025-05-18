//
//  Poketmon.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation

struct PoketmonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PoketmonListResult]
}

struct PoketmonListResult: Codable {
    let name: String?
    let url: String?
}

extension PoketmonListResult {
    var imageURL: URL? {
        guard let url = self.url else { return nil }
        let parts = url.split(separator: "/")
        if let idString = parts.last, let id = Int(idString) {
            return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-ii/gold/\(id).png")
        }
        return nil
    }
}
