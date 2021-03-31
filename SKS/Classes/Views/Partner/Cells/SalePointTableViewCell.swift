//
//  SalePointTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 02/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class SalePointTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var openedLabel: UILabel!
    
    var model: SalePoint? {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        guard let model = model else { return }
        
        addressLabel.text = model.address
        
        if let distance = model.distance,
            distance != -1 {
            if distance > 1000 {
                self.distanceLabel.text = "\(String(format:"%.1f", (Double(distance) / 1000))) км"
            } else {
                self.distanceLabel.text = "\(distance) м"
            }
        } else {
            distanceLabel.text = ""
        }
        
        if let isOpenedNow = model.isOpenedNow,
            isOpenedNow {
            openedLabel.text = "Открыто"
            openedLabel.textColor = ColorManager.green.value
        } else {
            openedLabel.text = "Закрыто"
            openedLabel.textColor = ColorManager.red.value
        }
        
        if let timeWork = model.timeWork {
            if timeWork.count != 7 {
                workTimeLabel.text = ""
                return
            }
            
            if timeWork[0].endWork == timeWork[1].endWork &&
                timeWork[0].endWork == timeWork[2].endWork &&
                timeWork[0].endWork == timeWork[3].endWork &&
                timeWork[0].endWork == timeWork[4].endWork {
                
                if let startWork = timeWork[0].startWork,
                    let endWork = timeWork[0].endWork {
                    workTimeLabel.text = "Будние дни: \(startWork)-\(endWork), "
                }
            } else {
                var text = ""
                if let startWork = timeWork[0].startWork,
                    let endWork = timeWork[0].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text = "ПН: \(startWork), "
                    } else {
                        text = "ПН: \(startWork)-\(endWork), "
                    }
                    
                }
                
                if let startWork = timeWork[1].startWork,
                    let endWork = timeWork[1].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text += "ВТ: \(startWork), "
                    } else {
                        text += "ВТ: \(startWork)-\(endWork), "
                    }
                }
                
                if let startWork = timeWork[2].startWork,
                    let endWork = timeWork[2].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text += "СР: \(startWork), "
                    } else {
                        text += "СР: \(startWork)-\(endWork), "
                    }
                }
                
                if let startWork = timeWork[3].startWork,
                    let endWork = timeWork[3].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text += "ЧТ: \(startWork), "
                    } else {
                        text += "ЧТ: \(startWork)-\(endWork), "
                    }
                }
                
                if let startWork = timeWork[4].startWork,
                    let endWork = timeWork[4].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text += "ПТ: \(startWork), "
                    } else {
                        text += "ПТ: \(startWork)-\(endWork), "
                    }
                }
                
                workTimeLabel.text = text
            }
            
            if timeWork[5].startWork == timeWork[6].startWork &&
                timeWork[5].endWork == timeWork[6].endWork {
                
                if let startWork = timeWork[5].startWork,
                    let endWork = timeWork[5].endWork {
                    
                    workTimeLabel.text! += "Выходные: \(startWork)-\(endWork)"
                }
            } else {
                var text = ""
                if let startWork = timeWork[5].startWork,
                    let endWork = timeWork[5].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text += "СБ: \(startWork), "
                    } else {
                        text += "СБ: \(startWork)-\(endWork), "
                    }
                }
                
                if let startWork = timeWork[6].startWork,
                    let endWork = timeWork[6].endWork {
                    
                    if startWork == "Круглосуточно" ||
                        startWork == "Выходной" {
                        text += "ВС: \(startWork), "
                    } else {
                        text += "ВС: \(startWork)-\(endWork)"
                    }
                }
                 
                workTimeLabel.text! += text
            }

        }
    }
    
}
