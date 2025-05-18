//
//  PoketmonDetail.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation

struct PokemonDetail: Codable {
    let id: Int?
    let name: String?
    let height: Int?
    let weight: Int?
    let sprites: Sprite?
    let types: [PokemonTypeEntry]
}

struct Sprite: Codable {
    let frontDefault: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonTypeEntry: Codable {
    let slot: Int?
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String?
    let url: String?
}
