//
//  HomeStationCellCollectionViewCell.swift
//  Mpl.
//
//  Created by Darius Martin on 02/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class HomeStationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var stationName: MarqueeLabel!
    
    @IBOutlet weak var nearIcon1: UIImageView!
    @IBOutlet weak var nearIcon2: UIImageView!
    @IBOutlet weak var procheLabel1: UILabel!
    @IBOutlet weak var procheLabel2: UILabel!
    @IBOutlet weak var timeLabel1: UILabel!
    @IBOutlet weak var timeLabel2: UILabel!
    @IBOutlet weak var destinationLabel1: MarqueeLabel!
    @IBOutlet weak var destinationLabel2: MarqueeLabel!
    @IBOutlet weak var otherLabel: UILabel!
    
    var plusLabel: UILabel!
    var linesLogos = [UILineLogo]()
    
    var station: StopZone? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.card.layer.backgroundColor = UIColor.white.cgColor

        self.stationName.text = "#?"
        self.stationName.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))

        self.plusLabel = UILabel(frame: CGRect(x: 0, y: 28*2, width: 40, height: 16))
        self.plusLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(14))
        self.plusLabel.textAlignment = .center
        self.plusLabel.textColor = UIColor(red: 178/255, green: 190/255, blue: 195/255, alpha: 1)
        self.card.addSubview(self.plusLabel)
        
        nearIcon1.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
        nearIcon1.animationDuration = 1.2
        nearIcon2.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
        nearIcon2.animationDuration = 1.2
    }
    
    // UI INITIALIZATION FUNCTIONS
    
    func fill(_ station: StopZone) {
        if self.station != nil && self.station!.id == station.id { return }
        //Saving station object
        self.station = station
        //Station name
        self.stationName.text = station.name.uppercased()
        //Station lines logos
        for logo in self.linesLogos {
            logo.label.removeFromSuperview()
            logo.panel.removeFromSuperview()
        }
        dispAvailableLines(station)
    }
    
    func dispAvailableLines(_ station: StopZone) {
        let lines = station.getLines().sorted(by: {$0.displayId < $1.displayId})
        self.plusLabel.isHidden = true
        for i in 0..<lines.count {
            if i == 2 {
                self.plusLabel.isHidden = false
                self.plusLabel.text = "+\(lines.count-2)"
                break
            }
            let lineLogo = UILineLogo(lineShortName: lines[i].shortName, bgColor: lines[i].bgColor, fontColor: lines[i].ftColor, type: lines[i].type, at: CGPoint(x: 0, y: 28*i))
            self.linesLogos.append(lineLogo)
            self.addSubview(lineLogo.panel)
            if linesLogos.count == 1 {
                self.roundCorners([.bottomRight, .topRight, .bottomLeft], radius: 15)
                self.card.layer.cornerRadius = 15
            }
        }
    }
    
    // UI UPDATES
    
    func updateDisplayedArrivals() {
        if (self.station == nil) { return }
        var nbArrivals = self.station!.timetable.schedules.count
        
        hideAllScheduleElements()
        if nbArrivals > 0 {
            otherLabel.isHidden = true
            nbArrivals = nbArrivals > 2 ? 2 : nbArrivals
            for i in 0..<nbArrivals {
                let schedule = self.station!.timetable.schedules[i]
                displaySchedule(displayId: i, schedule: schedule)
            }
        } else {
            otherLabel.isHidden = false
            if self.station!.timetable.state == 1 {
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
    
    func displaySchedule(displayId: Int, schedule: (date: DayDate, lineId: Int, dest: Stop)) {
        let nearIcon = displayId == 0 ? nearIcon1 : nearIcon2
        let procheLabel = displayId == 0 ? procheLabel1 : procheLabel2
        let timeLabel = displayId == 0 ? timeLabel1 : timeLabel2
        let destinationLabel = displayId == 0 ? destinationLabel1 : destinationLabel2
        
        destinationLabel!.isHidden = false
        if schedule.date.getSecondsFromNow() < 60 {
            nearIcon!.isHidden = false
            nearIcon!.startAnimating()
            procheLabel!.isHidden = false
            //timeLabel!.isHidden = true
            destinationLabel!.textColor = UIColor.darkGray
            destinationLabel!.text = schedule.dest.directionName.uppercased()
        } else if schedule.date.getMinsFromNow() < 180 {
            //nearIcon!.isHidden = true
            //procheLabel!.isHidden = true
            timeLabel!.isHidden = false
            timeLabel!.text = schedule.date.getMinsFromNow() < 60 ?  "\(schedule.date.getMinsFromNow()) mins" : "+1 heure"
            destinationLabel!.textColor = UIColor.lightGray
            destinationLabel!.text = schedule.dest.directionName.uppercased()
        }
    }

}
