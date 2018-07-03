//
//  UIItinerary.swift
//  Mpl.
//
//  Created by Darius Martin on 02/07/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class UIItinerary: UIView {

    var trip: Trip
    
    init(_ trip: Trip, at origin: CGPoint, width: CGFloat) {
        self.trip = trip
        super.init(frame: CGRect(origin: origin, size: CGSize(width: width, height: 0)))
        
        var y: CGFloat = 10
        var index = 0
        
        let walkLineSection = UIView(frame: CGRect(x: 20 + 40 + 20, y: y, width: 30, height: 0))
        walkLineSection.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        walkLineSection.layer.cornerRadius = 15
        self.addSubview(walkLineSection)
        
        for segment in trip.segments {
            
            if segment.mode == .BUS || segment.mode == .TRAMWAY {
                
                guard let destination = segment.destination else { continue }
                guard let line = segment.line else { continue }
                guard let firstStop = segment.departureStop else { continue }
                guard let lastStop = segment.arrivalStop else { continue }
                guard let departureTime = segment.departureTime else { continue }
                
                //geting direction well-formatted
                let substrings = destination.replacingOccurrences(of: " - ", with: "€").split(separator: "€")
                if substrings.count <= 1 { continue }
                let direction = String(substrings[1])
                
                //drawing segment head
                let logo = UILineIcon(line, at: CGPoint(x: 20, y: y))
                self.addSubview(logo)
                
                //departure time
                let departureLabel = UILabel(frame: CGRect(x: (walkLineSection.frame.minX / 2) - (50 / 2), y: logo.frame.maxY + 3, width: 50, height: 22))
                departureLabel.textColor = .gray
                departureLabel.text = NSLocalizedString("%Hh%M", comment: "").replacingOccurrences(of: "%H", with: "\(departureTime.hours)").replacingOccurrences(of: "%M", with: departureTime.mins < 10 ? "0\(departureTime.mins)" : "\(departureTime.mins)")
                departureLabel.textAlignment = .center
                departureLabel.font = UIFont(name: "Ubuntu-Bold", size: 14)
                self.addSubview(departureLabel)
                
                //line section
                let lineSection = UIView(frame: CGRect(x: logo.frame.maxX + 20, y: y, width: 30, height: 80))
                lineSection.backgroundColor = line.bgColor
                lineSection.layer.cornerRadius = 15
                self.addSubview(lineSection)
                
                //first station
                let firstStationPoint = UIView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
                firstStationPoint.layer.cornerRadius = 10
                firstStationPoint.backgroundColor = .white
                lineSection.addSubview(firstStationPoint)
                let firstStationLabel = MarqueeLabel(frame: CGRect(x: lineSection.frame.maxX + 15, y: y, width: width - (lineSection.frame.maxX + 15) - 15, height: firstStationPoint.frame.height + 8), duration: 8, fadeLength: 6)
                firstStationLabel.text = firstStop.name
                firstStationLabel.font = UIFont(name: "Ubuntu-Bold", size: 22)
                self.addSubview(firstStationLabel)
                
                //direction
                let directionTitleLabel = UILabel(frame: CGRect(x: firstStationLabel.frame.minX, y: firstStationLabel.frame.maxY + 2, width: firstStationLabel.frame.width, height: 17))
                directionTitleLabel.font = UIFont(name: "Ubuntu-Bold", size: 14)
                directionTitleLabel.text = NSLocalizedString("towards", comment: "")
                directionTitleLabel.textColor = .darkGray
                self.addSubview(directionTitleLabel)
                let directionColorPanel = UIView(frame: CGRect(x: directionTitleLabel.frame.minX, y: directionTitleLabel.frame.maxY, width: 125, height: 20))
                directionColorPanel.layer.cornerRadius = 10
                directionColorPanel.backgroundColor = line.bgColor
                self.addSubview(directionColorPanel)
                let directionLabel = MarqueeLabel(frame: CGRect(x: 0, y: 0, width: directionColorPanel.frame.width, height: directionColorPanel.frame.height-1), duration: 8, fadeLength: 6)
                directionLabel.textColor = line.ftColor
                directionLabel.text = direction
                directionLabel.textAlignment = .center
                directionLabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
                directionColorPanel.addSubview(directionLabel)
                
                self.frame.size.height = lineSection.frame.maxY
                
                var firstLastStopIndex = 0
                
                if (segment.intermediateStops.count >= 3) {
                    
                    let circlesNb = segment.intermediateStops.count - 2
                    firstLastStopIndex = circlesNb
                    let baseCirclesY = lineSection.frame.height
                    
                    for circle in 0..<circlesNb {
                        if circle == 3 { break }
                        
                        let littleCircle = UIView(frame: CGRect(x: 10, y: Int(baseCirclesY) + 5+(circle*5), width: 10, height: 10))
                        littleCircle.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
                        littleCircle.layer.cornerRadius = 5
                        lineSection.addSubview(littleCircle)
                        
                        lineSection.frame.size = CGSize(width: lineSection.frame.width, height: littleCircle.frame.maxY + 20)
                    }
                    
                }
                
                //Displaying last stops
                
                if segment.intermediateStops.count > firstLastStopIndex {
                    
                    for index in firstLastStopIndex..<segment.intermediateStops.count {
                        
                        let intermediateObject = segment.intermediateStops[index]
                        
                        if intermediateObject.name == nil || intermediateObject.name!.count == 0 { continue }
                        
                        let stationCircle = UIView(frame: CGRect(x: 8, y: lineSection.frame.height, width: 14, height: 14))
                        stationCircle.layer.cornerRadius = 7
                        stationCircle.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
                        lineSection.addSubview(stationCircle)
                        let stationLabel = UILabel(frame: CGRect(x: firstStationLabel.frame.minX, y: lineSection.frame.height + y - 5, width: firstStationLabel.frame.width, height: stationCircle.frame.height + 8))
                        stationLabel.text = intermediateObject.name!
                        stationLabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
                        stationLabel.textColor = .gray
                        self.addSubview(stationLabel)
                        
                        
                        lineSection.frame.size = CGSize(width: lineSection.frame.width, height: stationCircle.frame.maxY + 20)
                        
                    }
                    
                }
                
                //segment destination
                let lastStationPoint = UIView(frame: CGRect(x: 5, y: lineSection.frame.height, width: 20, height: 20))
                lastStationPoint.layer.cornerRadius = 10
                lastStationPoint.backgroundColor = .white
                lineSection.addSubview(lastStationPoint)
                let lastStationLabel = MarqueeLabel(frame: CGRect(x: lineSection.frame.maxX + 15, y: lineSection.frame.height + y - 5, width: width - (lineSection.frame.maxX + 15) - 15, height: lastStationPoint.frame.height + 8), duration: 8, fadeLength: 6)
                lastStationLabel.text = lastStop.name
                lastStationLabel.font = UIFont(name: "Ubuntu-Bold", size: 22)
                self.addSubview(lastStationLabel)
                
                lineSection.frame.size = CGSize(width: lineSection.frame.width, height: lastStationPoint.frame.maxY + 5)
                
                y += lineSection.frame.height + 10
                
            } else if segment.mode == .WALK {
                
                var sectionHeight: CGFloat = 70
                var sectionOffset: CGFloat = 15
                if segment.duration == nil || segment.duration! <= 3 {
                    sectionHeight = 15
                    if index == 0 { continue }
                }
                if index + 1 == trip.segments.count {
                    sectionHeight = 50
                    sectionOffset = 0
                }
                guard let distance = segment.distance else { continue }
                guard let departureTime = segment.departureTime else { continue }
                
                if segment.duration != nil && segment.duration! > 3 {
                    let walkIcon = UIImageView(frame: CGRect(x: (walkLineSection.frame.minX / 2) - (30 / 2), y: y, width: 30, height: 30))
                    walkIcon.image = #imageLiteral(resourceName: "itineraries_walk_icon")
                    self.addSubview(walkIcon)
                    let walkLabel = UILabel(frame: CGRect(x: walkLineSection.frame.maxX + 15, y: y, width: width - (walkLineSection.frame.maxX + 15) - 15, height: 30))
                    walkLabel.text = NSLocalizedString("Walk %Dm", comment: "").replacingOccurrences(of: "%D", with: "\(distance)")
                    walkLabel.textColor = .gray
                    walkLabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
                    self.addSubview(walkLabel)
                    
                    //departure time
                    let departureLabel = UILabel(frame: CGRect(x: (walkLineSection.frame.minX / 2) - (50 / 2), y: walkIcon.frame.maxY + 3, width: 50, height: 22))
                    departureLabel.textColor = .gray
                    departureLabel.text = NSLocalizedString("%Hh%M", comment: "").replacingOccurrences(of: "%H", with: "\(departureTime.hours)").replacingOccurrences(of: "%M", with: departureTime.mins < 10 ? "0\(departureTime.mins)" : "\(departureTime.mins)")
                    departureLabel.textAlignment = .center
                    departureLabel.font = UIFont(name: "Ubuntu-Bold", size: 14)
                    self.addSubview(departureLabel)
                }
                
                walkLineSection.frame.size = CGSize(width: walkLineSection.frame.width, height: y + sectionHeight + sectionOffset)
                
                y += sectionHeight
                y += (sectionOffset == 0 ? 20 : 0)
                
            }
            
            self.frame.size.height = y
            index += 1
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
