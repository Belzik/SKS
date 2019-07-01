//
//  NetworkService.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Alamofire

struct APIPath {
    static let showcase = ""
    static let categories = "/categories"
    static let cities = ""
    static let content = "/content"
}

struct NetworkErrors {
    static let common = "Произошла ошибка, попробуйте позже."
    static let internetConnection = "Подключение к интернету отсутствует."
}

class NetworkManager {
    private init() {}
    static let shared = NetworkManager()
    
    static let baseURI = "https://virtserver.swaggerhub.com/px2x/sks-mobile/0.0.1"
    
    func getContent(completion: @escaping (_ response: DataResponse<String>) -> Void) {
        let url = NetworkManager.baseURI + APIPath.content
        let headers = ["Content-type": "text/html",
                       "X-Type-Page": "license"]
        
        request(url, headers: headers)
            .validate()
            .responseString { (response: DataResponse<String>) in
                completion(response)
        }
    }
    
    func getCategories(completion: @escaping (_ response: DataResponse<Any>) -> Void) {
        let url = NetworkManager.baseURI + APIPath.categories
        
        let headers = ["Content-type": "tapplication/json",
                       "X-User-City": "spb"]
        
        request(url, headers: headers)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                completion(response)
        }
    }
}
