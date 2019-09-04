//
//  String.swift
//  SKS
//
//  Created by Александр Катрыч on 15/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

private let __emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
private let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

private let __phoneRegex = "^[0-9+]{0,1}+[0-9]{10,16}$"
private let __phonePredicate = NSPredicate(format: "SELF MATCHES %@", __phoneRegex)

private let __passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,8}$"
private let __passwordPredicate = NSPredicate(format: "SELF MATCHES %@", __passwordRegex)

private let __passportSerialAndNumberRegex = "[0-9]{4} [0-9]{6}"
private let __passportSerialAndNumberPredicate = NSPredicate(format: "SELF MATCHES %@", __passportSerialAndNumberRegex)

private let __passportPlaceCodeRegex = "[0-9]{3}-[0-9]{3}"
private let __passportPlaceCodePredicate = NSPredicate(format: "SELF MATCHES %@", __passportPlaceCodeRegex)

private let __indexRegex = "[0-9]{6}"
private let __indexPredicate = NSPredicate(format: "SELF MATCHES %@", __indexRegex)

private let __ptsSerialAndNumberRegex = "[A-Z0-9a-zЁёА-я0-9]{2} [A-Z0-9a-zЁёА-я0-9]{2} [A-Z0-9a-zЁёА-я0-9]{6}"
private let __ptsSerialAndNumberPredicate = NSPredicate(format: "SELF MATCHES %@", __ptsSerialAndNumberRegex)

private let __vinRegex = "[A-Z0-9a-z0-9ЁёА-я]{17}"
private let __vinPredicate = NSPredicate(format: "SELF MATCHES %@", __vinRegex)

private let __gosNumberRegex = "[A-Z0-9a-zЁёА-я0-9]{1} [A-Z0-9a-zЁёА-я0-9]{3} [A-Z0-9a-zЁёА-я0-9]{2} [A-Z0-9a-zЁёА-я0-9]{3} RUS"
private let __gosNumberPredicate = NSPredicate(format: "SELF MATCHES %@", __gosNumberRegex)

private let __cardRegex = "[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4}"
private let __cardPredicate = NSPredicate(format: "SELF MATCHES %@", __cardRegex)

private let __yandexWalletRegex = "[0-9]{5} [0-9]{5} [0-9]{5}"
private let __yandexWalletPredicate = NSPredicate(format: "SELF MATCHES %@", __yandexWalletRegex)

extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
    
    func isPhone() -> Bool {
        return __phonePredicate.evaluate(with: self)
    }
    
    func isPassword() -> Bool {
        return __passwordPredicate.evaluate(with: self)
    }
    
    func isPassportSerialAndNumber() -> Bool {
        return __passportSerialAndNumberPredicate.evaluate(with: self)
    }
    
    func isPassportPlaceCode() -> Bool {
        return __passportPlaceCodePredicate.evaluate(with: self)
    }
    
    func isIndex() -> Bool {
        return __indexPredicate.evaluate(with: self)
    }
    
    func isPtsSerialAndNumber() -> Bool {
        return __ptsSerialAndNumberPredicate.evaluate(with: self)
    }
    
    func isVin() -> Bool {
        return __vinPredicate.evaluate(with: self)
    }
    
    func isGosNumber() -> Bool {
        return __gosNumberPredicate.evaluate(with: self)
    }
    
    func isCard() -> Bool {
        return __cardPredicate.evaluate(with: self)
    }
    
    func isYandexWallet() -> Bool {
        return __yandexWalletPredicate.evaluate(with: self)
    }
    
    func with(mask: String, replacementChar: Character, isDecimalDigits: Bool) -> String {
        if self.count > 0 && mask.count > 0 {
            let tempString = isDecimalDigits ? self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() :
                self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            
            var finalText = ""
            var stop = false
            
            var formatterIndex = mask.startIndex
            var tempIndex = tempString.startIndex
            
            while !stop {
                let formattingPatternRange = formatterIndex..<mask.index(formatterIndex, offsetBy: 1)
                
                if mask.substring(with: formattingPatternRange) != String(replacementChar) {
                    finalText = finalText.appendingFormat(mask.substring(with: formattingPatternRange))
                } else if tempString.count > 0 {
                    let pureStringRange = tempIndex..<tempString.index(tempIndex, offsetBy: 1)
                    finalText = finalText.appendingFormat(tempString.substring(with: pureStringRange))
                    tempIndex = tempString.index(tempIndex, offsetBy: 1)
                }
                
                formatterIndex = mask.index(formatterIndex, offsetBy: 1)
                
                if formatterIndex >= mask.endIndex || tempIndex >= tempString.endIndex {
                    stop = true
                }
            }
            
            stop = false
            while !stop {
                if formatterIndex >= mask.endIndex {
                    stop = true
                    break
                }
                
                if mask[formatterIndex] == replacementChar {
                    stop = true
                } else {
                    finalText += String(mask[formatterIndex])
                    formatterIndex = mask.index(formatterIndex, offsetBy: 1)
                }
            }
            
            return finalText
        }
        return ""
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}


extension String {
    
    subscript(bounds: CountableClosedRange<Int>) -> String {
        let lowerBound = max(0, bounds.lowerBound)
        guard lowerBound < self.count else { return "" }
        
        let upperBound = min(bounds.upperBound, self.count-1)
        guard upperBound >= 0 else { return "" }
        
        let i = index(startIndex, offsetBy: lowerBound)
        let j = index(i, offsetBy: upperBound-lowerBound)
        
        return String(self[i...j])
    }
    
    subscript(bounds: CountableRange<Int>) -> String {
        let lowerBound = max(0, bounds.lowerBound)
        guard lowerBound < self.count else { return "" }
        
        let upperBound = min(bounds.upperBound, self.count)
        guard upperBound >= 0 else { return "" }
        
        let i = index(startIndex, offsetBy: lowerBound)
        let j = index(i, offsetBy: upperBound-lowerBound)
        
        return String(self[i..<j])
    }
}
