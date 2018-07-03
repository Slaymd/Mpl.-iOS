//
//  UILineIcon.swift
//  Mpl.
//
//  Created by Darius Martin on 24/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

enum UILineIconType {
    case LIGHT
    case DARK
}

class UILineIcon: UIView {

    var line: Line?
        
    init(frame: CGRect, lineIdentifier: String, backgroundColor: UIColor, fontColor: UIColor, type: LineType, icon: UIImage?) {
        super.init(frame: frame)
        if type == .TRAMWAY {
            self.roundCorners([.bottomLeft, .bottomRight, .topLeft], radius: 8)
        } else {
            self.roundCorners([.allCorners], radius: 10)
        }
        self.backgroundColor = backgroundColor
        
        if icon != nil { //icon
            
            let lineIcon = UIImageView(frame: CGRect(x: frame.width/2-24/2, y: frame.height/2-24/2, width: 24, height: 24))
            lineIcon.image = icon!
            self.addSubview(lineIcon)
            
        } else { //label
            
            let lineLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height-1))
            lineLabel.text = lineIdentifier
            lineLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
            lineLabel.adjustsFontSizeToFitWidth = true
            lineLabel.textAlignment = .center
            lineLabel.textColor = fontColor
            self.addSubview(lineLabel)
            
        }
    }
    
    convenience init(_ line: Line, at: CGPoint) {
        self.init(frame: CGRect(x: at.x, y: at.y, width: 40, height: 28), line: line, type: .DARK)
    }
    
    convenience init(frame: CGRect, line: Line) {
        self.init(frame: frame, line: line, type: .DARK)
    }
    
    convenience init(frame: CGRect, line: Line, type: UILineIconType) {
        //icon
        var icon: UIImage?
        if line.tamId == 13 {
            icon = type == .DARK ? #imageLiteral(resourceName: "lanavette-light") : #imageLiteral(resourceName: "lanavette-dark")
        } else if line.tamId == 15 {
            icon = type == .DARK ? #imageLiteral(resourceName: "laronde-light") : #imageLiteral(resourceName: "laronde-dark")
        }
        //init
        self.init(frame: frame, lineIdentifier: line.shortName, backgroundColor: type == .LIGHT ? UIColor.white : line.bgColor, fontColor: type == .LIGHT ? line.bgColor : line.ftColor, type: line.type, icon: icon)
        self.line = line
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
