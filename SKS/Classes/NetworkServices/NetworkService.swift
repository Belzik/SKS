//
//  NetworkService.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Alamofire

struct APIPath {
    static let showcase = "showcase"
    static let categories = "categories"
    static let cities = "cities"
    static let content = "content"
    static let partners = "partners"
}

enum HeaderKey: String {
    case typePage = "X-Type-Page"
    case userCity = "X-User-City"
    case pageOffset = "X-Page-Offset"
    case pageLimit = "X-Page-Limit"
    case idPartner = "idPartner"
}

enum NetworkError: Error {
    case common
    case noInternetConnection
}

class NetworkManager {
    private init() {}
    
    static let shared = NetworkManager()
    let decoder = JSONDecoder()
    
    let baseURI = "https://virtserver.swaggerhub.com/px2x/sks-mobile/0.0.1/"
    
    private func getResult<T: Decodable>(url: String, headers: [String : String], completion: @escaping (_ response: Result<T>) -> Void) {
        
        request(url, headers: headers)
            .validate()
            .responseData { response in
                let result: Result<T> = self.decoder.decodeResponse(from: response)
                completion(result)
        }
    }
    
    func getContent(completion: @escaping (_ response: DataResponse<String>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.content
        let headers = [HeaderKey.typePage.rawValue: "license"]
        
        request(url, headers: headers)
            .validate()
            .responseString { (response: DataResponse<String>) in
                completion(response)
        }
    }

    
    func getCategories(codeCity: String = "spb", completion: @escaping (_ result: Result<CategoriesResponse>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.categories
        let headers = [HeaderKey.userCity.rawValue: codeCity]
        
        getResult(url: url, headers: headers) { result in
            completion(result)
        }
    }
    
    func getCities(completion: @escaping (_ result: Result<CitiesResponse>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.cities
        
        getResult(url: url, headers: [:]) { result in
            completion(result)
        }
    }
    
    func getShowcase(codeCity: String = "spb", completion: @escaping (_ result: Result<StocksResponse>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.showcase
        let headers = [HeaderKey.userCity.rawValue: codeCity]
        
        getResult(url: url, headers: headers) { result in
            completion(result)
        }
    }
    
    func getPartners(codeCity: String = "spb", pageOffset: String = "0", pageLimit: String = "10", completion: @escaping (_ result: Result<PartnersResponse>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.partners
        let headers = [
            HeaderKey.userCity.rawValue: codeCity,
            HeaderKey.pageOffset.rawValue: pageOffset,
            HeaderKey.pageLimit.rawValue: pageLimit
        ]
        
        getResult(url: url, headers: headers) { result in
            completion(result)
        }
    }
    
    func getPartner(codeCity: String = "spb", idPartner: Int = 0, completion: @escaping (_ result: Result<Partner>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.partners + "/\(codeCity)"
        let headers = [
            HeaderKey.userCity.rawValue: codeCity,
            HeaderKey.idPartner.rawValue: codeCity
        ]
        
        getResult(url: url, headers: headers) { result in
            completion(result)
        }
    }
}
