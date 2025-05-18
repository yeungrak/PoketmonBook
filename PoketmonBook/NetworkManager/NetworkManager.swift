//
//  NetworkManager.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
}

// 싱글톤 네트워크 매니저

/// 싱글톤 - 동일한 인스턴스 사용을 하기 위해 사용함
///
class NetworkManager {
    static let shared = NetworkManager() //싱글톤 인스턴스
    private init() {} //외부에서 init을 하지 못하게 막음
    
    ///제네릭을 사용해서 어떤 타입도 받아 올 수 있게함. 단 Decodable을 따르는 타입이어야함.
    ///리턴 타입은 RxSwift의 Single<T>이다. 한 번만 값을 방출하거나 에러를 내는 Rx 스트림.
    func fetch<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in //Rx의 Single을 수동으로 생성하는 부분.
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    observer(.success(decodedData))
                } catch {
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
