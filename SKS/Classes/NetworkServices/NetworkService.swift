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
    static let newsRead        = "news/status/read"
    static let newsUnread      = "news/count/unread"
    static let getPoints       = "partner/list/points"
    static let getPartnerPoints = "partner/list/map"
    static let checkComment    = "partner/comment/check"
    static let editComment     = "partner/comment/edit"
    static let upuses          = "partners/upuses"
    static let authVK          = "auth/vk"
    static let authApple       = "auth/apple"
    static let addToFavorite   = "partners/add-to-favorite"
    static let deleteFromFavorite = "partners/delete-from-favorite"
    static let getKnowledges   = "/knowledge-base-categories"
    static let getKnowledge    = "/knowledge-base-questions"
    static let getQuestion     = "/knowledge-base-question-show"
    static let votesQuestion   = "/knowledge-base-vote-add"
    static let sendComplaintOnNews = "news/complaint/new"
    static let getLinkToMessager = "get-link-to-messenger"
    static let createRzdRequest = "create-request"
    static let getRzdRequest = "get-request"
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

class NetworkManager: BaseRequest {
    
    // MARK: - Properties
    
    static let shared = NetworkManager()
    let decoder = JSONDecoder()
    
//    let baseURI = "https://sks-mobile.develophost.ru"
//    let authURI = "https://sks-auth.develophost.ru"
    
    let baseURI = "https://app.sksadmin.ru"
    let authURI = "https://auth.sksadmin.ru"
    
    let apiVersion1 = "/v1/"
    let apiVersion2 = "/v2/"
    
    // MARK: - Object life cycle
    
    private override init() {}
    
    // MARK: - Internal methods

