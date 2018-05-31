//
//  LineViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 18/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class LineViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerShadowLabel: UILabel!
    @IBOutlet weak var headerLightLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var line: Line
    
    var stationsMap: [UIStationMapCard] = []
    
    //MARK: - INITS
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, line: Line) {
        self.line = line
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Header
        self.headerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.22)
        self.headerView.layer.shadowRadius = 40
        self.headerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.headerView.layer.shadowOpacity = 1
        //Label position
        headerLightLabel.frame = CGRect(x: 12, y: headerView.frame.maxY-45, width: self.view.frame.width-20, height: headerLightLabel.frame.height)
        headerShadowLabel.frame = CGRect(x: 16, y: headerView.frame.maxY-42, width: self.view.frame.width-20, height: headerLightLabel.frame.height)
        headerView.addSubview(headerShadowLabel)
        headerView.addSubview(headerLightLabel)
        //Scroll view
        scrollView.frame = CGRect(x: 0, y: self.headerView.frame.maxY, width: self.view.frame.width, height: UIScreen.main.bounds.height-self.headerView.frame.height)
        
        //Navigation
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //Line
        fillLine(line)
        
        //Background state event
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    private func fillLine(_ line: Line) {
        self.headerView.backgroundColor = line.bgColor
        self.headerShadowLabel.text = line.shortName
        self.headerLightLabel.text = line.shortName
        
        let lineStations = TransportData.getLineStopZonesByDirection(line: line)
        let dirToDisp: [StopZone] = lineStations.count > 0 ? lineStations[0] : []
        
        //Line map
        var height = 30
        for i in 0..<dirToDisp.count {
            let station = dirToDisp[i]
            let fromLine: Line? = i == 0 ? nil : line
            let toLine: Line? = i == dirToDisp.count-1 ? nil : line
            
            let stationMap = UIStationMapCard(frame: CGRect.init(x: 0, y: height, width: Int(self.scrollView.frame.width), height: 100), station: station, fromLine: fromLine, toLine: toLine)
            height += Int(stationMap.frame.height)
            self.scrollView.addSubview(stationMap)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: CGFloat(height)+30)
            self.stationsMap.append(stationMap)
        }
        
        //display schedules
        self.update()
        
    }
    
    //MARK: - UPDATE
    
    public func update() {
        
        ScheduleData.getSchedules(of: self.line, completion: {(result: Bool) in
            if result {
                for card in self.stationsMap {
                    card.updateDisplayedSchedules()
                }
            }
        })
        
    }
    
    //MARK: - BACKGROUND STATE
    
    @objc func appMovedToBackground() {
        MarqueeLabel.controllerLabelsLabelize(self)
    }
    
    @objc func appMovedToForeground() {
        self.update()
        MarqueeLabel.controllerLabelsAnimate(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if line.ftColor == .white {
            return .default
        } else {
            return .lightContent
        }
    }

}
