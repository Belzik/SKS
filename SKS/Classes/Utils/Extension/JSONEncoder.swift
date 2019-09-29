//
//  JSONEncoder.swift
//  SKS
//
//  Created by Александр Катрыч on 02/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case common
    case noInternetConnection
}

extension JSONDecoder {
    func decodeResponse<T: Decodable>(from response: DataResponse<Data>) -> (Result<T>, statusCode: Int?) {
        let statusCode = response.response?.statusCode
        
        if let error = response.error {
            return (.failure(error), statusCode)
        }
        
        guard let responseData = response.data else {
            return (.failure(NetworkError.common), statusCode)
        }
        
        let json = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [String : Any]
        print(json)
        
        print("-------------------")
        if let headers = response.response?.allHeaderFields {
            for header in headers {
                print(header)
            }
        }
        print("-------------------")

        
        //print("Все headers", response.response?.allHeaderFields)
        
        do {
            let item = try decode(T.self, from: responseData)
            return (.success(item), statusCode)
        } catch {
            return (.failure(error), statusCode)
        }
    }
}
