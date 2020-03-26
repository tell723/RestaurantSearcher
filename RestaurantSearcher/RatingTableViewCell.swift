//
//  RatingTableViewCell.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/22.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewerLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var scoerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
