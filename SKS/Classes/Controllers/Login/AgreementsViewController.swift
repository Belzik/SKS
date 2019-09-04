//
//  AgreementsViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 29/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import WebKit

class AgreementsViewController: BaseViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "http://sksbonus.ru/privacy") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
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
