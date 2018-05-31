//
//  UILineCard.swift
//  Mpl.
//
//  Created by Darius Martin on 15/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class UILineCard: UIView {
    
    var line: Line?
    var logo: UILineLogo?
    var destinationsLabels: [UILabel] = []
    var animState: Int = 0
    
    init(frame: CGRect, line: Line) {
        self.line = line
        super.init(frame: frame)
        
        //Graphic init
        self.layer.cornerRadius = 11
        self.backgroundColor = line.bgColor
        
        //Line Logo
        let logo = UILineLogo(lineShortName: line.shortName, bgColor: .white, fontColor: line.bgColor, type: line.type, at: CGPoint(x: 10, y: 10))
        self.logo = logo
        self.addSubview(logo.panel)
        
        //Destination
        let sortedDests = line.directions.sorted(by: {$0.count < $1.count})
        let dirLabelStartY = 65;
        let dirLabelHeight = ((Int(self.frame.height)-10)-dirLabelStartY)/4;
        for i in 0..<line.directions.count {
            if i >= 4 { break }

            let dirLabel = MarqueeLabel(frame: CGRect(x: 5, y: (dirLabelStartY+(dirLabelHeight*3))-(dirLabelHeight*i), width: Int(self.frame.width)-10, height: dirLabelHeight), duration: 6, fadeLength: 5.0)
            dirLabel.text = sortedDests[i].uppercased()
            dirLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
            dirLabel.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.8)
            self.addSubview(dirLabel)
            self.destinationsLabels.append(dirLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
