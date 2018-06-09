//
//  UISNCFSchedule.swift
//  Mpl.
//
//  Created by Darius Martin on 09/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class UISNCFSchedule: UIView {
    
    var schedule: SNCFSchedule
    
    var delayedView: UIView?
    var departureLabel: UILabel?
    var baseDepartureLabel: UILabel?
    var destinationLabel: MarqueeLabel?
    var trainLabel: UILabel?
    
    init(frame: CGRect, schedule: SNCFSchedule) {
        self.schedule = schedule
        super.init(frame: frame)
        
        if schedule.status == .DELAYED { //DELAYED
            //panel
            delayedView = UIView(frame: CGRect(x: 8, y: 0, width: 60, height: frame.height))
            delayedView!.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 0.8)
            delayedView!.layer.cornerRadius = 8
            self.addSubview(delayedView!)
            //real departure label
            self.departureLabel = UILabel(frame: CGRect(x: 0, y: (frame.height / 2 - 20 / 2) - 4, width: delayedView!.frame.width, height: 20))
            self.departureLabel!.font = UIFont(name: "Ubuntu-Medium", size: 18)
            self.departureLabel!.textColor = .white
            self.departureLabel!.textAlignment = .center
            self.departureLabel!.text = schedule.departure.formatted
            delayedView!.addSubview(departureLabel!)
            //old departure label
            self.baseDepartureLabel = UILabel(frame: CGRect(x: 0, y: self.departureLabel!.frame.maxY, width: delayedView!.frame.width, height: 12))
            self.baseDepartureLabel!.font = UIFont(name: "Ubuntu-Medium", size: 12)
            self.baseDepartureLabel!.textColor = UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1.0)
            let attributedString = NSMutableAttributedString(string: schedule.baseDeparture.formatted)
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            self.baseDepartureLabel!.attributedText = attributedString
            self.baseDepartureLabel!.textAlignment = .center
            delayedView!.addSubview(baseDepartureLabel!)
        } else if schedule.status == .ON_TIME { //ON TIME
            //real departure label
            self.departureLabel = UILabel(frame: CGRect(x: 8, y: frame.height / 2 - 20 / 2, width: 60, height: 20))
            self.departureLabel!.font = UIFont(name: "Ubuntu-Medium", size: 18)
            self.departureLabel!.textColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
            self.departureLabel!.text = schedule.departure.formatted
            self.departureLabel!.textAlignment = .center
            self.addSubview(departureLabel!)
        }
        
        //Train informations
        self.destinationLabel = MarqueeLabel(frame: CGRect(x: 80, y: -2, width: frame.width-8-80, height: 28), duration: 8.0, fadeLength: 5.0)
        self.destinationLabel!.text = schedule.destination
        self.destinationLabel!.textColor = .black
        self.destinationLabel!.font = UIFont(name: "Ubuntu-Bold", size: 24)
        self.addSubview(self.destinationLabel!)
        self.trainLabel = UILabel(frame: CGRect(x: 80, y: self.destinationLabel!.frame.maxY-4, width: frame.width-8-80, height: 18))
        self.trainLabel!.text = schedule.trainType + " " + schedule.trainNumber
        self.trainLabel!.textColor = .darkGray
        self.trainLabel!.font = UIFont(name: "Ubuntu-Medium", size: 14)
        self.addSubview(self.trainLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
