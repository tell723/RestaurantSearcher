//
//  TableViewCell.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/15.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var restImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var accessLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
