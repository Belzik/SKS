//
//  NetworkService.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Alamofire

struct APIPath {
    static let category        = "category"
    static let partner         = "partner"
    static let stock           = "stock"
    static let getSmsWithCode  = "auth/phone"
    static let verifyCodeSms   = "auth/otp"
    static let cityUniversitie = "univer/cities"
    static let universities    = "univer"
    static let faculties       = "univer/faculty"
    static let specialties     = "univer/specialty"
    static let cityPartners    = "partner/filter/cities"
    static let uploadPhoto     = "student/photo"
    static let refreshToken    = "auth/refreshtoken"
    static let student         = "student"
}

enum HeaderKey: String {
    case token       = "X-Access-Token"
    case typePage    = "X-Type-Page"
    case offset      = "X-Offset"
    case limit       = "X-Limit"
    case userCity    = "X-User-City"
    case userUniver  = "X-User-Univer"
    case userFaculty = "X-User-Faculty"
}

struct NetworkErrors {
    static let common             = "Произошла ошибка, попробуйте позже."
    static let internetConnection = "Подключение к интернету отсутствует."
}

class NetworkManager {
    private init() {}
    
    static let shared = NetworkManager()
    let decoder = JSONDecoder()
    
    let baseURI = "https://app.sksadmin.ru"
    let authURI = "https://auth.sksadmin.ru"
    let apiVersion = "/v1/"
    
    private func getResult<T: Decodable>(url: String,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         encoding: ParameterEncoding = URLEncoding.default,
                                         headers: [String : String]? = nil,
                                         completion: @escaping (_ response: (Result<T>, Int?)) -> Void) {
        
        request(url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers)
            .validate()
            .responseData { response in
                let result: (Result<T>, Int?) = self.decoder.decodeResponse(from: response)
                completion(result)
        }
    }

