//
//  DetailViewController.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/15.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import Alamofire
import SwiftyJSON

class DetailViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kanaLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var restImageView: UIImageView!
    @IBOutlet weak var webLinkButton: UIButton!
    @IBOutlet weak var segmentControlView: UISegmentedControl!
    @IBOutlet var restaurantInfoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ratingTableView: UITableView!
    @IBOutlet weak var prTextView: UITextView!
    
    
    var restaurant: Restaurant!
    
    let baseUrl = "https://api.gnavi.co.jp/PhotoSearchAPI/v3/"
    let apiKey = "7c26053265ff1eabac65817bfc40546d"
    
    var ratings: [Rating] = [] {
        didSet {
            ratingTableView.reloadData()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.adjustsFontSizeToFitWidth = true
        kanaLabel.adjustsFontSizeToFitWidth = true
        addressLabel.adjustsFontSizeToFitWidth = true
        openTimeLabel.adjustsFontSizeToFitWidth = true
        
        getRating(url: "\(baseUrl)?keyid=\(apiKey)&shop_id=\(restaurant.id)")

        
        setUpExtraView(extraView: ratingTableView)
        setUpExtraView(extraView: mapView)
        setUpExtraView(extraView: restaurantInfoView)
        
        
        webLinkButton.backgroundColor = UIColor.orange
        webLinkButton.layer.cornerRadius = webLinkButton.frame.size.height / 2
        webLinkButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        nameLabel.text = restaurant.name
        kanaLabel.text = restaurant.kana
        addressLabel.text = restaurant.address
        telLabel.text = "TEL \(restaurant.tel)"
        openTimeLabel.text = restaurant.opentime == "" ? "不明" : restaurant.opentime
        restImageView.image = restaurant.image
        
        
        ratingTableView.delegate = self
        ratingTableView.dataSource = self
        ratingTableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil),
                                    forCellReuseIdentifier: "orgRatingTableViewCell")
        ratingTableView.rowHeight = 250
        ratingTableView.allowsSelection = false
        
        prTextView.text = restaurant.pr
        prTextView.layer.cornerRadius = 10
        prTextView.isEditable = false
        prTextView.showsVerticalScrollIndicator = true
        
        
        if restaurant.latitude == 0.0 || restaurant.longitude == 0.0 {

            CLGeocoder().geocodeAddressString(restaurant.address) { placemarks, error in

                if let latitude = placemarks?.first?.location?.coordinate.latitude,
                    let longtude = placemarks?.first?.location?.coordinate.longitude {

                    self.lounchMap(latitude: latitude, longitude: longtude)
                }
            }
        } else {
            lounchMap(latitude: restaurant.latitude, longitude: restaurant.longitude)
        }
        
        
    }
    
    
    
    @IBAction func webPageButtonTapped(_ sender: Any) {
        
        guard let url = URL(string: restaurant.mobileUrl) else { return }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.view.bringSubviewToFront(restaurantInfoView)
        case 1:
            self.view.bringSubviewToFront(ratingTableView)
        case 2:
            self.view.bringSubviewToFront(mapView)
        default:
            self.view.bringSubviewToFront(restaurantInfoView)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ratingTableView.dequeueReusableCell(withIdentifier: "orgRatingTableViewCell", for: indexPath) as! RatingTableViewCell
        cell.commentTextView.frame = CGRect(
            x: 16,
            y: 106,
            width: ratingTableView.frame.width - 32,
            height: 125)
        cell.commentTextView.layer.cornerRadius = 10

        let rating = ratings[indexPath.row]
        cell.reviewerLabel.text = "投稿者：　\(rating.nickname)"
        cell.reviewerLabel.adjustsFontSizeToFitWidth = true
        cell.updateDateLabel.text = rating.updateDate
        cell.commentTextView.text = rating.comment
        cell.scoerLabel.text = rating.score
        cell.ratingImageView.image = rating.image
        cell.commentTextView.isEditable = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    
    
    func lounchMap(latitude: Double, longitude: Double) {
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude,
                                                                      longitude: longitude)
        self.mapView.setCenter(location, animated: true)
        var region: MKCoordinateRegion = self.mapView.region
        region.center = location
        region.span.latitudeDelta = 0.005
        region.span.longitudeDelta = 0.005
        
        self.mapView.setRegion(region,
                               animated: true)
        self.mapView.mapType = MKMapType.standard
        
        // Do any additional setup after loading the view.
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude,
                                                           longitude)
        self.mapView.addAnnotation(annotation)
    }
    
    
    
    func setUpExtraView(extraView: UIView) {
        
        extraView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height - 180 )

        self.view.addSubview(extraView)
    }
    
    
    
    func getRating(url: String) {
        
        Alamofire.request(url).responseJSON { response in
            
            if let jsonObject = response.result.value {
                
                let json = JSON(jsonObject)
                
                let totalHitCount = json["response"]["total_hit_count"].intValue

                print(totalHitCount)
                if totalHitCount != 0 {
                    
                    for i in 0...(totalHitCount - 1) {

                        let subJson = json["response"]["\(i)"]
                        let rating = Rating(subJson: subJson)

                        if let url = URL(string: rating.imageUrl) {
                            do {
                                let data = try Data(contentsOf: url)
                                rating.image = UIImage(data: data)!

                            } catch let err {
                                print("Error : \(err.localizedDescription)")
                            }
                        }
                        self.ratings.append(rating)
                    }
                }
                
            }
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
