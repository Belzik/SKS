//
//  DateManager.swift
//  SKS
//
//  Created by Александр Катрыч on 25/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class DateManager {
    static let shared = DateManager()
    private var dateFormatter = DateFormatter()
    
    private init() {}
    
    func toPeriod(dateStart: String?, dateEnd: String?) -> String {
        if let dateStart = dateStart,
            let dateEnd = dateEnd {
            
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let date = dateFormatter.date(from: dateStart)
            
            if let date = date {
                dateFormatter.dateFormat = "dd.MM"
                
                let period = "c \(dateFormatter.string(from: date)) - \(dateEnd)"
                
                return period
            }
            
            return ""
        } else {
            return ""
        }
    }
    
    func toDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale.init(identifier: "ru")

        return dateFormatter.date(from: dateString)
    }
}
