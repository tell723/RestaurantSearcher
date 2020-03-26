//
//  TableViewController.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/14.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class TableViewController: UITableViewController {
    
    
    var restaurans: [Restaurant] = [] {
        didSet {
            tableView.reloadData()
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: "TableCell", bundle: nil), forCellReuseIdentifier: "customCell")
        tableView.rowHeight = 200
        getRests(url: url)
    }

    // MARK: - Table view data source
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell

        // Configure the cell...
        let restauran = restaurans[indexPath.row]
        cell.nameLabel.text = restauran.name
//        cell.stationLabel.text = restauran.station
//        cell.lineLabel.text = restauran.line
//        cell.exitLabel.text = restauran.stationExit
        cell.restImageView.image = restauran.image

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.totalRestsCount >= 20 && indexPath.row == ( self.restaurans.count - 10 ) {
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
        print(url)
        Alamofire.request(url).responseJSON { response in
            
            if let jsonObject = response.result.value {
                
                let json = JSON(jsonObject)
                let rests = json["rest"]
                self.totalRestsCount = json["total_hit_count"].intValue
//                print("total: \(self.totalRestsCount)")
//                print("page: \(self.totalPage)")
                print("current page: \(self.currentPage)")
                
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
                    
//                    print(restaurant.address)
                    print(restaurant.name)
                }
                self.currentPage += 1
                print()
            }
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
