//
//  HomeViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 21/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: Int = -1
    var sections: [String] = ["", "Акции", "Партнеры"]
    let sectionsFiltered: [String] = ["", "Акции", "Партнеры"]
    var categories: [CategoryHome] = [CategoryHome(title: "Кафе",
                                                   image: UIImage(named: "ic_coffee")!,
                                                   color: UIColor(hexString: "#FFBA68")),
                                      CategoryHome(title: "Досуг",
                                                   image: UIImage(named: "ic_smile")!,
                                                   color: UIColor(hexString: "#D083FF")),
                                      CategoryHome(title: "Печать",
                                                   image: UIImage(named: "ic_layers")!,
                                                   color: UIColor(hexString: "#8C91BB")),
        CategoryHome(title: "Кафе",
                     image: UIImage(named: "ic_coffee")!,
                     color: UIColor(hexString: "#FFBA68")),
        CategoryHome(title: "Досуг",
                     image: UIImage(named: "ic_smile")!,
                     color: UIColor(hexString: "#D083FF")),
        CategoryHome(title: "Печать",
                     image: UIImage(named: "ic_layers")!,
                     color: UIColor(hexString: "#8C91BB"))]
    
    var stocks: [StockHome] = [StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019")]
    
    var partners: [PartnerHome] = [PartnerHome(title: "Типография Блокнот",
                                               description: "Быстрая печать качественной полиграфии с продуманным дизайном",
                                               image: UIImage(named: "example_typography")!,
                                               discount: "10 %",
                                               category: "Печать",
                                               isStock: false),
                                   PartnerHome(title: "Антикафе Downtown",
                                               description: "Антикафе Good Time - это уютное место в центре г.Ростов-на-дону, где можно вкусно поесть",
                                               image: UIImage(named: "example_cofe")!,
                                               discount: "10 %",
                                               category: "Кафе",
                                               isStock: true),
                                   PartnerHome(title: "If you want",
                                               description: "Скидки 5% на все дневные рационы питания",
                                               image: UIImage(named: "example_want")!,
                                               discount: "5 %",
                                               category: "Досуг",
                                               isStock: false)]

    let categoriesFilter: [CategoryHome] = [CategoryHome(title: "Кафе",
                                                   image: UIImage(named: "ic_coffee")!,
                                                   color: UIColor(hexString: "#FFBA68")),
                                      CategoryHome(title: "Досуг",
                                                   image: UIImage(named: "ic_smile")!,
                                                   color: UIColor(hexString: "#D083FF")),
                                      CategoryHome(title: "Печать",
                                                   image: UIImage(named: "ic_layers")!,
                                                   color: UIColor(hexString: "#8C91BB")),
                                      CategoryHome(title: "Кафе",
                                                   image: UIImage(named: "ic_coffee")!,
                                                   color: UIColor(hexString: "#FFBA68")),
                                      CategoryHome(title: "Досуг",
                                                   image: UIImage(named: "ic_smile")!,
                                                   color: UIColor(hexString: "#D083FF")),
                                      CategoryHome(title: "Печать",
                                                   image: UIImage(named: "ic_layers")!,
                                                   color: UIColor(hexString: "#8C91BB"))]
    
    let stocksFilter: [StockHome] = [StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019"),
                               StockHome(title: "Кофе в подарок",
                                         description: "Каждый третий кофе в подарок при предъявление штрих кода",
                                         period: "с 17.10 - 18.11.2019")]
    
    let partnersFilter: [PartnerHome] = [PartnerHome(title: "Типография Блокнот",
                                               description: "Быстрая печать качественной полиграфии с продуманным дизайном",
                                               image: UIImage(named: "example_typography")!,
                                               discount: "10 %",
                                               category: "Печать",
                                               isStock: false),
                                   PartnerHome(title: "Антикафе Downtown",
                                               description: "Антикафе Good Time - это уютное место в центре г.Ростов-на-дону, где можно вкусно поесть",
                                               image: UIImage(named: "example_cofe")!,
                                               discount: "10 %",
                                               category: "Кафе",
                                               isStock: true),
                                   PartnerHome(title: "If you want",
                                               description: "Скидки 5% на все дневные рационы питания",
                                               image: UIImage(named: "example_want")!,
                                               discount: "5 %",
                                               category: "Досуг",
                                               isStock: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UINib(nibName: "\(PartnerTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(PartnerTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(CategoryTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(CategoryTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(StockTableViewCell.self)",
            bundle: nil),
                           forCellReuseIdentifier: "\(StockTableViewCell.self)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 {
            if stocks.count == 0 {
                return partners.count
            } else {
                return 1
            }
        }
        return partners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(CategoryTableViewCell.self)",
                                                     for: indexPath) as! CategoryTableViewCell
            
            cell.setCollectionViewDataSourceDelegate(self)
            cell.collectionView.tag = 1
            
            return cell
        } else if indexPath.section == 1 && stocks.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(StockTableViewCell.self)",
                for: indexPath) as! StockTableViewCell
            
            cell.setCollectionViewDataSourceDelegate(self)
            cell.collectionView.tag = 2
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(PartnerTableViewCell.self)",
                for: indexPath) as! PartnerTableViewCell
            
            cell.model = partners[indexPath.row]
            
            return cell
        }

    }
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CategoryCollectionViewCell.self)",
                for: indexPath) as! CategoryCollectionViewCell
            
            cell.model = categories[indexPath.row]
            
            return cell
        }

        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(StockCollectionViewCell.self)",
                for: indexPath) as! StockCollectionViewCell
            
            cell.model = stocks[indexPath.row]
            
            return cell
        }
        print(collectionView.tag)
        let cell = UICollectionViewCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 2 {
            return CGSize(width: view.bounds.width - 32, height: 124)
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex == -1 {
                categories[indexPath.row].isSelect = true
                selectedIndex = indexPath.row
                collectionView.reloadItems(at: [indexPath])
                filtered()
            
        } else if selectedIndex == indexPath.row {
            categories[indexPath.row].isSelect = false
            selectedIndex = -1
            collectionView.reloadItems(at: [indexPath])
            filtered()
        } else {
            categories[selectedIndex].isSelect = false
            categories[indexPath.row].isSelect = true
            collectionView.reloadItems(at: [IndexPath(row: selectedIndex, section: 0), indexPath])
            selectedIndex = indexPath.row
            filtered()
        }
    }
    
    
    func filtered() {
        if selectedIndex == -1 {
            categories = categoriesFilter
            stocks = stocksFilter
            partners = partnersFilter
            sections = sectionsFiltered
        } else {
            let category = categories[selectedIndex]
            
            sections = ["", "Партнеры"]
            stocks = []
            let partnersFilt = partnersFilter.filter { (partner) -> Bool in
                return partner.category == category.title
            }
            
            partners = partnersFilt
        }
        tableView.reloadData()
    }
}
