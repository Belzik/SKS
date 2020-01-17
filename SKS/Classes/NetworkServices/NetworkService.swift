//
//  NetworkService.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Alamofire
import UIKit

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
    static let sendNotificationToken = "student/push"
    static let setPassword     = "auth/setpassword"
    static let enterPassword   = "auth/enterpassword"
    static let resetPassword   = "auth/reset"
    static let getSalePoints   = "partner/card/list/points"
    static let getStatistics   = "partner/rating/statistic"
    static let getNews         = "news"
    static let getComments     = "partner/comment/list"
    static let commentLike     = "partner/comment/like"
    static let sendComplaint   = "partner/complaint/new"
    static let sendComment     = "partner/comment/new"
    static let sendRating      = "partner/rating"
    static let event           = "news/event"
    static let pooling         = "news/pooling"
    static let getPoints       = "partner/list/points"
    static let getPartnerPoints = "partner/list/map"
    static let checkComment    = "partner/comment/check"
    static let editComment     = "partner/comment/edit"
    static let upuses          = "/v2/partners/upuses"
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
    
    //let baseURI = "https://app.sksadmin.ru"
    //let authURI = "https://auth.sksadmin.ru"
    
    //let baseURI = "http://sksapp.px2x.ru"
    //let authURI = "http://sksauth.px2x.ru"
    
    let baseURI = "http://46.161.53.41:9999"
    let authURI = "http://46.161.53.41:9997"
    
    let apiVersion = "/v1/"
    
    private func getResult<T: Decodable>(url: String,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         encoding: ParameterEncoding = URLEncoding.default,
                                         headers: [String : String]? = nil,
                                         completion: @escaping (_ response: (Result<T>, Int?)) -> Void) {
        var requestHeaders: [String : String] = [:]
        
        if let headers = headers {
            requestHeaders = requestHeaders.merging(headers) { (_, new) in new }
        }
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            requestHeaders["DeviceType"] = "iOs"
            requestHeaders["Version"] = appVersion
        }
        
        request(url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: requestHeaders)
            .validate()
            .responseData { response in
                let result: (Result<T>, Int?) = self.decoder.decodeResponse(from: response)
                
                if let vc = UIWindow.getVisibleViewController(nil),
                    let statusCode = result.1 {
                    if !(vc is UIAlertController) {
                        if statusCode == 426 {
                            let alert = UIAlertController(title: "Внимание!",
                                                          message: "Новая версия СКС РФ доступна для скачивания. Пожалуйста, обновитесь.",
                                                          preferredStyle: .alert)
                            
                            let okBtn = UIAlertAction(title: "Обновить",
                                                      style: .default,
                                                      handler: {(_ action: UIAlertAction) -> Void in
                                                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1473711942"),
                                                            UIApplication.shared.canOpenURL(url){
                                                            if #available(iOS 10.0, *) {
                                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                            } else {
                                                                UIApplication.shared.openURL(url)
                                                            }
                                                        }
                            })
                            
                            alert.addAction(okBtn)
                            vc.present(alert, animated: true,
                                       completion: nil)
                        }
                        
                        if statusCode == 423 {
                            let alert = UIAlertController(title: "Внимание!",
                                                          message: "Новая версия СКС РФ доступна для скачивания. Пожалуйста, обновитесь.",
                                                          preferredStyle: .alert)
                            
                            let okBtn = UIAlertAction(title: "Обновить",
                                                      style: .default,
                                                      handler: {(_ action: UIAlertAction) -> Void in
                                                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1473711942"),
                                                            UIApplication.shared.canOpenURL(url){
                                                            if #available(iOS 10.0, *) {
                                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                            } else {
                                                                UIApplication.shared.openURL(url)
                                                            }
                                                        }
                            })
                            let noBtn = UIAlertAction(title:"Пропустить" ,
                                                      style: .destructive,
                                                      handler: {(_ action: UIAlertAction) -> Void in
                            })
                            alert.addAction(noBtn)
                            alert.addAction(okBtn)
                            vc.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
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
                   searchString: String? = nil,
                   limit: Int,
                   offset: Int,
                   completion: @escaping (_ result: (result: Result<StocksResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.stock
        
        var parameters: Parameters = [:]
        
        if let category = category {
            parameters["categories"] = [category]
        }
        
        if let uuidCity = uuidCity {
            parameters["cities"] = [uuidCity]
        }
        
        if let searchString = searchString {
            parameters["searchString"] = searchString
        }
        
        let headers = [
            "X-Limit": String(describing: limit),
            "X-Offset": String(describing: offset)
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
                     searchString: String? = nil,
                     limit: Int,
                     offset: Int,
                     completion: @escaping (_ result: (result: Result<PartnersResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI +  "/v2/" + APIPath.partner
        //let url = "http://sksapp.px2x.ru/v2/partner"
        
        var parameters: Parameters = [:]
        
        if let category = category {
            parameters["categories"] = [category]
        }
        
        if let uuidCity = uuidCity {
            parameters["cities"] = [uuidCity]
        }

        if let searchString = searchString {
            parameters["searchString"] = searchString
        }
        
        let headers = [
            "X-Limit": String(describing: limit),
            "X-Offset": String(describing: offset)
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
        let url = baseURI + "/v2/" + APIPath.partner + "/\(uuidPartner)"

        //let url = "http://sksapp.px2x.ru/v2/partner" + "/\(uuidPartner)"
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
        let url = authURI + "/v2/" + APIPath.getSmsWithCode
        //let url = "http://sksauth.px2x.ru/v2/auth/phone"
        
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
        let url = authURI + "/v2/" + APIPath.verifyCodeSms
        
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
        let url = baseURI + "/v2/" + APIPath.uploadPhoto
        
        var headers: [String: String] = [:]
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers["DeviceType"] = "iOs"
            headers["Version"] = appVersion
        }
        
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
                      uuidUniversity: String,
                      uuidFaculty: String,
                      uuidSpecialty: String,
                      accessToken: String,
                      keyPhoto: String,
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
            "uuidUniversity": uuidUniversity,
            "uuidFaculty": uuidFaculty,
            "uuidSpecialty": uuidSpecialty,
            "keyPhoto": keyPhoto
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
                      completion: @escaping (_ result: (result: Result<TokensResponse>, statusCode: Int?)) -> Void) {
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
    
    // MARK: - Получить профиль пользовател
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
    
    func sendNotificationToken(notificationToken: String,
                               deviceToken: String,
                               accessToken: String = "",
                               completion: @escaping (_ response: DataResponse<Data>) -> Void) {
        let url = baseURI + apiVersion + APIPath.sendNotificationToken
        let parameters: Parameters = [
            "token": notificationToken,
            "device": "iOs",
            "idDevice": deviceToken
        ]
        
        var headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers["DeviceType"] = "iOs"
            headers["Version"] = appVersion
        }
        
        request(url,
                method: .post,
                parameters: parameters,
                headers: headers)
            .validate()
            .responseData { response in
                completion(response)
        }
    }
    
    // MARK: Обновить информацию о пользователе
    func updateUserInfo(uniqueSess: String,
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
                        completion: @escaping (_ response: (result: Result<UserData>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }

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
                  method: .put,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Получить торговые точки партнера
    func getSalePoints(uuidPartner: String,
                       uuidCity: String,
                       completion: @escaping (_ response: (result: Result<SalePointsResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + "/v2/" + APIPath.getSalePoints
        
        //let url = "http://sksapp.px2x.ru/v2/partner/card/list/points"
        
        let parametrs: Parameters = [
            "uuidCity": uuidCity,
            "uuidPartner": uuidPartner
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Получить оценки и их статистику по партнеру
    func getRatingStatictis(uuidPartner: String,
                            completion: @escaping (_ response: (result: Result<RatingStatistic>, statusCode: Int?)) -> Void) {
        let url = baseURI + "/v2/" + APIPath.getStatistics + "/\(uuidPartner)"
        //let url = "http://sksapp.px2x.ru/v2/partner/rating/statistic/" + "\(uuidPartner)"
        
        getResult(url: url) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить новости
    func getNews(limit: Int,
                 offset: Int,
                 completion: @escaping (_ result: (result: Result<NewsResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.getNews
        //let url = "http://sksapp.px2x.ru/v1/news"
        
        var headers: [String: String] = [
            "X-Limit": String(describing: limit),
            "X-Offset": String(describing: offset)
        ]
        
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers[HeaderKey.token.rawValue] = accessToken
        }
        
        getResult(url: url,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить новость
    func getSingleNews(uuidNews: String,
                       completion: @escaping (_ result: (result: Result<News>, statusCode: Int?)) -> Void) {
        let url = baseURI + apiVersion + APIPath.getNews + "/\(uuidNews)"
        
        var headers: [String: String] = [:]
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers[HeaderKey.token.rawValue] = accessToken
        }
        
        getResult(url: url,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить комментарии партнера
    func getComments(uuidPartner: String,
                     completion: @escaping (_ response: (result: Result<CommentResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + "/v2/" + APIPath.getComments
        //let url = "http://sksapp.px2x.ru/v2/partner/comment/list"
        
        var headers: [String: String] = [:]
        
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers[HeaderKey.token.rawValue] = accessToken
        }
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    
    // MARK: Отправить жалобу на партнера
    func sendComplaintToPartner(uuidPartner: String,
                                complaint: String,
                                completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + "/v2/" + APIPath.sendComplaint
        //let url = "http://sksapp.px2x.ru/v2/partner/complaint/new"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner,
            "complaint": complaint,
        ]
        
        getResult(url: url,
                  method: .post,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Отправить отзыв партнеру
    func sendCommentToPartner(uuidPartner: String,
                              comment: String,
                                completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + "/v2/" + APIPath.sendComment
        //let url = "http://sksapp.px2x.ru/v2/partner/comment/new"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner,
            "comment": comment,
        ]
        
        getResult(url: url,
                  method: .post,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Получить отзыв о партнере
    func getCommentUser(uuidPartner: String,
                        completion: @escaping (_ response: (result: Result<CheckComment>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + "/v2/" + APIPath.checkComment
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner
        ]
        
        getResult(url: url,
                  method: .post,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }

    }

    // MARK: Редактирование отзыва партнера
    func editCommentToPartner(uuidComment: String,
                              comment: String,
                              completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + "/v2/" + APIPath.editComment
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        let parametrs: Parameters = [
            "uuidComment": uuidComment,
            "comment": comment,
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Поставить оценку партнеру
    func sendRatingToPartner(uuidPartner: String,
                             rating: Double,
                             completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + "/v2/" + APIPath.sendRating
        //let url = "http://sksapp.px2x.ru/v2/partner/rating"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner,
            "rating": rating,
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
     // MARK: Зарегистрироваться на мероприятие
    func registrationOnEvent(idEvent: String,
                             completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion + APIPath.event + "/\(idEvent)"
        
        //let url = "http://sksapp.px2x.ru/v1/news/event/\(idEvent)"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken,
        ]
        
        getResult(url: url,
                  method: .post,
                  headers: headers) { result in
                    completion(result)
        }
    }
        
    // MARK: Отменить регистрацию на мероприятие
    func cancelRegistrationOnEvent(idEvent: String,
                                   completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion + APIPath.event + "/\(idEvent)"
        //let url = "http://sksapp.px2x.ru/v1/news/event/\(idEvent)"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken,
        ]
        
        getResult(url: url,
                  method: .delete,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
     // MARK: Зарегистрироваться на мероприятие
    func sendAnswer(idAnswer: String,
                    completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion + APIPath.pooling + "/\(idAnswer)"
        //let url = "http://sksapp.px2x.ru/v1/news/pooling/\(idAnswer)"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken,
        ]
        
        getResult(url: url,
                  method: .post,
                  headers: headers) { result in
                    completion(result)
        }
    }
    
    // MARK: Получить точки на карте по экрану
    func getPoints(topRightCornerLatitude: String,
                   topRightCornerLongitude: String,
                   lowerLeftCornerLatitude: String,
                   lowerLeftCornerLongitude: String,
                   uuidCategory: String,
                   latUser: String,
                   lngUser: String,
                   completion: @escaping (_ response: (result: Result<MapPointsResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + "/v2/" + APIPath.getPoints
        //let url = "http://sksapp.px2x.ru/v2/partner/list/points"
        
        var parametrs: Parameters = [
            "topRightCorner": [
                "latitude": topRightCornerLatitude,
                "longitude": topRightCornerLongitude
            ],
            "lowerLeftCorner": [
                "latitude": lowerLeftCornerLatitude,
                "longitude": lowerLeftCornerLongitude
            ],
        ]
        
        if uuidCategory != "" {
            parametrs["uuidCategory"] = uuidCategory
        }
        
        if latUser != "" {
            parametrs["latUser"] = latUser
            parametrs["lngUser"] = lngUser
        }
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
                    completion(result)
        }
    }
    
    // MARK: Задать пароль для пользователя
    func setPassword(passwordKey: String,
                     password: String,
                     completion: @escaping (_ response: (result: Result<SetPasswordResponse>, statusCode: Int?)) -> Void) {
        let url = authURI + "/v2/" + APIPath.setPassword
        
        let parametrs: Parameters = [
            "setPasswordKey": passwordKey,
            "newPassword": password
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
                    completion(result)
        }
    }
    
    // MARK: Авторизоваться по паролю
    func enterPassword(loginKey: String,
                       password: String,
                       completion: @escaping (_ response: (result: Result<SetPasswordResponse>, statusCode: Int?)) -> Void) {
        let url = authURI + "/v2/" + APIPath.enterPassword
        
        let parametrs: Parameters = [
            "loginKey": loginKey,
            "password": password
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
                    completion(result)
        }
    }
    
    // MARK: Сбросить пароль
    func resetPassword(phone: String,
                       place: String = "mobile",
                       completion: @escaping (_ response: (result: Result<SmsResponse>, statusCode: Int?)) -> Void) {
        let url = authURI + "/v2/" + APIPath.resetPassword
        //let url = "http://sksauth.px2x.ru/v2/auth/reset"
        
        let parametrs: Parameters = [
            "login" : phone,
            "place" : place
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Получить партнеров для нижней шторки на карте
    func getPartnersMap(uuidCity: String,
                        uuidCategory: String,
                        latUser: String,
                        lngUser: String,
                        completion: @escaping (_ response: (result: Result<MapPartnerResponse>, statusCode: Int?)) -> Void) {
        let url = baseURI + "/v2/" + APIPath.getPartnerPoints
        //let url = "http://sksapp.px2x.ru/v2/partner/list/points"
        var parametrs: Parameters = [:]
        
        if uuidCity != "" {
            parametrs["uuidCity"] = uuidCity
        }
        
        if uuidCategory != "" {
            parametrs["uuidCategory"] = uuidCategory
        }
        
        if latUser != "" {
            parametrs["latitude"] = latUser
            parametrs["longitude"] = lngUser
        }
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs) { result in
                    completion(result)
        }
    }
    
    // MARK: - Лайкнуть комментарий
    func likeComment(uuidComment: String,
                       completion: @escaping (_ response: (result: Result<LikeResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + "/v2/" + APIPath.commentLike
        
        let headers = [
            HeaderKey.token.rawValue: accessToken,
        ]
        
        let parametrs: Parameters = [
            "uuidComment" : uuidComment
        ]
        
        getResult(url: url,
                  method: .put,
                  parameters: parametrs,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    func upusesPartner(uuidPartner: String,
                       completion: @escaping (_ response: (result: Result<StatusResponse>, statusCode: Int?)) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        
        let url = baseURI + "/v2/" + APIPath.upuses + "/\(uuidPartner)"
        
        let headers = [
            HeaderKey.token.rawValue: accessToken,
        ]
        
        getResult(url: url,
                  method: .post,
                  headers: headers) { result in
            completion(result)
        }
    }
}
