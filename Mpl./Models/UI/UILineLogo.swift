//
//  UILineLogo.swift
//  Mpl.
//
//  Created by Darius Martin on 27/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class UILineLogo {

    var panel: UIView
    var icon: UIImageView
    var label: UILabel
    
    var topLeftCornerRadius: Int
    
    init(lineShortName: String, bgColor: UIColor, fontColor: UIColor, type: LineType, at: CGPoint) {
        self.icon = UIImageView(frame: CGRect(x: 40/2-24/2, y: 28/2-24/2, width: 24, height: 24))
        self.panel = UIView(frame: CGRect(x: at.x, y: at.y, width: 40, height: 28))
        self.label = MarqueeLabel(frame: CGRect(x: 2, y: self.panel.center.y-9-self.panel.frame.minY, width: self.panel.frame.width-4, height: 16), duration: 3.0, fadeLength: 2.0)
        if type == .TRAMWAY {
            self.panel.roundCorners([.bottomLeft, .bottomRight, .topLeft], radius: 8)
            self.topLeftCornerRadius = 8
        } else {
            self.panel.roundCorners([.allCorners], radius: 10)
            self.topLeftCornerRadius = 10
        }
        self.panel.backgroundColor = bgColor
        self.label.text = lineShortName
        self.label.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
        self.label.textAlignment = .center
        self.label.textColor = fontColor
        
        //special lines (icons)
        if lineShortName == "La Ronde (15)" {
            if self.panel.backgroundColor == .white {
                self.icon.image = #imageLiteral(resourceName: "laronde-dark")
            } else {
                self.icon.image = #imageLiteral(resourceName: "laronde-light")
            }
            self.label.text = ""
        } else if lineShortName == "La Navette (13)" {
            if self.panel.backgroundColor == .white {
                self.icon.image = #imageLiteral(resourceName: "lanavette-dark")
            } else {
                self.icon.image = #imageLiteral(resourceName: "lanavette-light")
            }

            self.label.text = ""
        }
        self.panel.addSubview(self.icon)
        self.panel.addSubview(self.label)
    }
    
    init(line: Line, rect: CGRect) {
        //hard elemts
        self.icon = UIImageView(frame: CGRect(x: 0+((40/2)-(24/2)), y: 0+((28/2)-(24/2)), width: 24, height: 24))
        let panel: UIView = UIView(frame: rect)
        var lineName: UILabel
        //borders mask
        switch (line.type) {
        case LineType.TRAMWAY:
            lineName = UILabel(frame: CGRect(x: 0, y: panel.center.y-9-rect.minY, width: rect.width, height: 16))
            let tram_path = UIBezierPath(roundedRect:panel.bounds, byRoundingCorners:[.topLeft, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8))
            let tram_mask = CAShapeLayer()
            tram_mask.path = tram_path.cgPath
            panel.layer.mask = tram_mask
        case LineType.BUS:
            let radius = rect.width < rect.height ? rect.width/2 : rect.height/2
            panel.frame = CGRect(x: rect.midX-radius, y: rect.midY-radius, width: radius*2, height: radius*2)
            lineName = UILabel(frame: CGRect(x: 0, y: panel.center.y-9-rect.minY, width: radius*2, height: 16))
            panel.layer.cornerRadius = 4
        case LineType.UNKNOWN:
            lineName = UILabel(frame: CGRect(x: 0, y: panel.center.y-9-rect.minY, width: rect.width, height: 16))
            panel.layer.cornerRadius = 8
        }
        //bg and color
        panel.backgroundColor = line.bgColor
        lineName.text = line.shortName
        lineName.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
        lineName.textAlignment = NSTextAlignment.center
        lineName.textColor = line.ftColor
        panel.addSubview(lineName)
        
        self.panel = panel
        self.label = lineName
        self.topLeftCornerRadius = 0
    }
}