    // MARK: - Получить все категории
    func getCategories(completion: @escaping (_ result: (result: Result<CategoriesResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.category
        
        getResult(url: url) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить все акции
    func getStocks(category: String? = nil,
                   uuidCity: String? = nil,
                   completion: @escaping (_ result: (result: Result<StocksResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.stock
        
        var parameters: Parameters = [:]
        
        if let category = category {
            parameters["categories"] = [category]
        }
        
        if let uuidCity = uuidCity {
            parameters["cities"] = [uuidCity]
        }
        
        let headers = [
            "X-Limit": "3",
            "X-Offset": "0"
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parameters,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить определенную акцию
    func getStock(idStock: String,
                  uuidCity: String,
                  completion: @escaping (_ result: (result: Result<Stock>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.stock + "/\(idStock)"
        
        let parameters: Parameters = ["uuidCity": uuidCity]
        
        getResult(url: url,
                  method: .put,
                  parameters: parameters) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить всех партнеров
    func getPartners(category: String? = nil,
                     uuidCity: String? = nil,
                     completion: @escaping (_ result: (result: Result<PartnersResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI +  apiVersion + APIPath.partner
        
        var parameters: Parameters = [:]
        
        if let category = category {
            parameters["categories"] = [category]
        }
        
        if let uuidCity = uuidCity {
            parameters["cities"] = [uuidCity]
        }
        
        let headers = [
            "X-Limit": "7",
            "X-Offset": "0"
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parameters,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить определенного партнера
    func getPartner(uuidPartner: String,
                    uuidCity: String,
                    completion: @escaping (_ result: (result: Result<Partner>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.partner + "/\(uuidPartner)"

        let parameters: Parameters = ["uuidCity": uuidCity]
        
        getResult(url: url,
                  method: .put,
                  parameters: parameters) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить СМС с кодом на телефон
    func getCodeWithSms(phone: String,
                        place: String = "mobile",
                        completion: @escaping (_ result: (result: Result<SmsResponse>, statusCode: Int?)) -> Void) {
        let url = authURI + apiVersion + APIPath.getSmsWithCode
        
        let parametrs: Parameters = [
            "login" : phone,
            "place" : place
        ]
        
        getResult(url: url,
                  method: .post,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: - Проверить код из СМС
    func verifyCodeSms(phone: String,
                       attempt: String,
                       code: String,
                       completion: @escaping (_ result: (result: Result<OtpResponse>, statusCode: Int?)) -> Void) {
        let url = authURI + apiVersion + APIPath.verifyCodeSms
        
        let parametrs: Parameters = [
            "login": phone,
            "attempt": attempt,
            "confirmCode": code
        ]
        
        getResult(url: url,
                  method: .post,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Получить все города, в которых есть университеты
    func getСityUniversities(completion: @escaping (_ result: (result: Result<CitiesResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.cityUniversitie
        
        getResult(url: url) { result in 
            completion(result)
        }
    }
    
    // MARK: Получить все университеты в определенном городе
    func getUniversities(uuidCity: String,
                         completion: @escaping (_ result: (result: Result<UniversitiesResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.universities
        
        let headers = [
            HeaderKey.userCity.rawValue: uuidCity
        ]
        
        getResult(url: url,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Получить все факультеты в определенном университете
    func getFaculties(uuidUniver: String,
                      completion: @escaping (_ result: (result: Result<FacultiesResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.faculties
        
        let headers = [
            HeaderKey.userUniver.rawValue: uuidUniver
        ]
        
        getResult(url: url,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Получить все специальности в определенном факультете
    func getSpecialties(uuidFaculty: String,
                        completion: @escaping (_ result: (result: Result<SpecialtiesResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.specialties
        
        let headers = [
            HeaderKey.userFaculty.rawValue: uuidFaculty
        ]
        
        getResult(url: url,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Получить города для фильтрации партнеров
    func getCityPartners(completion: @escaping (_ result: (result: Result<CitiesResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.cityPartners
        
        getResult(url: url,
                  method: .put) { result in
                    completion(result)
        }
    }
    
    // MARK: Отправить фото пользователя
    func uploadImage(image: UIImage,
                     completion: @escaping (_ response: (result: Result<PathFile>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.uploadPhoto
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            guard let jpegData = image.jpegData(compressionQuality: 1) else { return }
            
            multipartFormData.append(jpegData, withName: "imageFile", fileName: "userPhoto.jpg", mimeType: "image/jpg")
            
        }, to: url) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseData(completionHandler: { response in
                    let result: (result: Result<PathFile>, statusCode: Int?) = self.decoder.decodeResponse(from: response)
                    completion(result)
                })
            case .failure(_):
                break
            }
        }
    }
    
    // MARK: Зарегистрироваться
    func registration(uniqueSess: String,
                      name: String,
                      patronymic: String,
                      surname: String,
                      birthdate: String,
                      startEducation: String,
                      endEducation: String,
                      course: String,
                      uuidCity: String,
                      photo: String,
                      uuidUniversity: String,
                      uuidFaculty: String,
                      uuidSpecialty: String,
                      accessToken: String,
                      completion: @escaping (_ response: (result: Result<UserData>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.student
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        let parametrs: Parameters = [
            "uniqueSess": uniqueSess,
            "name": name,
            "patronymic": patronymic,
            "surname": surname,
            "birthdate": birthdate,
            "startEducation": startEducation,
            "endEducation": endEducation,
            "course": course,
            "uuidCity": uuidCity,
            "photo": photo,
            "uuidUniversity": uuidUniversity,
            "uuidFaculty": uuidFaculty,
            "uuidSpecialty": uuidSpecialty
        ]
        
        getResult(url: url,
                  method: .post,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: - Рефреш токена
    func refreshToken(refreshToken: String,
                      completion: @escaping (_ result: (result: Result<OtpResponse>, statusCode: Int?)) -> Void) {
        let url = authURI + apiVersion + APIPath.refreshToken
        
        
        let parametrs: Parameters = [
            "refreshToken": refreshToken,
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
                    completion(result)
        }
    }
    
    func getInfoUser(completion: @escaping (_ response: (result: Result<UserData>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion + APIPath.student
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        getResult(url: url,
                  headers: headers) { result in
                    completion(result)
        }
    }
}
