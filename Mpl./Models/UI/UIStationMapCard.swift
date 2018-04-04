//
//  UIStationMapCard.swift
//  Mpl.
//
//  Created by Darius Martin on 18/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class UIStationMapCard: UIView {
    
    var station: StopZone
    var fromLine: Line?
    var toLine: Line?
    
    var stationName: MarqueeLabel?
    
    var schedulesUI: [UIMultiDirectionSchedule] = []
    
    init(frame: CGRect, station: StopZone, fromLine line1: Line?, toLine line2: Line?) {
        self.station = station
        self.fromLine = line1
        self.toLine = line2
        super.init(frame: frame)
        
        //Station point and line
        if line1 != nil {
            let lineView = UIView(frame: CGRect(x: 20, y: 0, width: 4, height: frame.height/2))
            lineView.backgroundColor = line1!.bgColor
            self.addSubview(lineView)
        }
        if line2 != nil {
            let lineView = UIView(frame: CGRect(x: 20, y: frame.height/2, width: 4, height: frame.height/2))
            lineView.backgroundColor = line2!.bgColor
            self.addSubview(lineView)
        }
        
        let stationPoint = UIView(frame: CGRect(x: 22-7, y: (frame.height-14)/2, width: 14, height: 14))
        self.addSubview(stationPoint)
        if station.getLines().count == 1 {
            stationPoint.layer.cornerRadius = 7
            stationPoint.backgroundColor = line1 != nil ? line1!.bgColor : line2!.bgColor
        } else {
            stationPoint.backgroundColor = .black
            let stationSubPoint = UIView(frame: CGRect(x: 22-4, y: (frame.height-8)/2, width: 8, height: 8))
            stationSubPoint.backgroundColor = .white
            self.addSubview(stationSubPoint)
        }
        
        //Lines logo
        var lines = self.station.getLines().sorted(by: {$0.displayId < $1.displayId})
        for _ in 0..<2 {
            let index = lines.index(where: {$0 == line1 || $0 == line2})
            
            if index != nil {
                lines.remove(at: index!)
            }
        }
        var dispId = 1
        
        for i in 0..<lines.count {
            let line = lines[i]
            
            if line == line1 || line == line2 { continue }
            if dispId > 3 {
                let more = UILabel(frame: CGRect(x: Int(UIScreen.main.bounds.width)-20, y: (Int(frame.height)-20)/2-4, width: 20, height: 28))
                more.font = UIFont(name: "Ubuntu-Medium", size: 14.0)
                more.text = "+\(lines.count-3)"
                more.textColor = .lightGray
                more.textAlignment = .center
                self.addSubview(more)
                break
            }
            let x = Int(UIScreen.main.bounds.width)-15-(40+5)*dispId
            let y = (Int(frame.height)-20)/2-4
            let lineLogo = UILineLogo(lineShortName: line.shortName, bgColor: line.bgColor, fontColor: line.ftColor, type: line.type, at: CGPoint(x: x, y: y))
            self.addSubview(lineLogo.panel)
            dispId += 1
        }
        
        //Station name
        let textWidth = Int(UIScreen.main.bounds.width)-15-(40+5)*dispId - 2
        self.stationName = MarqueeLabel(frame: CGRect(x: 35, y: Int((frame.height-20)/2), width: textWidth, height: 20), duration: 8.0, fadeLength: 6.0)
        self.stationName!.text = station.name
        self.stationName!.font = UIFont(name: "Ubuntu-Bold", size: 18.0)
        self.addSubview(self.stationName!)
        
        //Schedules
        let scheduleLen = Int((UIScreen.main.bounds.width-35-10)/2.5)
        for i in 0..<3 {
            self.schedulesUI.append(UIMultiDirectionSchedule(frame: CGRect(x: 35+scheduleLen*i, y: Int(self.stationName!.frame.maxY)+11, width: scheduleLen, height: 31)))
            self.addSubview(schedulesUI[i])
        }
    }
    
    //MARK: - UPDATE SCHEDULES
    
    public func updateDisplayedSchedules() {
        for i in 0..<station.schedules.count {
            let schedule = station.schedules[i]
            
            if i >= schedulesUI.count-1 { break }
            schedulesUI[i].update(with: schedule)
        }
    }
    
    required init?(coder aDecoder: NSCoder, station: StopZone, fromLine line1: Line?, toLine line2: Line?) {
        self.station = station
        self.fromLine = line1
        self.toLine = line2
        super.init(coder: aDecoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
