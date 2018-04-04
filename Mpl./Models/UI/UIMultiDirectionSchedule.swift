//
//  UIMultiDirectionSchedule.swift
//  Mpl.
//
//  Created by Darius Martin on 04/04/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import MarqueeLabel
import UIKit

class UIMultiDirectionSchedule: UIView {

    var schedule: Schedule?
    
    var nearIcon: UIImageView?
    var nearLabel: UILabel?
    var timeLabel: UILabel?
    var destinationLabel: MarqueeLabel?
    
    //MARK: - INIT
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let maxLen = frame.width
        
        //Near icon
        self.nearIcon = UIImageView.init(frame: CGRect.init(x: 0, y: 5, width: 10, height: 10))
        self.nearIcon!.image = #imageLiteral(resourceName: "near")
        self.nearIcon!.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
        self.nearIcon!.animationDuration = 1.2
        self.addSubview(nearIcon!)
        
        //Near label
        self.nearLabel = UILabel.init(frame: CGRect.init(x: 11, y: 0, width: maxLen-11, height: 15))
        self.nearLabel!.textColor = UIColor(red: 120.0/255, green: 169.0/255, blue: 66.0/255, alpha: 1.0)
        self.nearLabel!.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(14))
        self.nearLabel!.text = NSLocalizedString("near", comment: "")
        self.addSubview(nearLabel!)
        
        //Waiting time label
        self.timeLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: maxLen, height: 15))
        self.timeLabel!.textColor = .darkGray
        self.timeLabel!.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(14))
        self.timeLabel!.text = "2 mins"
        self.addSubview(timeLabel!)
        
        //Destination label
        self.destinationLabel = MarqueeLabel(frame: CGRect.init(x: 0, y: 13, width: maxLen-5, height: 16), duration: 6.0, fadeLength: 6.0)
        self.destinationLabel!.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(15))
        self.destinationLabel!.text = "DESTINATION"
        self.addSubview(destinationLabel!)
        
        self.hideAll()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - DISP CHANGES
    
    public func hideAll() {
        self.nearIcon!.isHidden = true
        self.nearLabel!.isHidden = true
        self.timeLabel!.isHidden = true
        self.destinationLabel!.isHidden = true
    }
    
    public func update(with schedule: Schedule) {
        self.schedule = schedule
        
        self.hideAll()
        
        self.destinationLabel!.isHidden = false
        if schedule.waitingTime < 2 {
            nearIcon!.isHidden = false
            nearIcon!.startAnimating()
            nearLabel!.isHidden = false
            destinationLabel!.textColor = .darkGray
            destinationLabel!.text = schedule.destination.directionName.uppercased()
        } else if schedule.waitingTime < 180 {
            timeLabel!.isHidden = false
            timeLabel!.text = schedule.waitingTime < 60 ?  "\(schedule.waitingTime) \(NSLocalizedString("mins", comment: ""))" : NSLocalizedString("+1 hour", comment: "")
            destinationLabel!.textColor = UIColor.lightGray
            destinationLabel!.text = schedule.destination.directionName.uppercased()
        }
    }
    
}
