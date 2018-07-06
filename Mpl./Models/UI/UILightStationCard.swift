//
//  UILightStationCard.swift
//  Mpl.
//
//  Created by Darius Martin on 16/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel
import CoreLocation

class UILightStationCard: UIView {
    
    var station: StopZone
    var distance: Double
    
    var logos: [UILineIcon] = []
    var label: MarqueeLabel?
    
    var distanceIcon: UIImageView?
    var distanceLabel: UILabel?
    
    var nearIcon1: UIImageView!
    var nearIcon2: UIImageView!
    var procheLabel1: UILabel!
    var procheLabel2: UILabel!
    var timeLabel1: UILabel!
    var timeLabel2: UILabel!
    var destinationLabel1: MarqueeLabel!
    var destinationLabel2: MarqueeLabel!
    var otherLabel: UILabel!
    
    init(frame: CGRect, station: StopZone, distance: Double) {
        self.station = station
        self.distance = distance
        super.init(frame: frame)
        
        self.layer.cornerRadius = 15
        self.backgroundColor = .white
        
        //Line logos
        var x = Int(self.frame.maxX)-15
        let lines = station.getLines().sorted(by: {$0.displayId < $1.displayId})
        for i in 0..<lines.count {
            if (x-50 < Int(self.frame.width)/2) { break }
            x -= 50
            let logo = UILineIcon(lines[i], at: CGPoint(x: x, y: (Int(self.frame.height)-28)/2))
            self.logos.append(logo)
            self.addSubview(logo)
        }
        
        //Station name
        self.label = MarqueeLabel.init(frame: CGRect.init(x: 15, y: 0, width: x-30, height: Int(self.frame.height)), duration: 6.0, fadeLength: 6.9)
        self.label!.text = station.name
        self.label!.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(18))
        self.addSubview(self.label!)
        
