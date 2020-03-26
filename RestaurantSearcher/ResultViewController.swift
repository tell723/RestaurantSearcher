//
//  ResultViewController.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/17.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    
    @IBOutlet weak var restauransTableView: UITableView!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    
    var range = ""
    var freeWord = ""
    
    var restaurans: [Restaurant] = [] {
        didSet {
            activityIndicatorView.stopAnimating()
            restauransTableView.reloadData()
            totalCountLabel.text = "\(totalRestsCount) Restaurans Hit"
        }
    }
    var selectedRow = 0
    var url = ""
    var totalRestsCount = 0
    var currentPage = 1
    var totalPage: Int {
        get {
            let n: Int = totalRestsCount / 20
            if ( totalRestsCount % 20 ) == 0 {
                return n
            } else {
                return n + 1
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        totalCountLabel.text  = ""
        addjustTextLabel(textLabel: rangeLabel, textString: "現在位置から\(range)")
        
        
        self.restauransTableView.delegate = self
        self.restauransTableView.dataSource = self
        self.restauransTableView.register(UINib(nibName: "TableViewCell", bundle: nil),
                                     forCellReuseIdentifier: "customCell")
        self.restauransTableView.rowHeight = 100
        self.restauransTableView.layer.borderWidth = 0
        
        self.activityIndicatorView.hidesWhenStopped = true
        
        self.getRests(url: url)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = restauransTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        
        let restauran = restaurans[indexPath.row]
        
        cell.nameLabel.text = restauran.name
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.accessLabel.adjustsFontSizeToFitWidth = true
        cell.categoryNameLabel.text = restauran.category
        cell.restImageView.image = restauran.image
        cell.accessLabel.text = restauran.line + restauran.station + restauran.stationExit + " " + walkTime(restauran.walk)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
           self.selectedRow = indexPath.row
           tableView.deselectRow(at: indexPath, animated: true)
           performSegue(withIdentifier: "toDetailVC", sender: nil)
       }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.totalRestsCount > 20 && indexPath.row == ( self.restaurans.count - 10 ) && currentPage <= totalPage {
            
            getRests(url: self.url + "&offset_page=\(self.currentPage)")
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailVC" {
            
            let nextVC = segue.destination as! DetailViewController
            nextVC.restaurant = self.restaurans[selectedRow]
        }
    }
    
    
    
     func getRests(url: String) {
        
        activityIndicatorView.startAnimating()

            Alamofire.request(url).responseJSON { response in
                
                switch response.result {
                case .success:
                    print("success")
                    
                case .failure(let error):
                    print("error: \(error)")
                    self.showAlert(message: "ネットワークに接続されていません")
                }
                
                if let jsonObject = response.result.value {
                    
                    let json = JSON(jsonObject)
                    
                    if json["error"] == .null {
                        
                        let rests = json["rest"]
                        self.totalRestsCount = json["total_hit_count"].intValue
                        
                        for (key,subJson):(String, JSON) in rests {
                            
                            let restaurant = Restaurant(subJson: subJson)
                            
                            if let url = URL(string: restaurant.imageUrl) {
                                do {
                                    let data = try Data(contentsOf: url)
                                    restaurant.image = UIImage(data: data)!
                                } catch let err {
                                    print("Error : \(err.localizedDescription)")
                                }
                            }
                            self.restaurans.append(restaurant)
                        }
                        self.currentPage += 1
                        //                        print()
                    } else {
                        
                        print("error message: \(json["error"][0]["message"])")
                        self.showAlert(message: json["error"][0]["message"].stringValue)
                    }
                
                    
                }
            }
            
        }
    
    
    
    func walkTime(_ walk: String) -> String {
        
        if walk.contains("徒歩") {
            return walk + "分"
        } else {
            return "徒歩\(walk)分"
        }
    }
    
    
    
    func addjustTextLabel(textLabel: UILabel, textString: String) {
        
        textLabel.backgroundColor = UIColor.white
        textLabel.textColor = UIColor.orange
        textLabel.layer.cornerRadius = textLabel.frame.size.height / 2
        textLabel.clipsToBounds = true
        textLabel.text = textString
    }
    
    
    
    func showAlert(message: String) {
        
        let alert = UIAlertController(
            title: "エラー",
            message: message,
            preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil)
        
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
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
