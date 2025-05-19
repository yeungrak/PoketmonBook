//
//  PoketmonDetail.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation

struct PoketmonDetail: Codable {
    let id: Int?          // No
    let name: String?     // 이름
    let height: Int?    // 키
    let weight: Int?      // 몸무게
    let types: [PoketmonTypeEntry] // 타입 배열
}

struct PoketmonTypeEntry: Codable {
    let slot: Int?
    let type: PoketmonType
}

struct PoketmonType: Codable {
    let name: String? // 포켓몬 타입이름
}

