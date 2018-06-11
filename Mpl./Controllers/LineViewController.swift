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

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerTitleShadow: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    
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
        self.header.backgroundColor = line.bgColor
        self.headerTitleShadow.text = line.shortName
        self.headerTitle.text = line.shortName
        
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
