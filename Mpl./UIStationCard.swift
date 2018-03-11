//
//  UIStationCard.swift
//  Mpl.
//
//  Created by Darius Martin on 27/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel
import NotificationBannerSwift

/*class UIStationCard {
    
    var card: UIView
    var stationName: MarqueeLabel
    var linesLogo: [UILineLogo] = [UILineLogo]()
    var station: StopZone
    var nextSchedules: [Int] = []
    var evt_startpress: TimeInterval? = nil
    
    func longPressAnimationStart() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       animations: { self.card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) })
    }
    
    func longPressAnimationClose() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       animations: { self.card.transform = .identity })
    }
    
    func dispContextualMenu(viewController: HomeView) {
        let haptic: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator()
        
        haptic.prepare()
        haptic.impactOccurred()
        let alert = UIAlertController(title: "Station : \(self.station.name)", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { _ in
            UserData.removeFavStation(station: self.station)
            viewController.update()
        }))
        alert.addAction(UIAlertAction(title: "Plus d'informations", style: .default, handler: { _ in
            ViewMaker.createStationPopUpFromHome(view: viewController, station: self.station)
        }))
        alert.addAction(UIAlertAction(title: "S'y rendre", style: .default, handler: { _ in
            let banner = NotificationBanner(title: "S'y rendre", subtitle: "Bientôt disponible.", style: .info)
            banner.haptic = .light
            banner.show()
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    init(x: CGFloat, y: CGFloat, station: StopZone){
        let card: UIView = UIView(frame: CGRect(x: x, y: y, width: 250, height: 75))
        let stationName = MarqueeLabel(frame: CGRect(x: 50, y: 6, width: 190, height: 14), duration: 4.0, fadeLength: 5.0)
        let lines = station.getLines()

        //Background card
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 15
        /*card.layer.shadowColor = UIColor.lightGray.cgColor
        card.layer.shadowRadius = 20
        card.layer.shadowOpacity = 0.2
        card.layer.shadowOffset = CGSize.zero*/
        self.card = card
        self.station = station
        //Card label
        stationName.text = station.name.folding(options: .diacriticInsensitive, locale: NSLocale.current).uppercased()
        stationName.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
        card.addSubview(stationName)
        self.stationName = stationName
        //Line Logo
        if (lines.count <= 2) {
            for i in 0..<lines.count {
                self.linesLogo.append(UILineLogo(line: lines[i], rect: CGRect(x: 0, y: 28*i, width: 40, height: 28)))
                card.addSubview(self.linesLogo[i].panel)
            }
        } else {
            self.linesLogo.append(UILineLogo(line: station.lines[0], rect: CGRect(x: 0, y: 28*0, width: 40, height: 28)))
            card.addSubview(self.linesLogo[0].panel)
            let fictLine = Line(id: -1, tamId: -1, citywayId: -1, displayId: -1, name: "+\(station.lines.count-1)", shortName: "+\(station.lines.count-1)", forwardDir: "", backwardDir: "", mode: -1, color: "#b2bec3", fontColor: "#2d3436", urban: -1)
            self.linesLogo.append(UILineLogo(line: fictLine, rect: CGRect(x: 0, y: 28*1, width: 40, height: 28)))
            card.addSubview(self.linesLogo[1].panel)
        }
        //Next arrivals

        for i in 0..<(station.timetable.schedules.count > 2 ? 2 : station.timetable.schedules.count) {
            let arrival = station.timetable.schedules[i]
            addNextArrival(in: arrival.date.getSecondsFromNow(), toDestination: arrival.dest.directionName, withLine: TransportData.getLineById(arrival.lineId)!, atIndex: i)
            self.nextSchedules.append(arrival.date.getMinsFromNow())
        }
        if station.timetable.schedules.count == 0 {
            let stopped: UILabel = UILabel(frame: CGRect(x: 50, y: 37, width: 140, height: 20))
            stopped.text = station.timetable.state == 1 ? "..." : "Service terminé."
            stopped.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(16))
            card.addSubview(stopped)
        }
        /*var arrival: (mins: Int, line: Line, destId: Int)
        for i in 0..<station.nextArrivals.count {
            arrival = station.nextArrivals[i]
            addNextArrival(in: arrival.mins, toDestination: arrival.line.directions[arrival.destId], withLine: arrival.line, atIndex: i)
        }*/
    }
    
    func addNextArrival(in seconds: Int, toDestination dest: String, withLine line: Line?, atIndex index: Int) {
        let timeInMins = Int(round(Double(seconds)/60.0))

        if index > 1 { return }
        if seconds <= 90 { //Near
            //Near icon
            let near: UIImageView = UIImageView(frame: CGRect(x: 45+90*index, y: 35, width: 10, height: 10))
            near.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
            near.animationDuration = 1.2
            near.startAnimating()
            //Near label
            let nearLabel: UILabel = UILabel(frame: CGRect(x: 45+90*index+11, y: 30, width: 75, height: 15))
            nearLabel.text = "proche"
            nearLabel.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(14))
            nearLabel.textColor = UIColor(red: 120.0/255, green: 169.0/255, blue: 66.0/255, alpha: 1.0)
            //Destination label
            let destinLabel: MarqueeLabel = MarqueeLabel(frame: CGRect(x: 45+90*index, y: 43, width: 85, height: 16), duration: 4.0, fadeLength: 3.0)
            destinLabel.text = dest.uppercased()
            destinLabel.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(15))
            destinLabel.textColor = UIColor.darkGray
            //Adding subview
            self.card.addSubview(near)
            self.card.addSubview(nearLabel)
            self.card.addSubview(destinLabel)
        } else {
            //Time label
            let timeLabel: UILabel = UILabel(frame: CGRect(x: 45+100*index, y: 30, width: 90, height: 15))
            timeLabel.text = "\(timeInMins) mins"
            timeLabel.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(14))
            timeLabel.textColor = UIColor.darkGray
            //Destination label
            let destinLabel: MarqueeLabel = MarqueeLabel(frame: CGRect(x: 45+100*index, y: 43, width: 90, height: 16), duration: 4.0, fadeLength: 3.0)
            destinLabel.text = dest.uppercased()
            destinLabel.font = UIFont(name: "Ubuntu-Medium", size: CGFloat(15))
            destinLabel.textColor = UIColor.lightGray
            //Adding subview
            self.card.addSubview(timeLabel)
            self.card.addSubview(destinLabel)
        }
    }

}*/