        //If station is near
        if (distance <= 200) {
            let y = Int(frame.height)
            self.frame.size = CGSize(width: self.frame.width, height: self.frame.height*2)
            self.distanceIcon = UIImageView.init(frame: CGRect.init(x: 15, y: ((Int(self.frame.height)-y)/2)+y-15, width: 15, height: 15))
            self.distanceIcon!.image = #imageLiteral(resourceName: "navigation")
            self.distanceLabel = UILabel.init(frame: CGRect.init(x: 35, y: ((Int(self.frame.height)-y)/2)+y-15, width: 70, height: 15))
            self.distanceLabel!.text = "\(Int(distance)) m"
            self.distanceLabel!.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
            self.distanceLabel!.textColor = UIColor.init(hex: "3498db")
            self.addSubview(distanceIcon!)
            self.addSubview(distanceLabel!)
            
            //Times inits
            let secondX = (Int(self.frame.width)-105)/2+105
            let maxLen = secondX-105
            self.nearIcon1 = UIImageView.init(frame: CGRect.init(x: 105, y: 57, width: 10, height: 10))
            self.nearIcon1.image = #imageLiteral(resourceName: "near")
            self.nearIcon1.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
            self.nearIcon1.animationDuration = 1.2
            self.addSubview(nearIcon1!)
            self.nearIcon2 = UIImageView.init(frame: CGRect.init(x: secondX, y: 57, width: 10, height: 10))
            self.nearIcon2.image = #imageLiteral(resourceName: "near")
            self.nearIcon2.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
            self.nearIcon2.animationDuration = 1.2
            self.addSubview(nearIcon2!)
            
            self.procheLabel1 = UILabel.init(frame: CGRect.init(x: 105+11, y: 52, width: maxLen-11, height: 15))
            self.procheLabel1.textColor = UIColor(red: 120.0/255, green: 169.0/255, blue: 66.0/255, alpha: 1.0)
            self.procheLabel1.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(14))
            self.procheLabel1.text = NSLocalizedString("near", comment: "")
            self.addSubview(procheLabel1!)
            self.procheLabel2 = UILabel.init(frame: CGRect.init(x: secondX+11, y: 52, width: maxLen-11, height: 15))
            self.procheLabel2.textColor = UIColor(red: 120.0/255, green: 169.0/255, blue: 66.0/255, alpha: 1.0)
            self.procheLabel2.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(14))
            self.procheLabel2.text = NSLocalizedString("near", comment: "")
            self.addSubview(procheLabel2!)
            
            self.timeLabel1 = UILabel.init(frame: CGRect.init(x: 105, y: 52, width: maxLen, height: 15))
            self.timeLabel1.textColor = .darkGray
            self.timeLabel1.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(14))
            self.timeLabel1.text = "2 mins"
            self.addSubview(timeLabel1)
            self.timeLabel2 = UILabel.init(frame: CGRect.init(x: secondX, y: 52, width: maxLen, height: 15))
            self.timeLabel2.textColor = .darkGray
            self.timeLabel2.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(14))
            self.timeLabel2.text = "2 mins"
            self.addSubview(timeLabel2)
            
            self.destinationLabel1 = MarqueeLabel(frame: CGRect.init(x: 105, y: 65, width: maxLen-5, height: 16), duration: 6.0, fadeLength: 6.0)
            self.destinationLabel1.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(15))
            self.destinationLabel1.text = "DESTINATION"
            self.addSubview(destinationLabel1)
            self.destinationLabel2 = MarqueeLabel(frame: CGRect.init(x: secondX, y: 65, width: maxLen-5, height: 16), duration: 6.0, fadeLength: 6.0)
            self.destinationLabel2.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(15))
            self.destinationLabel2.text = "DESTINATION"
            self.addSubview(destinationLabel2)
            
            self.otherLabel = UILabel(frame: CGRect.init(x: 105, y: 57, width: maxLen*2, height: 21))
            self.otherLabel.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(17))
            self.addSubview(otherLabel)
            
            self.hideAllScheduleElements()
            //Updating station
            station.updateTimetable(completion: { (result: Bool) in
                if result == true {
                    self.updateDisplayedArrivals()
                } else {
                    if (self.station.schedules.count > 0) {
                        self.updateDisplayedArrivals()
                    }
                }
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI UPDATES
    
    func updateDisplayedArrivals() {
        var nbArrivals = self.station.schedules.count
        
        hideAllScheduleElements()
        if nbArrivals > 0 {
            otherLabel.isHidden = true
            nbArrivals = nbArrivals > 2 ? 2 : nbArrivals
            for i in 0..<nbArrivals {
                let schedule = self.station.schedules[i]
                displaySchedule(displayId: i, schedule: schedule)
            }
        } else {
            otherLabel.isHidden = false
            print(self.station.updateState)
            if self.station.updateState == 1 {
                otherLabel.text = "..."
            } else {
                otherLabel.text = "Service terminé."
            }
        }
    }
    
    func hideAllScheduleElements() {
        nearIcon1.isHidden = true
        nearIcon2.isHidden = true
        procheLabel1.isHidden = true
        procheLabel2.isHidden = true
        destinationLabel1.isHidden = true
        destinationLabel2.isHidden = true
        timeLabel1.isHidden = true
        timeLabel2.isHidden = true
        otherLabel.isHidden = true
    }
    
    func displaySchedule(displayId: Int, schedule: Schedule) {
        let nearIcon = displayId == 0 ? nearIcon1 : nearIcon2
        let procheLabel = displayId == 0 ? procheLabel1 : procheLabel2
        let timeLabel = displayId == 0 ? timeLabel1 : timeLabel2
        let destinationLabel = displayId == 0 ? destinationLabel1 : destinationLabel2
        
        destinationLabel!.isHidden = false
        if schedule.waitingTime < 2 {
            nearIcon!.isHidden = false
            nearIcon!.startAnimating()
            procheLabel!.isHidden = false
            destinationLabel!.textColor = UIColor.darkGray
            destinationLabel!.text = schedule.destination.directionName.uppercased()
        } else if schedule.waitingTime < 180 {
            timeLabel!.isHidden = false
            timeLabel!.text = schedule.waitingTime < 60 ?  "\(schedule.waitingTime) mins" : "+1 heure"
            destinationLabel!.textColor = UIColor.lightGray
            destinationLabel!.text = schedule.destination.directionName.uppercased()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
