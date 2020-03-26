//
//  Rating.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/22.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import Foundation
import SwiftyJSON

class Rating {
    
    var nickname: String
    var score: String
    var comment: String
    var updateDate: String
    
    var imageUrl: String
    var image: UIImage = UIImage(named: "no_image2")!
    
    
    init(subJson: JSON) {
        
        self.nickname = subJson["photo"]["nickname"].stringValue
        self.score = subJson["photo"]["total_score"].stringValue
        self.comment = subJson["photo"]["comment"].stringValue
        self.imageUrl = subJson["photo"]["image_url"]["url_1024"].stringValue
        
        
        let updateDate = subJson["photo"]["update_date"].stringValue
        
        if updateDate != "" {
            let array = updateDate.components(separatedBy: "+")
            let array2 = array[0].components(separatedBy: "T")
            let updateDateString: String = array2[0] + " " + array2[1]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dt: Date = formatter.date(from: updateDateString)!
            let format = DateFormatter()
            format.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            self.updateDate = format.string(from: dt)
        } else {
            self.updateDate = "投稿日時不明"
        }
        //2013-07-05T16:49:50+09:00
    }
}
