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

    func toDateString(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "ru")
        let date = dateFormatter.date(from: date)

        if let date = date {
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter.string(from: date)
        }

        return ""
    }

    func toDatePool(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "ru")

        return dateFormatter.date(from: dateString)
    }
    
    func toDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale.init(identifier: "ru")

        return dateFormatter.date(from: dateString)
    }
    
     func getDifferenceTime(from start: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let startDate = dateFormatter.date(from: start) else {
                return ""
        }

        let difference = Calendar.current.dateComponents([.minute], from: startDate, to: Date()).minute
        
        if let difference = difference {
            if difference <= 1 {
                return "Только что"
            }
            
            if difference < 60 {
                return "\(difference) минут назад"
            }
            
            if difference < 1440 {
                let house = difference / 60
                return "\(house) часов назад"
            }
            
            if difference > 1440 &&
                difference < 2880 {
                
                return "Вчера"
            }
            
            if difference > 2880 &&
                difference < 4320 {
                return "Позавчера"
            }
            
            if difference > 4320 {
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: startDate)
                return dateString
            }
        }
        
        return ""
    }
}
