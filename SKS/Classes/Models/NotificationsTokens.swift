//
//  NotificationsTokens.swift
//  SKS
//
//  Created by Alexander on 11/09/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class NotificationsTokens: NSObject, NSCoding {
    var deviceToken: String?
    var notificationToken: String?
    var isDownload: Bool?
    
    required override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.deviceToken = aDecoder.decodeObject(forKey: "deviceToken") as? String ?? nil
        self.notificationToken = aDecoder.decodeObject(forKey: "notificationToken") as? String ?? nil
        self.isDownload = aDecoder.decodeObject(forKey: "isDownload") as? Bool ?? nil
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(deviceToken, forKey: "deviceToken")
        aCoder.encode(notificationToken, forKey: "notificationToken")
        aCoder.encode(isDownload, forKey: "isDownload")
    }
    
    func save() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "tokens")
            UserDefaults.standard.synchronize()
        } catch(let error) {
            print(error.localizedDescription)
        }

    }
    
    class func clear() {
        if UserDefaults.standard.object(forKey: "tokens") != nil {
            UserDefaults.standard.removeObject(forKey: "tokens")
        }
    }
    
    class func loadSaved() -> NotificationsTokens? {
        if let data = UserDefaults.standard.object(forKey: "tokens") as? Data {
            let tokens = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NotificationsTokens
            return tokens
        }
        return nil
    }
}
