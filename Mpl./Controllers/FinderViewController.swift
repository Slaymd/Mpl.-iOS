//
//  FinderViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 05/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationBannerSwift
import MarqueeLabel

class FinderViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    //MARK: - VARIABLES
    
    //header outlets
    @IBOutlet weak var headerTitleShadow: UILabel!
    @IBOutlet weak var headerTitleLight: UILabel!
    
    //lines outlets
    @IBOutlet weak var linesTitle: UILabel!
    @IBOutlet weak var linesScrollView: UIScrollView!
    @IBOutlet weak var linesPanelHeightConstraint: NSLayoutConstraint!
    
    //stations outlets
    @IBOutlet weak var stationsTitle: UILabel!
    @IBOutlet weak var stationsScrollView: UIScrollView!
    
    //location
    var userLocationProvider: Int
    var userLocation: CLLocation
    
    //timer
    var refresher: Timer!
    
    //UI tmp
    var lineCards: [UILineCard] = []
    var stationCards: [UILightStationCard] = []
    var dispositionSmall = false

    //MARK: - INIT
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, userLocation: CLLocation?) {
        if (userLocation == nil) {
            self.userLocationProvider = 1
            self.userLocation = TransportData.getStopZoneById(stopZoneId: 308)!.coords
        } else {
            self.userLocationProvider = 0
            self.userLocation = userLocation!
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.userLocation = TransportData.getStopZoneById(stopZoneId: 308)!.coords
        self.userLocationProvider = 1
        super.init(coder: aDecoder)
    }
    
    //MARK: - VIEW LOADING

    override func viewDidLoad() {
        super.viewDidLoad()

        //Notification about user location
        if (self.userLocationProvider == 1) {
            let banner = NotificationBanner(title: NSLocalizedString("Localization", comment: ""), subtitle: NSLocalizedString("Turn on localization to get station list sorted by distance !", comment: ""), style: .warning)
            banner.haptic = .medium
            banner.show()
        }
        
        //Locales
        self.headerTitleLight.text = NSLocalizedString("Search", comment: "").uppercased()
        self.headerTitleShadow.text = NSLocalizedString("Search", comment: "").uppercased()
        self.stationsTitle.text = NSLocalizedString("Stations", comment: "")
        self.linesTitle.text = NSLocalizedString("Lines", comment: "")
        
        //Setup lines
        dispLines(TransportData.lines.sorted(by: {$0.displayId < $1.displayId}))
        
        //Setup stations
        dispStations(TransportData.stopZones.sorted(by: {self.userLocation.distance(from: $0.coords) < self.userLocation.distance(from: $1.coords)}))
        self.stationsScrollView.delegate = self
        
        //Timer init
        self.refresher = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        //Navigation
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //Background state event
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    //MARK: - UI UPDATE LOOP
    
    @objc func update() {
        for stationCard in self.stationCards {
            if stationCard.distance <= 200 {
                stationCard.station.updateTimetable(completion: { (state: Bool) in
                    if state == true {
                        stationCard.updateDisplayedArrivals()
                    }
                })
            }
        }
    }
    
    //MARK: - UI SETUP
    
    func dispLines(_ lines: [Line]) {
        var line: Line

        for i in 0..<lines.count {
            if i >= lines.count { break }
            line = lines[i]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(lineCardTap(sender:)))
            let lineCard = UILineCard.init(frame: CGRect.init(x: i*150+15+(15*i), y: 5, width: 150, height: 150), line: line)
            lineCard.addGestureRecognizer(tap)
            lineCards.append(lineCard)
            self.linesScrollView.addSubview(lineCard)
            self.linesScrollView.contentSize = CGSize(width: i*150+15+(15*i)+150+15, height: 150)
        }
    }
    
    func dispStations(_ stations: [StopZone]) {
        var y = 5

        for i in 0..<12 {
            if i >= stations.count { break }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(stationCardTap(sender:)))
            let distance = self.userLocation.distance(from: stations[i].coords)
            let stationCard = UILightStationCard.init(frame: CGRect.init(x: 16, y: y, width: Int(UIScreen.main.bounds.width)-32, height: 50), station: stations[i], distance: distance)
            stationCard.addGestureRecognizer(tap)
            self.stationsScrollView.addSubview(stationCard)
            self.stationCards.append(stationCard)
            y += Int(stationCard.frame.height)+15
            self.stationsScrollView.contentSize = CGSize(width: Int(self.stationsScrollView.frame.width), height: y)
        }
    }
    
    //MARK: - SCROLLING STATION LIST
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 10 {
            updateLineDisposition(small: true)
        } else {
            updateLineDisposition(small: false)
        }
    }
    
    //MARK: - UPDATE LINE DISPOSITION
    
    func updateLineDisposition(small: Bool) {
        var lineCardHeight: CGFloat = -1

        if small && !self.dispositionSmall {
            self.dispositionSmall = true
            self.linesPanelHeightConstraint.constant = 90
            UIView.animate(withDuration: 0.125) {
                self.view.layoutIfNeeded()
                for card in self.lineCards {
                    card.setSmallVersion()
                    lineCardHeight = card.frame.height
                }
                self.linesScrollView.contentSize = CGSize(width: self.linesScrollView.contentSize.width, height: lineCardHeight)
            }
        } else if !small && self.dispositionSmall {
            self.dispositionSmall = false
            self.linesPanelHeightConstraint.constant = 195
            UIView.animate(withDuration: 0.125) {
                self.view.layoutIfNeeded()
                for card in self.lineCards {
                    card.setNormalVersion()
                    lineCardHeight = card.frame.height
                }
                self.linesScrollView.contentSize = CGSize(width: self.linesScrollView.contentSize.width, height: lineCardHeight)
            }
        }
    }
    
    //MARK: - CLICKING LINE CARD
    
    @objc func lineCardTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.linesScrollView)
        
        for lineCard in self.lineCards {
            if clickLoc.x < lineCard.frame.minX || clickLoc.x > lineCard.frame.maxX { continue }
            if clickLoc.y < lineCard.frame.minY || clickLoc.y > lineCard.frame.maxY { continue }
            
            let lineView: LineViewController = LineViewController.init(nibName: "LineViewController", bundle: nil, line: lineCard.line!)
            self.navigationController?.pushViewController(lineView, animated: true)
            break
        }
    }
    
    //MARK: - CLICKING STATION SEARCH BUTTON
    
    @IBAction func clickStationSearchButton(_ sender: Any) {
        let textResearchView: TextResearcherView =  TextResearcherView.init(nibName: "TextResearcherView", bundle: nil)
        
        self.navigationController?.pushViewController(textResearchView, animated: true)
    }
    
    //MARK: - CLICKING STATION CARD
    
    @objc func stationCardTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.stationsScrollView)
        
        for stationCard in self.stationCards {
            if clickLoc.x < stationCard.frame.minX || clickLoc.x > stationCard.frame.maxX { continue }
            if clickLoc.y < stationCard.frame.minY || clickLoc.y > stationCard.frame.maxY { continue }
            
            let stationPopUp: StationPopUpView = StationPopUpView.init(nibName: "StationPopUpView", bundle: nil, station: stationCard.station, mainView: self)
            stationPopUp.modalPresentationStyle = .overCurrentContext
            self.present(stationPopUp, animated: false, completion: nil)
            break
        }
    }
    
    //MARK: - CLICKING BACK BUTTON
    
    @IBAction func clickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - STATUS BAR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - BACKGROUND STATE
    
    @objc func appMovedToBackground() {
        self.refresher?.invalidate()
        self.refresher = nil
        MarqueeLabel.controllerLabelsLabelize(self)
    }
    
    @objc func appMovedToForeground() {
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        self.update()
        MarqueeLabel.controllerLabelsAnimate(self)
    }
}
