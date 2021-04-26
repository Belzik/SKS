//
//  RememberCity.swift
//  SKS
//
//  Created by Alexander on 05/02/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import Foundation

class RememberCity: NSObject, NSCoding {
    var uuidCity: String?
    var name: String?
    
    required override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.uuidCity = aDecoder.decodeObject(forKey: "uuidCity") as? String ?? nil
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? nil
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uuidCity, forKey: "uuidCity")
        aCoder.encode(name, forKey: "name")
    }

    func save() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "rememberCity")
            UserDefaults.standard.synchronize()
        } catch(let error) {
            print(error.localizedDescription)
        }
    }

    class func clear() {
        if UserDefaults.standard.object(forKey: "rememberCity") != nil {
            UserDefaults.standard.removeObject(forKey: "rememberCity")
        }
    }

    class func loadSaved() -> RememberCity? {
        if let data = UserDefaults.standard.object(forKey: "rememberCity") as? Data {
            let rememberCity = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? RememberCity
            return rememberCity
        }
        return nil
    }
}
