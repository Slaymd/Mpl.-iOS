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
        
        //Station name
        self.stationName = MarqueeLabel(frame: CGRect(x: 35, y: (frame.height-20)/2, width: (frame.width-35)/2, height: 20) , duration: 8.0, fadeLength: 6.0)
        self.stationName!.text = station.name
        self.stationName!.font = UIFont(name: "Ubuntu-Bold", size: 18.0)
        self.addSubview(self.stationName!)
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
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
