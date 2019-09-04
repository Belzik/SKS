//
//  StockTableViewHeader.swift
//  SKS
//
//  Created by Александр Катрыч on 17/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class StockTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var periodView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        let description = NSMutableAttributedString(string: "Получите 6-й кофе с собой в подарок в период с 17.10 – 18.11.2018")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        description.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description.length))
        descriptionLabel.attributedText = description
        
        let condition = NSMutableAttributedString(string: """
        1. Купи любой кофе с собой;
        2. Получи специальную карточку участника;
        3. Кассир поставит фирменную отметку в специальную ячейку;
        4. Соберите 5 отметок;
        5. Получите 6-й кофе КАПУЧИНО 180 мл или АМЕРИКАНО 150 мл с собой в подарок.
        """)
        
        condition.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, condition.length))
        //conditionLabel.attributedText = condition
        
        categoryView.layer.cornerRadius = 5
        periodView.layer.cornerRadius = 5
    }
}
