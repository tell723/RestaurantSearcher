//
//  WebPageViewController.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/20.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import WebKit

class WebPageViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("url: \(urlString)")
        if let url = URL(string: urlString) {
            self.webView.load(URLRequest(url: url))
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
