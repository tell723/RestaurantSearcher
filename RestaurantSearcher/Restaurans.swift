//
//  Restaurans.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/14.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Restaurant {
    
    
    
    var id: String
    var name: String
    var kana: String
    var category: String
    var address: String
    var latitude: Double
    var longitude: Double
    var tel: String
    var opentime: String
    var holiday: String
    var line: String
    var station: String
    var stationExit: String
    var walk: String
    var imageUrl: String
    var parking: String
    var creditCard: String
    var mobileUrl: String
    var pr: String
    
    var image: UIImage = UIImage(named: "no_image2")!
    
    
    
    init(subJson: JSON) {
        
        self.id = subJson["id"].stringValue
        self.name = subJson["name"].stringValue
        self.kana = subJson["name_kana"].stringValue
        self.category = subJson["code"]["category_name_l"][0].stringValue
        self.address = subJson["address"].stringValue
        self.latitude = subJson["latitude"].doubleValue
        self.longitude = subJson["longitude"].doubleValue
        self.tel = subJson["tel"].stringValue
        self.opentime = subJson["opentime"].stringValue
        self.holiday = subJson["holiday"].stringValue
        self.line = subJson["access"]["line"].stringValue
        self.station = subJson["access"]["station"].stringValue
        self.stationExit = subJson["access"]["station_exit"].stringValue
        self.walk = subJson["access"]["walk"].stringValue
        self.imageUrl = subJson["image_url"]["shop_image1"].stringValue
        self.parking = subJson["parking_lots"].stringValue
        self.creditCard = subJson["credit_card"].stringValue
        self.mobileUrl = subJson["url_mobile"].stringValue
        self.pr = subJson["pr"]["pr_long"].stringValue
    }
}
