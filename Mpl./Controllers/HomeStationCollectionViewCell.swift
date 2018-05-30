//
//  HomeStationCellCollectionViewCell.swift
//  Mpl.
//
//  Created by Darius Martin on 02/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel
import CoreMotion
import NotificationBannerSwift

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
    
    @IBOutlet weak var disruptedIcon: UIImageView!
    
    let motionManager = CMMotionManager()
    var isPressed: Bool = false
    var homeView: HomeView? = nil
    
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
        
        self.procheLabel1.text = NSLocalizedString("near", comment: "")
        self.procheLabel2.text = NSLocalizedString("near", comment: "")

        self.plusLabel = UILabel(frame: CGRect(x: 0, y: 28*2, width: 40, height: 16))
        self.plusLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(14))
        self.plusLabel.textAlignment = .center
        self.plusLabel.textColor = UIColor(red: 178/255, green: 190/255, blue: 195/255, alpha: 1)
        self.card.addSubview(self.plusLabel)
        self.card.addSubview(self.stationName)
        
        nearIcon1.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
        nearIcon1.animationDuration = 1.2
        nearIcon2.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
        nearIcon2.animationDuration = 1.2
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    var pitch = motion.attitude.pitch * 9 // x-axis
                    let roll = motion.attitude.roll * 9 // y-axi
                    
                    pitch = pitch > 11 ? 11 : pitch < 0 ? 0 : pitch
                    //if !self.isPressed {
                        self.transform = CGAffineTransform(translationX: CGFloat(roll), y: CGFloat(pitch-8))
                    //}
                }
            })
        }
        self.configureGestureRecognizer()
    }
    
    // MARK: - Gesture Recognizer
    
    private func configureGestureRecognizer() {
        // Long Press Gesture Recognizer
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.addGestureRecognizer(longPressGestureRecognizer)
        
        // Simple click
        let click = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(click)
    }
    
    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            handleLongPressBegan()
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if (self.homeView == nil || self.station == nil) { return }
        let stationPopUp: StationPopUpView = StationPopUpView.init(nibName: "StationPopUpView", bundle: nil, station: self.station!, mainView: self.homeView!)
        stationPopUp.modalPresentationStyle = .overCurrentContext
        homeView!.present(stationPopUp, animated: false, completion: nil)
        /*homeView!.addChildViewController(stationPopUp)
        stationPopUp.view.frame = homeView!.view.frame
        homeView!.view.addSubview(stationPopUp.view)
        stationPopUp.didMove(toParentViewController: homeView!)*/
        //homeView?.navigationController?.pushViewController(stationPopUp, animated: false)
        //homeView!.present(stationPopUp, animated: false, completion: nil)
        //self.navigationController?.pushViewController(researchView, animated: true)
        //ViewMaker.createStationPopUpFromHome(view: self.homeView!, station: self.station!)
    }
    
    private func handleLongPressBegan() {
        guard !isPressed else {
            return
        }
        
        if (station == nil) { return }
        isPressed = true
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { (value: Bool) in self.homeView?.dispContextualMenu(station: self.station!) })
    
    }
    
    private func handleLongPressEnded() {
        guard isPressed else {
            return
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.card.transform = CGAffineTransform.identity
        }) { (finished) in
            self.isPressed = false
        }
    }
    
    // UI INITIALIZATION FUNCTIONS
    
    func fill(_ station: StopZone, fromView: HomeView) {
        if self.station != nil && self.station!.id == station.id { return }
        //Updating station
        station.updateTimetable(completion: { (result: Bool) in
            if result == true {
                self.updateDisplayedArrivals()
            }
        })
        //Saving station object
        self.station = station
        //Main view
        self.homeView = fromView
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
            self.card.addSubview(lineLogo.panel)
            if linesLogos.count == 1 {
                self.card.roundCorners([.bottomRight, .topRight, .bottomLeft], radius: 15)
                self.card.layer.cornerRadius = 15
            }
        }
    }
    
    // UI UPDATES
    
    func updateDisplayedArrivals() {
        if (self.station == nil) { return }
        var nbArrivals = self.station!.schedules.count
        
        hideAllScheduleElements()
        if nbArrivals > 0 {
            otherLabel.isHidden = true
            nbArrivals = nbArrivals > 2 ? 2 : nbArrivals
            for i in 0..<nbArrivals {
                let schedule = self.station!.schedules[i]
                displaySchedule(displayId: i, schedule: schedule)
            }
        } else {
            otherLabel.isHidden = false
            if self.station!.updateState == 1 {
                otherLabel.text = "..."
            } else {
                otherLabel.text = "Service terminé."
            }
        }
        
        //Update disruption
        var disrupted = false
        
        for line in self.station!.lines {
            DisruptionData.isLineDisrupted(line: line, completion: { (value: Bool) in
                if value == true {
                    disrupted = true
                }
            })
        }
        if disrupted {
            self.disruptedIcon.isHidden = false
            self.stationName.frame.size = CGSize(width: 172, height: 28)
        } else {
            self.disruptedIcon.isHidden = true
            self.stationName.frame.size = CGSize(width: 190, height: 28)
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
    
    func displaySchedule(displayId: Int, schedule: Schedule) {
        let nearIcon = displayId == 0 ? nearIcon1 : nearIcon2
        let procheLabel = displayId == 0 ? procheLabel1 : procheLabel2
        let timeLabel = displayId == 0 ? timeLabel1 : timeLabel2
        let destinationLabel = displayId == 0 ? destinationLabel1 : destinationLabel2
        
        destinationLabel!.isHidden = false
        if schedule.waitingTime < 2 {
            nearIcon!.isHidden = false
            nearIcon!.startAnimating()
            procheLabel!.isHidden = false
            destinationLabel!.textColor = UIColor.darkGray
            destinationLabel!.text = schedule.destination.directionName.uppercased()
        } else if schedule.waitingTime < 180 {
            timeLabel!.isHidden = false
            timeLabel!.text = schedule.waitingTime < 60 ?  "\(schedule.waitingTime) " + NSLocalizedString("mins", comment: "") : NSLocalizedString("+1 hour", comment: "")
            destinationLabel!.textColor = UIColor.lightGray
            destinationLabel!.text = schedule.destination.directionName.uppercased()
        }
    }

}
