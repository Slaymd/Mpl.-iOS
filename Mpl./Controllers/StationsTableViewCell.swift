//
//  StationsTableViewCell.swift
//  Mpl.
//
//  Created by Darius Martin on 30/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class StationsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: MarqueeLabel!
    @IBOutlet weak var logosPanel: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
