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
    
    var station: StopZone?
    
    var logos: [UILineLogo] = []
    var label: MarqueeLabel?
    
    init(frame: CGRect, station: StopZone, distance: Double) {
        self.station = station
        super.init(frame: frame)
        
        self.layer.cornerRadius = 15
        self.backgroundColor = .white
        
        //Line logos
        var x = Int(self.frame.maxX)-15
        let lines = station.getLines()
        for i in 0..<lines.count {
            x -= 50
            
            if (x < Int(self.frame.width)/2) { break }
            let logo = UILineLogo(lineShortName: lines[i].shortName, bgColor: lines[i].bgColor, fontColor: lines[i].ftColor, type: lines[i].type, at: CGPoint(x: x, y: (Int(self.frame.height)-28)/2))
            self.logos.append(logo)
            self.addSubview(logo.panel)
        }
        
        //Station name
        self.label = MarqueeLabel.init(frame: CGRect.init(x: 15, y: 0, width: x-30, height: Int(self.frame.height)), duration: 6.0, fadeLength: 6.9)
        self.label!.text = station.name
        self.label!.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(18))
        self.addSubview(self.label!)
        
        //If station is near
        if (distance <= 150) {
            self.frame.size = CGSize(width: self.frame.width, height: self.frame.height*2)
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
