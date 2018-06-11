//
//  UIService.swift
//  Mpl.
//
//  Created by Darius Martin on 09/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class UIParking: UIView {
    
    var parking: Parking
    
    var logoView: UIView?
    var logoLabel: UILabel?
    var parkingNameLabel: UILabel?
    var parkingInfosLabel: UILabel?
    
    init(frame: CGRect, parking: Parking) {
        self.parking = parking
        super.init(frame: frame)
        
        self.logoView = UIView(frame: CGRect(x: 8, y: 0, width: frame.height, height: frame.height))
        self.logoView?.backgroundColor = UIColor(red: 0, green: 168/255, blue: 1.0, alpha: 0.8)
        self.addSubview(logoView!)
        self.logoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.logoView!.frame.width, height: self.logoView!.frame.height))
        self.logoLabel!.text = "P"
        self.logoLabel!.textColor = .white
        self.logoLabel!.textAlignment = .center
        self.logoLabel!.font = UIFont(name: "Ubuntu-Bold", size: 25)
        logoView!.addSubview(logoLabel!)
        self.parkingNameLabel = UILabel(frame: CGRect(x: logoView!.frame.maxX + 10, y: 0, width: frame.width - (logoView!.frame.width+10) - 8, height: frame.height / 2 + 2))
        self.parkingNameLabel!.text = parking.name
        self.parkingNameLabel!.textColor = .black
        self.parkingNameLabel!.font = UIFont(name: "Ubuntu-Bold", size: 20)
        self.addSubview(parkingNameLabel!)
        self.parkingInfosLabel = UILabel(frame: CGRect(x: logoView!.frame.maxX + 10, y: frame.height / 2, width: frame.width - (logoView!.frame.width+10) - 8, height: frame.height / 2))
        self.parkingInfosLabel!.textColor = .darkGray
        let greenColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
        if parking.spotFree != -1 { //REAL TIME
            let attrText = NSMutableAttributedString()
            attrText.append(NSMutableAttributedString(string: "\(parking.spotFree)", attributes: [.foregroundColor : greenColor]))
            attrText.append(NSMutableAttributedString(string: " \(NSLocalizedString("free spots", comment: ""))"))
            self.parkingInfosLabel!.attributedText = attrText
        } else { //THEORICAL
            self.parkingInfosLabel!.text = "\(parking.spotTotal) \(NSLocalizedString("parking spots", comment: ""))"
        }
        self.parkingInfosLabel!.font = UIFont(name: "Ubuntu-Medium", size: 18)
        self.addSubview(parkingInfosLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class UIBike: UIView {
    
    var bikeStation: BikeStation
    
    var logoView: UIView?
    var logoImage: UIImageView?
    var stationNameLabel: MarqueeLabel?
    var stationInfosLabel: UILabel?
    
    init(frame: CGRect, bikeStation: BikeStation) {
        self.bikeStation = bikeStation
        super.init(frame: frame)
        
        self.logoView = UIView(frame: CGRect(x: 8, y: 0, width: frame.height, height: frame.height))
        self.logoView?.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 0.8)
        self.addSubview(logoView!)
        let logoImageMargin = self.logoView!.frame.width * 0.15
        let logoImageSize = self.logoView!.frame.width - (logoImageMargin * 2)
        self.logoImage = UIImageView(frame: CGRect(x: logoImageMargin, y: logoImageMargin, width: logoImageSize, height: logoImageSize))
        self.logoImage!.image = #imageLiteral(resourceName: "man-cycling")
        logoView!.addSubview(logoImage!)
        self.stationNameLabel = MarqueeLabel(frame: CGRect(x: logoView!.frame.maxX + 10, y: 0, width: frame.width - (logoView!.frame.width+10) - 8, height: frame.height / 2 + 2), duration: 8.0, fadeLength: 5.0)
        self.stationNameLabel!.text = bikeStation.name
        self.stationNameLabel!.textColor = .black
        self.stationNameLabel!.font = UIFont(name: "Ubuntu-Bold", size: 20)
        self.addSubview(stationNameLabel!)
        self.stationInfosLabel = UILabel(frame: CGRect(x: logoView!.frame.maxX + 10, y: frame.height / 2, width: frame.width - (logoView!.frame.width+10) - 8, height: frame.height / 2))
        self.stationInfosLabel!.textColor = .darkGray
        let greenColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
        let attrText = NSMutableAttributedString()
        attrText.append(NSMutableAttributedString(string: "\(bikeStation.spotWithBike)", attributes: [.foregroundColor : greenColor]))
        attrText.append(NSMutableAttributedString(string: " \(NSLocalizedString("bikes", comment: "")) • "))
        attrText.append(NSMutableAttributedString(string: "\(bikeStation.spotFree)", attributes: [.foregroundColor : greenColor]))
        attrText.append(NSMutableAttributedString(string: " \(NSLocalizedString("free spots", comment: ""))"))
        self.stationInfosLabel!.attributedText = attrText
        self.stationInfosLabel!.font = UIFont(name: "Ubuntu-Medium", size: 16)
        self.addSubview(stationInfosLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
