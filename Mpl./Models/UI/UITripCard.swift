//
//  TripCardViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 23/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class UITripCard: UIView {
    
    var trip: Trip
    
    var timePanel: UIView?
    var timeLabel: UILabel?
    var subTimeLabel: UILabel?
    
    var departureLabel: UILabel?
    var departureTimeLabel: UILabel?
    var arrivalLabel: UILabel?
    var arrivalTimeLabel: UILabel?
    
    init(frame: CGRect, trip: Trip) {
        self.trip = trip
        super.init(frame: frame)
        
        //background settings
        self.layer.cornerRadius = 15
        self.backgroundColor = .white
        self.clipsToBounds = true
        
        //time panel
        self.timePanel = UIView(frame: CGRect(x: frame.width * 0.75, y: 0.0, width: frame.width * 0.25, height: frame.height))
        self.timePanel!.backgroundColor = UIColor(white: 235/255.0, alpha: 1.0)
        self.addSubview(timePanel!)
        
        //Time label
        self.timeLabel = UILabel(frame: CGRect(x: self.timePanel!.frame.width*0.1, y: 25, width: self.timePanel!.frame.width*0.7, height: 35))
        self.timeLabel!.text = String(trip.duration)
        self.timeLabel!.font = UIFont(name: "Ubuntu-Bold", size: 34)
        self.timeLabel!.adjustsFontSizeToFitWidth = true
        self.timeLabel!.textAlignment = .right
        self.timeLabel!.textColor = .black
        self.timePanel!.addSubview(timeLabel!)
        
        //SubTime label
        self.subTimeLabel = UILabel(frame: CGRect(x: self.timeLabel!.frame.width*0.1, y: self.timeLabel!.frame.maxY-2, width: self.timePanel!.frame.width*0.7, height: 18))
        self.subTimeLabel!.text = NSLocalizedString("mins", comment: "")
        self.subTimeLabel!.font = UIFont(name: "Ubuntu-Medium", size: 13)
        self.subTimeLabel!.textAlignment = .right
        self.subTimeLabel!.textColor = .darkGray
        self.timePanel!.addSubview(subTimeLabel!)
        
        //Itinerary overview
        var id = 0
        var x = CGFloat(10)
        let y = CGFloat(50)
        for segments in trip.segments {
            if segments.mode == .WALK && segments.duration! <= 3 { continue }
            if id > 0 {
                //separator point
                let sep = UILabel(frame: CGRect(x: x-11, y: y, width: 7, height: 28))
                sep.text = "•"
                sep.textColor = .lightGray
                sep.font = sep.font.withSize(12)
                sep.textAlignment = .center
                self.addSubview(sep)
                if x + 40 >= self.timePanel!.frame.minX {
                    sep.frame.size = CGSize(width: 22, height: 28)
                    sep.frame.origin = CGPoint(x: x-15, y: y)
                    sep.text = "•••"
                    sep.font = sep.font.withSize(10)
                    break
                }
            }
            if segments.mode == .TRAMWAY || segments.mode == .BUS {
                let lineIcon = UILineIcon(frame: CGRect(x: x, y: y, width: 35, height: 28), line: segments.line!)
                
                self.addSubview(lineIcon)
                x += 35 + 15.0
            } else if segments.mode == .WALK {
                let walkImg = UIImageView(frame: CGRect(x: x, y: y, width: 25, height: 28))
                walkImg.image = #imageLiteral(resourceName: "itineraries_walk_icon")
                self.addSubview(walkImg)
                let walkDuration = UILabel(frame: CGRect(x: x-1, y: walkImg.frame.maxY, width: 27, height: 13))
                walkDuration.text = String(segments.duration!) + " " + NSLocalizedString("mins", comment: "")
                walkDuration.textAlignment = .center
                walkDuration.font = UIFont(name: "Ubuntu-Medium", size: 13)
                walkDuration.adjustsFontSizeToFitWidth = true
                walkDuration.textColor = UIColor(white: 177/255.0, alpha: 1.0)
                self.addSubview(walkDuration)
                x += 25 + 15.0
            }
            id += 1
        }
        
        //Departure and arrival time
        self.departureLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 80, height: 15))
        self.departureLabel!.font = UIFont(name: "Ubuntu-Medium", size: 12)
        self.departureLabel!.text = NSLocalizedString("departure", comment: "")
        self.departureLabel!.textColor = .gray
        self.addSubview(self.departureLabel!)
        
        self.departureTimeLabel = UILabel(frame: CGRect(x: 10, y: self.departureLabel!.frame.maxY-3, width: 80, height: 20))
        self.departureTimeLabel!.font = UIFont(name: "Ubuntu-Medium", size: 14)
        if trip.departureTime.getMinsFromNow() > 1400 || trip.departureTime.getMinsFromNow() <= 1 {
            self.departureTimeLabel!.text = NSLocalizedString("now", comment: "")
        } else {
            self.departureTimeLabel!.text = NSLocalizedString("%Hh%M", comment: "").replacingOccurrences(of: "%H", with: "\(trip.departureTime.hours)").replacingOccurrences(of: "%M", with: trip.departureTime.mins < 10 ? "0\(trip.departureTime.mins)" : "\(trip.departureTime.mins)")
        }
        self.departureTimeLabel!.textColor = .black
        self.addSubview(self.departureTimeLabel!)
        
        self.arrivalLabel = UILabel(frame: CGRect(x: 90, y: 5, width: 80, height: 15))
        self.arrivalLabel!.font = UIFont(name: "Ubuntu-Medium", size: 12)
        self.arrivalLabel!.text = NSLocalizedString("arrival", comment: "")
        self.arrivalLabel!.textColor = .gray
        self.addSubview(self.arrivalLabel!)
        
        self.arrivalTimeLabel = UILabel(frame: CGRect(x: 90, y: self.arrivalLabel!.frame.maxY-3, width: 80, height: 20))
        self.arrivalTimeLabel!.font = UIFont(name: "Ubuntu-Medium", size: 14)
        self.arrivalTimeLabel!.text = NSLocalizedString("%Hh%M", comment: "").replacingOccurrences(of: "%H", with: "\(trip.arrivalTime.hours)").replacingOccurrences(of: "%M", with: trip.arrivalTime.mins < 10 ? "0\(trip.arrivalTime.mins)" : "\(trip.arrivalTime.mins)")
        self.arrivalTimeLabel!.textColor = .black
        self.addSubview(self.arrivalTimeLabel!)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
