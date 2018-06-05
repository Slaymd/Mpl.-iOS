//
//  ResearcherViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 12/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class ResearcherViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var mainScrollView: MainScrollView
    
    var lineCards: [UILineCard] = []
    var stationCards: [UILightStationCard] = []
    var animState = 0

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerShadowLabel: UILabel!
    @IBOutlet weak var headerLightLabel: UILabel!

    @IBOutlet weak var linesTitle: UILabel!
    @IBOutlet weak var linesScroll: UIScrollView!
    
    @IBOutlet weak var stationsTitle: UILabel!
    @IBOutlet weak var stationsScroll: UIScrollView!
    @IBOutlet weak var stationsSearchButton: UIButton!
    
    var refresher: Timer!

    //MARK: - INITS
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, mainScrollView: MainScrollView) {
        self.mainScrollView = mainScrollView
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VIEW LOAD INITIALIZATION
    
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
        
        //Localizable
        self.headerLightLabel.text = NSLocalizedString("Search", comment: "").uppercased()
        self.headerShadowLabel.text = NSLocalizedString("Search", comment: "").uppercased()
        self.stationsTitle.text = NSLocalizedString("Stations", comment: "")
        self.linesTitle.text = NSLocalizedString("Lines", comment: "")
        
        //Lines scrollview
        linesScroll.frame.origin = CGPoint(x: 0, y: self.headerView.frame.height+75)
        linesScroll.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 170)
        
        self.linesTitle.frame = CGRect(x: 16, y: self.headerView.frame.maxY+50, width: self.linesScroll.frame.width, height: 23)
        
        let sortedLines = TransportData.lines.sorted(by: { $0.displayId < $1.displayId})
        
        for i in 0..<sortedLines.count {
            if i >= sortedLines.count { break }
            let line = sortedLines[i]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            let lineCard = UILineCard.init(frame: CGRect.init(x: i*150+15+(15*i), y: 5, width: 150, height: 160), line: line)
            lineCard.addGestureRecognizer(tap)
            lineCards.append(lineCard)
            self.linesScroll.addSubview(lineCard)
            self.linesScroll.contentSize = CGSize(width: i*150+15+(15*i)+150+15, height: 170)
        }
        
        //Station list
        self.stationsTitle.frame.origin = CGPoint(x: 16, y: self.linesScroll.frame.maxY+20)
        self.stationsScroll.frame.origin = CGPoint(x: 0, y: self.linesScroll.frame.maxY+50)
        self.stationsScroll.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-self.stationsScroll.frame.minY)
        print(self.stationsSearchButton.frame)
        self.stationsSearchButton.frame.origin = CGPoint(x: UIScreen.main.bounds.width-16-self.stationsSearchButton.frame.width, y: self.stationsTitle.frame.minY-7)
        print(self.stationsSearchButton.frame)
        self.view.addSubview(self.stationsSearchButton)
        
        let refLocation = self.mainScrollView.userLocation != nil ? self.mainScrollView.userLocation : TransportData.getStopZoneById(stopZoneId: 308)!.coords
        let sortedStations = TransportData.stopZones.sorted(by: { refLocation!.distance(from: $0.coords) < refLocation!.distance(from: $1.coords) })
        
        var y = 0
        for i in 0..<12 {
            if i >= sortedStations.count { break }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleStationTap(sender:)))
            let distance = self.mainScrollView.userLocation == nil ? 1000.0 : Double((refLocation?.distance(from: sortedStations[i].coords))!)
            let stationCard = UILightStationCard.init(frame: CGRect.init(x: 16, y: y, width: Int(UIScreen.main.bounds.width)-32, height: 50), station: sortedStations[i], distance: distance)
            stationCard.addGestureRecognizer(tap)
            self.stationsScroll.addSubview(stationCard)
            self.stationCards.append(stationCard)
            y += Int(stationCard.frame.height)+15
            self.stationsScroll.contentSize = CGSize(width: Int(self.stationsScroll.frame.width), height: y)
        }
        
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
    
    //MARK: - CLICKS
    
    @objc func handleStationTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.stationsScroll)
        
        for stationCard in self.stationCards {
            if clickLoc.x < stationCard.frame.minX || clickLoc.x > stationCard.frame.maxX { continue }
            if clickLoc.y < stationCard.frame.minY || clickLoc.y > stationCard.frame.maxY { continue }
            
            let stationPopUp: StationPopUpView = StationPopUpView.init(nibName: "StationPopUpView", bundle: nil, station: stationCard.station, mainView: self)
            stationPopUp.modalPresentationStyle = .overCurrentContext
            self.present(stationPopUp, animated: false, completion: nil)
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.linesScroll)
        
        for lineCard in self.lineCards {
            if clickLoc.x < lineCard.frame.minX || clickLoc.x > lineCard.frame.maxX { continue }
            if clickLoc.y < lineCard.frame.minY || clickLoc.y > lineCard.frame.maxY { continue }
            
            let lineView: LineViewController = LineViewController.init(nibName: "LineViewController", bundle: nil, line: lineCard.line!)
            self.navigationController?.pushViewController(lineView, animated: true)
            break
        }
    }
    
    @IBAction func clickOnTextResearcher(_ sender: Any) {
        let textResearchView: TextResearcherView =  TextResearcherView.init(nibName: "TextResearcherView", bundle: nil)
        
        self.navigationController?.pushViewController(textResearchView, animated: true)
    }

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
