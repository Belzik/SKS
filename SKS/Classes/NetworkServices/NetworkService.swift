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
    static let stock = "stock"
    static let getSmsWithCode = "auth/phone"
}

enum HeaderKey: String {
    case typePage = "X-Type-Page"
    case userCity = "X-User-City"
    case pageOffset = "X-Page-Offset"
    case pageLimit = "X-Page-Limit"
    case searchString = "X-Search-String"
    case idPartner = "idPartner"
    case idStock = "idStock"
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
    let authURI = "http://sksauth.px2x.ru"
    let apiVersion = "v1"
    
    private func getResult<T: Decodable>(url: String,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         encoding: ParameterEncoding = URLEncoding.default,
                                         headers: [String : String]? = nil,
                                         completion: @escaping (_ response: Result<T>) -> Void) {
        
        request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
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
    
    func getStocks(codeCity: String = "spb", completion: @escaping (_ result: Result<StocksResponse>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.showcase
        let headers = [HeaderKey.userCity.rawValue: codeCity]
        
        getResult(url: url, headers: headers) { result in
            completion(result)
        }
    }
    
    func getStock(codeCity: String = "spb", idStock: String = "00000000-0000-0000-0000-000000000000", completion: @escaping (_ result: Result<Stock>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.stock + "/\(idStock)"
        let headers = [
            HeaderKey.userCity.rawValue: codeCity,
            HeaderKey.idStock.rawValue: idStock
        ]
        
        getResult(url: url, headers: headers) { result in
            completion(result)
        }
    }
    
    func getPartners(codeCity: String = "spb", pageOffset: String = "0", pageLimit: String = "10", search: String = "Donalds",  completion: @escaping (_ result: Result<PartnersResponse>) -> Void) {
        let url = NetworkManager.shared.baseURI + APIPath.partners
        let headers = [
            HeaderKey.userCity.rawValue: codeCity,
            HeaderKey.pageOffset.rawValue: pageOffset,
            HeaderKey.pageLimit.rawValue: pageLimit,
            HeaderKey.searchString.rawValue: search
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
    
    func getCodeWithSms(phone: String, place: String = "mobile", completion: @escaping (_ result: Result<SmsResponse>) -> Void) {
        let url = authURI + "/\(apiVersion)/" + "\(APIPath.getSmsWithCode)"
        
        let parametrs: Parameters = [
            "login" : phone,
            "place" : place
        ]
        
        getResult(url: url, method: .post, parameters: parametrs) { result in
            completion(result)
        }
    }
}
