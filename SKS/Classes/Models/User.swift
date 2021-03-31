//
//  User.swift
//  SKS
//
//  Created by Александр Катрыч on 24/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class UserData: NSObject, NSCoding, Codable {
    var uuidUser: String?
    var status: String?
    var statusReason: String?
    var phone: String?
    var vk: Bool?
    var studentCode: String?
    var studentInfo: StudentInfo?
    
    var accessToken: String?
    var refreshToken: String?
    var uniqueSess: String?
    
    enum CodingKeys: String, CodingKey {
        case uuidUser
        case status
        case statusReason
        case phone
        case studentCode
        case studentInfo
        case uniqueSess
        case vk
    }
    
    required override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.uuidUser = aDecoder.decodeObject(forKey: "uuidUser") as? String ?? nil
        self.status = aDecoder.decodeObject(forKey: "status") as? String ?? nil
        self.statusReason = aDecoder.decodeObject(forKey: "statusReason") as? String ?? nil
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String ?? nil
        self.studentCode = aDecoder.decodeObject(forKey: "studentCode") as? String ?? nil
        self.accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String ?? nil
        self.refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String ?? nil
        self.uniqueSess = aDecoder.decodeObject(forKey: "uniqueSess") as? String ?? nil
        self.studentInfo = aDecoder.decodeObject(forKey: "studentInfo") as? StudentInfo ?? nil
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uuidUser, forKey: "uuidUser")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(statusReason, forKey: "statusReason")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(studentCode, forKey: "studentCode")
        aCoder.encode(accessToken, forKey: "accessToken")
        aCoder.encode(refreshToken, forKey: "refreshToken")
        aCoder.encode(uniqueSess, forKey: "uniqueSess")
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "userData")
        UserDefaults.standard.synchronize()
    }
    
    class func clear() {
        if UserDefaults.standard.object(forKey: "userData") != nil {
            UserDefaults.standard.removeObject(forKey: "userData")
        }
    }
    
    class func loadSaved() -> UserData? {
        if let data = UserDefaults.standard.object(forKey: "userData") as? NSData {
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? UserData
            return userData
        }
        return nil
    }
}

class StudentInfo: Codable {
    var name: String?
    var patronymic: String?
    var surname: String?
    var birthdate: String?
    var startEducation: String?
    var endEducation: String?
    var course: Int?
    var nameCity: String?
    var uuidCity: String?
    var photo: String?
    var nameUniversity: String?
    var uuidUniversity: String?
    var nameFaculty: String?
    var uuidFaculty: String?
    var nameSpecialty: String?
    var uuidSpecialty: String?
    var shortNameUniversity: String?
    
    var fio: String {
        var string = ""
        
        if let surname = surname,
            surname != "" {
            string += surname
        }
        
        if let name = name,
            name != "" {
            string += " " + name
        }
        
        if let patronymic = patronymic,
            patronymic != "" {
            string += " " + patronymic
        }
        
        return string
    }
}
