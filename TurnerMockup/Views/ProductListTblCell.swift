//
//  ProductListTblCell.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/21/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ProductListTblCell: UITableViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clear
        
        viewContainer.layer.cornerRadius = 30
        viewContainer.layer.masksToBounds = true
        viewContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.55)
        
        imgContainer.layer.cornerRadius = 16
        imgContainer.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
