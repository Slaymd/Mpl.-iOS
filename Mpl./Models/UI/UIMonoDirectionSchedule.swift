//
//  UIMonoDirectionSchedule.swift
//  Mpl.
//
//  Created by Darius Martin on 25/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class UIMonoDirectionSchedule: UIView {
    
    var waitingTime: Int
    
    var nearPanel: UIView?
    var nearImage: UIImageView?
    var nearLabel: UILabel?
    
    var waitingTimeLabel: UILabel?
    
    init(frame: CGRect, waitingTime: Int) {
        self.waitingTime = waitingTime
        super.init(frame: frame)
        
        //NEAR: round panel
        self.nearPanel = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        self.nearPanel!.layer.cornerRadius = 15
        self.nearPanel!.backgroundColor = .white
        self.addSubview(nearPanel!)
        
        //NEAR: icon
        self.nearImage = UIImageView(frame: CGRect(x: 5, y: 6, width: 14, height: 14))
        self.nearImage!.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
        self.nearImage!.animationDuration = 1.2
        self.nearImage!.startAnimating()
        self.nearPanel!.addSubview(nearImage!)
        
        //NEAR: label
        self.nearLabel = UILabel(frame: CGRect(x: 22, y: -1, width: self.nearPanel!.frame.width-15, height: 25))
        self.nearLabel!.text = NSLocalizedString("near", comment: "")
        self.nearLabel!.textColor = UIColor(red: 120.0/255, green: 169.0/255, blue: 66.0/255, alpha: 1.0)
        self.nearLabel!.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(15))
        self.nearPanel!.addSubview(nearLabel!)
        
        //NORMAL TIME: label
        self.waitingTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 25))
        self.waitingTimeLabel!.text = "\(self.waitingTime) " + NSLocalizedString("mins", comment: "")
        self.waitingTimeLabel!.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
        self.waitingTimeLabel!.textColor = .darkGray
        self.addSubview(self.waitingTimeLabel!)
        
        self.update(withWaitingTime: waitingTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.waitingTime = 42
        super.init(coder: aDecoder)
    }
    
    //MARK: - DISP CHANGES
    
    public func hideAll() {
        self.waitingTimeLabel!.isHidden = true
        self.nearLabel!.isHidden = true
        self.nearImage!.isHidden = true
        self.nearPanel!.isHidden = true
    }
    
    public func update(withWaitingTime waitingTime: Int) {
        self.waitingTime = waitingTime
        
        self.hideAll()
        
        if waitingTime < 2 {
            //Near
            self.nearLabel!.isHidden = false
            self.nearImage!.isHidden = false
            self.nearPanel!.isHidden = false
        } else {
            //Normal wait
            self.waitingTimeLabel!.text = "\(self.waitingTime) " + NSLocalizedString("mins", comment: "")
            self.waitingTimeLabel!.isHidden = false
        }
    }

}
