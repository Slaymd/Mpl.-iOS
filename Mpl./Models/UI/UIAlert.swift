//
//  UIAlert.swift
//  Mpl.
//
//  Created by Darius Martin on 08/04/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import UIKit

enum AlertType {
    case info,disruption,pickpocket
}

class UIAlert : UIView {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
