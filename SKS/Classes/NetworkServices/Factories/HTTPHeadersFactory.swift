//
//  HTTPHeadersFactory.swift
//  BeFriends
//
//  Created by Александр Катрыч on 29.07.2020.
//  Copyright © 2020 Sheverev. All rights reserved.
//

import Foundation
import Alamofire

class HTTPHeadersFactory {
    
    // MARK: - Methods
    
    func makesDefaultHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = []
        
        let deviceTypeHeader = HTTPHeader(name: "DeviceType",
                                          value: "iOs")
        headers.add(deviceTypeHeader)
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let appVersionHeader = HTTPHeader(name: "Version",
                                              value: appVersion)
            headers.add(appVersionHeader)
        }
        
        if let languageCode = Locale.current.languageCode {
            let localeHeader = HTTPHeader(name: "X-Locale",
                                          value: languageCode.uppercased())
            
            headers.add(localeHeader)
        }
        
        return headers
    }
    
}
