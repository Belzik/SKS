//
//  BaseRequest.swift
//  BeFriends
//
//  Created by Александр Катрыч on 29.07.2020.
//  Copyright © 2020 Sheverev. All rights reserved.
//

import Alamofire

struct BaseResponse<T: Codable> {
    let value: T?
    let responseCode: Int?
}

class BaseRequest {
    
    // MARK: - Methods
    
    @discardableResult
    func request<ResponseType: Codable, Parameters: Encodable>(
        url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        completion: @escaping (_ response: BaseResponse<ResponseType>) -> Void) -> DataRequest {
        
        var requestHeaders = HTTPHeadersFactory().makesDefaultHeaders()
        if let headers = headers {
            for header in headers {
                requestHeaders.add(header)
            }
        }

        return AF.request(url,
                          method: method,
                          parameters: parameters,
                          encoder: encoder,
                          headers: requestHeaders,
                          interceptor: interceptor)
                 .responseDecodable(of: ResponseType.self) { response in
                    
            self.showAlertWithVersionUpdateMessage(statusCode: response.response?.statusCode)
            let baseResponse = BaseResponse(value: response.value,
                                            responseCode: response.response?.statusCode)
            completion(baseResponse)
        }
    }
    
    @discardableResult
    func request<ResponseType: Codable>(
        url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: JSONEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        completion: @escaping (_ response: BaseResponse<ResponseType>) -> Void) -> DataRequest {
        
        var requestHeaders = HTTPHeadersFactory().makesDefaultHeaders()
        if let headers = headers {
            for header in headers {
                requestHeaders.add(header)
            }
        }
        
        return AF.request(url, method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: requestHeaders,
                   interceptor: interceptor)
                 .responseDecodable(of: ResponseType.self) { response in
            
            self.showAlertWithVersionUpdateMessage(statusCode: response.response?.statusCode)
            let baseResponse = BaseResponse(value: response.value,
                                            responseCode: response.response?.statusCode)
            completion(baseResponse)
        }
    }
    
    private func showAlertWithVersionUpdateMessage(statusCode: Int?) {
        guard let statusCode = statusCode,
              let vc = UIWindow.getVisibleViewController(nil) else { return }

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
    
}