    // MARK: - Получить все категории
    func getCategories(completion: @escaping (_ result: BaseResponse<CategoriesResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.category
        
        request(url: url) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить все акции
    func getStocks(category: String? = nil,
                   uuidCity: String? = nil,
                   searchString: String? = nil,
                   limit: Int,
                   offset: Int,
                   completion: @escaping (_ result: BaseResponse<StocksResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.stock
        
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
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: "X-Limit", value: String(describing: limit)),
            HTTPHeader(name: "X-Offset", value: String(describing: offset))
        ]
        
        request(url: url,
                  method: .put,
                  parameters: parameters,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить определенную акцию
    func getStock(idStock: String,
                  uuidCity: String,
                  completion: @escaping (_ result: BaseResponse<Stock>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.stock + "/\(idStock)"
        
        let parameters: Parameters = ["uuidCity": uuidCity]
        
        request(url: url,
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
                     completion: @escaping (_ result: BaseResponse<PartnersResponse>) -> Void) {
        let url = baseURI +  apiVersion2 + APIPath.partner
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
        
        if let uuidCategory = category {
            if uuidCategory == "favorite" {
                parameters = [:]
                parameters["onlyFavorite"] = true
            }
        }
        
        var headers: HTTPHeaders = [
            HTTPHeader(name: "X-Limit", value: String(describing: limit)),
            HTTPHeader(name: "X-Offset", value: String(describing: offset))
        ]
        
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }
        
        request(url: url,
                  method: .put,
                  parameters: parameters,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить определенного партнера
    func getPartner(uuidPartner: String,
                    uuidCity: String,
                    completion: @escaping (_ result: BaseResponse<Partner>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.partner + "/\(uuidPartner)"

        //let url = "http://sksapp.px2x.ru/v2/partner" + "/\(uuidPartner)"
        let parameters: Parameters = ["uuidCity": uuidCity]
        
        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }
        
        request(url: url,
                  method: .put,
                  parameters: parameters,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить СМС с кодом на телефон
    func getCodeWithSms(phone: String,
                        place: String = "mobile",
                        completion: @escaping (_ result: BaseResponse<SmsResponse>) -> Void) {
        let url = authURI + apiVersion2 + APIPath.getSmsWithCode
        
        let parametrs: Parameters = [
            "login" : phone,
            "place" : place
        ]
        
        request(url: url,
                  method: .post,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: - Проверить код из СМС
    func verifyCodeSms(phone: String,
                       attempt: String,
                       code: String,
                       completion: @escaping (_ result: BaseResponse<OtpResponse>) -> Void) {
        let url = authURI + "/v2/" + APIPath.verifyCodeSms
        
        let parametrs: Parameters = [
            "login": phone,
            "attempt": attempt,
            "confirmCode": code
        ]
        
        request(url: url,
                  method: .post,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Получить все города, в которых есть университеты
    func getСityUniversities(completion: @escaping (_ result: BaseResponse<CitiesResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.cityUniversitie
        
        request(url: url) { result in
            completion(result)
        }
    }
    
    // MARK: Получить все университеты в определенном городе
    func getUniversities(uuidCity: String,
                         completion: @escaping (_ result: BaseResponse<UniversitiesResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.universities
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.userCity.rawValue, value: uuidCity)
        ]
        
        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Получить все факультеты в определенном университете
    func getFaculties(uuidUniver: String,
                      completion: @escaping (_ result: BaseResponse<FacultiesResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.faculties
        
        let headers: HTTPHeaders = [
            HeaderKey.userUniver.rawValue: uuidUniver
        ]
        
        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Получить все специальности в определенном факультете
    func getSpecialties(uuidFaculty: String,
                        completion: @escaping (_ result: BaseResponse<SpecialtiesResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.specialties
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.userFaculty.rawValue, value: uuidFaculty)
        ]
        
        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Получить города для фильтрации партнеров
    func getCityPartners(completion: @escaping (_ result: BaseResponse<CitiesResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.cityPartners
        
        request(url: url,
                method: .put) { result in
            completion(result)
        }
    }
    
    // MARK: Отправить фото пользователя
    func uploadImage(image: UIImage,
                     completion: @escaping (_ response: BaseResponse<PathFile>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.uploadPhoto
        
        var headers: HTTPHeaders = []
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers.add(HTTPHeader(name: "DeviceType", value: "iOs"))
            headers.add(HTTPHeader(name: "Version", value: appVersion))
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            guard let jpegData = image.jpegData(compressionQuality: 0.5) else { return }
            
            multipartFormData.append(jpegData,
                                     withName: "imageFile",
                                     fileName: "userPhoto.jpg",
                                     mimeType: "image/jpg")
            
        },
        to: url,
        headers: headers)
            .responseDecodable(of: PathFile.self) { response in
            let baseResponse = BaseResponse(value: response.value,
                                            responseCode: response.response?.statusCode)
            completion(baseResponse)
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
                      accessToken: String,
                      keyPhoto: String,
                      phone: String,
                      completion: @escaping (_ response: BaseResponse<UserData>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.student
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        var parametrs: Parameters = [
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
            "keyPhoto": keyPhoto
        ]
        
        if phone != "" {
            parametrs["phone"] = phone
        }
        
        request(url: url,
                method: .post,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Рефреш токена
    func refreshToken(refreshToken: String,
                      completion: @escaping (_ result: BaseResponse<TokensResponse>) -> Void) {
        let url = authURI + apiVersion1 + APIPath.refreshToken
        
        let parametrs: Parameters = [
            "refreshToken": refreshToken,
        ]
        
        request(url: url,
                  method: .put,
                  parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить профиль пользовател
    func getInfoUser(completion: @escaping (_ response: BaseResponse<UserData>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion1 + APIPath.student
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }
    
    func sendNotificationToken(notificationToken: String,
                               deviceToken: String,
                               accessToken: String = "",
                               completion: @escaping (_ response: AFDataResponse<Data>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.sendNotificationToken
        let parameters: Parameters = [
            "token": notificationToken,
            "device": "iOs",
            "idDevice": deviceToken
        ]
        
        var headers: HTTPHeaders = [
            HeaderKey.token.rawValue: accessToken
        ]
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers["DeviceType"] = "iOs"
            headers["Version"] = appVersion
        }
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   headers: headers)
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
                        phone: String,
                        completion: @escaping (_ response: BaseResponse<UserData>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }

        let url = baseURI + apiVersion1 + APIPath.student
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        var parametrs: Parameters = [
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
        ]
        
        if phone != "" {
            parametrs["phone"] = phone
        }
        
        request(url: url,
                method: .put,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Получить торговые точки партнера
    func getSalePoints(uuidPartner: String,
                       uuidCity: String,
                       latitude: String,
                       longitude: String,
                       completion: @escaping (_ response: BaseResponse<SalePointsResponse>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.getSalePoints
        
        var parametrs: Parameters = [
            "uuidCity": uuidCity,
            "uuidPartner": uuidPartner
        ]
        
        if latitude != "" {
            parametrs["latitude"] = latitude
            parametrs["longitude"] = longitude
        }
        
        request(url: url,
                method: .put,
                parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Получить оценки и их статистику по партнеру
    func getRatingStatictis(uuidPartner: String,
                            completion: @escaping (_ response: BaseResponse<RatingStatistic>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.getStatistics + "/\(uuidPartner)"
        
        var headers: HTTPHeaders = []
        
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }
        
        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить новости
    func getNews(limit: Int,
                 offset: Int,
                 completion: @escaping (_ result: BaseResponse<NewsResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.getNews
        
        var headers: HTTPHeaders = [
            HTTPHeader(name: "X-Limit", value: String(describing: limit)),
            HTTPHeader(name: "X-Offset", value: String(describing: offset))
        ]
        
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }
        
        request(url: url,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить новость
    func getSingleNews(uuidNews: String,
                       completion: @escaping (_ result: BaseResponse<News>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.getNews + "/\(uuidNews)"
        
        var headers: HTTPHeaders = [:]
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }
        
        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: - Получить комментарии партнера
    func getComments(uuidPartner: String,
                     completion: @escaping (_ response: BaseResponse<CommentResponse>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.getComments
        
        var headers: HTTPHeaders = []
        
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner
        ]
        
        request(url: url,
                  method: .put,
                  parameters: parametrs,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    
    // MARK: Отправить жалобу на партнера
    func sendComplaintToPartner(uuidPartner: String,
                                complaint: String,
                                completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.sendComplaint
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner,
            "complaint": complaint,
        ]
        
        request(url: url,
                method: .post,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Отправить отзыв партнеру
    func sendCommentToPartner(uuidPartner: String,
                              comment: String,
                                completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.sendComment
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner,
            "comment": comment,
        ]
        
        request(url: url,
                  method: .post,
                  parameters: parametrs,
                  headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Получить отзыв о партнере
    func getCommentUser(uuidPartner: String,
                        completion: @escaping (_ response: BaseResponse<CheckComment>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.checkComment
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner
        ]
        
        request(url: url,
                method: .post,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }

    }

    // MARK: Редактирование отзыва партнера
    func editCommentToPartner(uuidComment: String,
                              comment: String,
                              completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.editComment
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parametrs: Parameters = [
            "uuidComment": uuidComment,
            "comment": comment,
        ]
        
        request(url: url,
                method: .put,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }
    
    // MARK: Поставить оценку партнеру
    func sendRatingToPartner(uuidPartner: String,
                             rating: Double,
                             completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.sendRating
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parametrs: Parameters = [
            "uuidPartner": uuidPartner,
            "rating": rating,
        ]
        
        request(url: url,
                method: .put,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }
    
     // MARK: Зарегистрироваться на мероприятие
    func registrationOnEvent(idEvent: String,
                             completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion1 + APIPath.event + "/\(idEvent)"
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        request(url: url,
                method: .post,
                headers: headers) { result in
            completion(result)
        }
    }
        
    // MARK: Отменить регистрацию на мероприятие
    func cancelRegistrationOnEvent(idEvent: String,
                                   completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion1 + APIPath.event + "/\(idEvent)"
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        request(url: url,
                method: .delete,
                headers: headers) { result in
            completion(result)
        }
    }
    
     // MARK: Зарегистрироваться на мероприятие
    func sendAnswer(idAnswer: String,
                    completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion1 + APIPath.pooling + "/\(idAnswer)"
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        request(url: url,
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
                   searchString: String,
                   completion: @escaping (_ response: BaseResponse<MapPointsResponse>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.getPoints
        
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
        
        if searchString != "" {
            parametrs["searchString"] = searchString
        }
        
        request(url: url,
                method: .put,
                parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Задать пароль для пользователя
    func setPassword(passwordKey: String,
                     password: String,
                     completion: @escaping (_ response: BaseResponse<SetPasswordResponse>) -> Void) {
        let url = authURI + apiVersion2 + APIPath.setPassword
        
        let parametrs: Parameters = [
            "setPasswordKey": passwordKey,
            "newPassword": password
        ]
        
        request(url: url,
                method: .put,
                parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Авторизоваться по паролю
    func enterPassword(loginKey: String,
                       password: String,
                       completion: @escaping (_ response: BaseResponse<SetPasswordResponse>) -> Void) {
        let url = authURI + apiVersion2 + APIPath.enterPassword
        
        let parametrs: Parameters = [
            "loginKey": loginKey,
            "password": password
        ]
        
        request(url: url,
                method: .put,
                parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: Сбросить пароль
    func resetPassword(phone: String,
                       place: String = "mobile",
                       completion: @escaping (_ response: BaseResponse<SmsResponse>) -> Void) {
        let url = authURI + apiVersion2 + APIPath.resetPassword
        
        let parametrs: Parameters = [
            "login" : phone,
            "place" : place
        ]
        
        request(url: url,
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
                        searchString: String,
                        completion: @escaping (_ response: BaseResponse<MapPartnerResponse>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.getPartnerPoints

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
        
        if searchString != "" {
            parametrs["searchString"] = searchString
        }
        
        request(url: url,
                method: .put,
                parameters: parametrs) { result in
            completion(result)
        }
    }
    
    // MARK: - Лайкнуть комментарий
    func likeComment(uuidComment: String,
                       completion: @escaping (_ response: BaseResponse<LikeResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.commentLike
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parametrs: Parameters = [
            "uuidComment" : uuidComment
        ]
        
        request(url: url,
                method: .put,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }
    
    func upusesPartner(uuidPartner: String,
                       completion: @escaping (_ response: BaseResponse<StatusResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        
        let url = baseURI + apiVersion2 + APIPath.upuses + "/\(uuidPartner)"
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        request(url: url,
                method: .post,
                headers: headers) { result in
            completion(result)
        }
    }
    
    func authVK(userId: String,
                vkToken: String,
                completion: @escaping (_ response: BaseResponse<AuthVKResponse>) -> Void) {
        let url = authURI + apiVersion1 + APIPath.authVK
        
        let parametrs: Parameters = [
            "vkToken": vkToken,
            "vkId": userId,
            "place": "mobile"
        ]
        
        request(url: url,
                method: .post,
                parameters: parametrs) { result in
            completion(result)
        }
    }
    
    func addPartnerToFavorite(uuidPartner: String,
                              completion: @escaping (_ response: BaseResponse<AddToFavoriteResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.addToFavorite
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        let parameters: Parameters = [
            "uuidPartner": uuidPartner
        ]
        
        request(url: url,
                method: .post,
                parameters: parameters,
                headers: headers) { result in
            completion(result)
        }
    }
    
    func deletePartnerFromFavorite(uuidPartner: String,
                                   completion: @escaping (_ response: BaseResponse<AddToFavoriteResponse>) -> Void) {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        let url = baseURI + apiVersion2 + APIPath.deleteFromFavorite + "/\(uuidPartner)"
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken)
        ]
        
        request(url: url,
                method: .delete,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - База знаний
    func getKnowledges(
        limit: Int = 100,
        offset: Int = 0,
        completion: @escaping (_ result: BaseResponse<KnowledgesResponse>) -> Void) {
        let url = baseURI + APIPath.getKnowledges

        var headers: HTTPHeaders = [
            HTTPHeader(name: "X-Limit", value: String(describing: limit)),
            HTTPHeader(name: "X-Offset", value: String(describing: offset))
        ]

        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        request(url: url,
                  headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Список вопросов
    func getKnowledge(
        limit: Int = 100,
        offset: Int = 0,
        uuid: String,
        completion: @escaping (_ result: BaseResponse<KnowledgeResponse>) -> Void) {
        let url = baseURI + APIPath.getKnowledge + "?uuid=\(uuid)"

        var headers: HTTPHeaders = [
            HTTPHeader(name: "X-Limit", value: String(describing: limit)),
            HTTPHeader(name: "X-Offset", value: String(describing: offset)),
        ]

        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Вопрос
    func getQuestion(uuid: String, completion: @escaping (_ result: BaseResponse<Question>) -> Void) {
        let url = baseURI + APIPath.getQuestion + "?uuid=\(uuid)"

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Голосовать
    func sendVote(uuid: String, isUseful: Bool, completion: @escaping (_ result: BaseResponse<Vote>) -> Void) {
        let url = baseURI + APIPath.votesQuestion

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        var parametrs: Parameters = [:]
        parametrs["uuid"] = uuid
        parametrs["vote"] = isUseful ? 1 : 0

        request(url: url,
                method: .post,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Отправить жалобу на Новость
    func sendComplaintAboutNews(uuidNews: String, complaint: String, completion: @escaping (_ result: BaseResponse<StatusResponse>) -> Void) {
        let url = baseURI + apiVersion2 + APIPath.sendComplaintOnNews

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        var parametrs: Parameters = [:]
        parametrs["uuidNews"] = uuidNews
        parametrs["complaint"] = complaint

        request(url: url,
                method: .post,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Получить ссылку на месснеджер универа
    func getLinkToMessager(completion: @escaping (_ result: BaseResponse<String>) -> Void) -> Void {
        let url = baseURI + apiVersion1 + APIPath.getLinkToMessager

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        AF.request(
            url,
            headers: headers)
            .responseString { response in
                let baseResponse = BaseResponse(value: response.value,
                                                responseCode: response.response?.statusCode)
                completion(baseResponse)
            }
    }

    // MARK: - Получить статус заявки РЖД
    func getRzdRequest(completion: @escaping (_ result: BaseResponse<RzdRequest>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.getRzdRequest

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Отправить заявку на РЖД
    func sendRzdRequest(id: String, completion: @escaping (_ result: BaseResponse<RzdRequest>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.createRzdRequest

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        var parametrs: Parameters = [:]
        parametrs["id"] = id

        request(url: url,
                method: .post,
                parameters: parametrs,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: - Авторизация через apple
    func authApple(userId: String,
                   email: String,
                   completion: @escaping (_ response: BaseResponse<AuthVKResponse>) -> Void) {
        let url = authURI + apiVersion2 + APIPath.authApple

        let parametrs: Parameters = [
            "appleToken": userId,
            "login": email,
            "place": "mobile"
        ]

        request(url: url,
                method: .post,
                parameters: parametrs,
                encoding: URLEncoding.default) { result in
            completion(result)
        }
    }

    // MARK: Количество непрочитанный новостей

    func getNumberUnreadNessages(completion: @escaping (_ result: BaseResponse<NewsCountResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.newsUnread

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        request(url: url,
                headers: headers) { result in
            completion(result)
        }
    }

    // MARK: Прочитать новости

    func putReadNews(completion: @escaping (_ result: BaseResponse<StatusResponse>) -> Void) {
        let url = baseURI + apiVersion1 + APIPath.newsRead

        var headers: HTTPHeaders = []
        if let accessToken = UserData.loadSaved()?.accessToken {
            headers.add(HTTPHeader(name: HeaderKey.token.rawValue, value: accessToken))
        }

        request(url: url,
                method: .put,
                headers: headers) { result in
            completion(result)
        }
    }
}
