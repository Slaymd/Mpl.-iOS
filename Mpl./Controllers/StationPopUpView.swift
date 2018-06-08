//
//  StationPopUpView.swift
//  Mpl.
//
//  Created by Darius Martin on 23/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class StationPopUpView: UIViewController {
    
    //MARK: - VARIABLES
    
    var station: StopZone
    
    //UI pop-up
    
    @IBOutlet weak var popUpWidthConstraint: NSLayoutConstraint!
    
    //UI header
    
    @IBOutlet weak var headerStationTypeLabel: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var header: UIView!
    private var headerTabButtons: [UIButton] = []
    private var headerTabLine: UIView?
    
    //UI content

    @IBOutlet weak var blurBackground: UIVisualEffectView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var actionsCard: UIView!
    @IBOutlet weak var popUpCard: UIView!
    @IBOutlet weak var stationCard: UIView!
    @IBOutlet weak var stationDataScroll: UIScrollView!
    private var contentTamScroll: UIScrollView?
    var informationLabel: UILabel?
    
    var effect: UIVisualEffect?
    
    var disturbancesPanel: UIView?
    var directionsPanel: UIView?
    
    var schedulesUI: [(schedules: (line: Line, dest: Stop, times: [Int]), panel: UIView, lineLogo: UILineLogo, destLabel: MarqueeLabel, timesUI: [UIMonoDirectionSchedule])] = []
    var disturbances: [(disruption: Disruption, lines: [Line])] = []
    
    var refresher: Timer!
    var mainView: UIViewController
    
    //MARK: - INITS
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, station: StopZone, mainView: UIViewController) {
        self.station = station
        self.mainView = mainView
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Identify
        self.effect = blurBackground.effect
        self.blurBackground.effect = nil
        self.view.alpha = 0

        //Round car
        self.stationCard.layer.cornerRadius = 16
        self.actionsCard.layer.cornerRadius = 16
        
        //Station name
        self.stationNameLabel.text = self.station.name.uppercased().toASCII()
        
        //Favorite button
        if UserData.isFavorite(station) {
            self.favoriteButton.isSelected = true
        } else {
            self.favoriteButton.isSelected = false
        }
        
        //Background state event
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    //MARK: - UI UPDATE LOOP
    
    @objc func update() {
        self.station.updateTimetable(completion: { (state: Bool) in
            if state == true {
                self.displaySchedules()
            }
        })
        
    }
    
    /*
    **  STATION POP-UP PAGINATION
    */
    
    //MARK: - SETUP POP-UP PAGE (TRANSPORT DATA, SNCF, SERVICES...)
    
    public func initPages() {
        let dataTypes = StationData.getDataTypes(stopZone: self.station)
        let tabWidth: CGFloat
        let tabHeight: CGFloat
        var tabX: CGFloat = 0
        let tabY: CGFloat
        
        //header pagination when needed
        if dataTypes.count > 1 {
            //values
            tabHeight = 100.0 - self.headerHeightConstraint.constant
            tabY = self.headerHeightConstraint.constant
            self.headerHeightConstraint.constant = 100
            tabWidth = self.stationCard.frame.width / CGFloat(dataTypes.count)
            
            //header tabline
            self.headerTabLine = UIView(frame: CGRect(x: tabX, y: tabY + tabHeight - 3.0, width: tabWidth, height: 3.0))
            self.headerTabLine!.backgroundColor = .black
            self.header.addSubview(headerTabLine!)
            
            //creating header tab buttons
            for dataType in dataTypes {
                let tabButton = UIButton(frame: CGRect(x: tabX, y: tabY, width: tabWidth, height: tabHeight))
                
                tabButton.setTitleColor(.darkGray, for: .normal)
                tabButton.setTitleColor(.black, for: .selected)
                tabButton.titleLabel?.font = UIFont(name: "Ubuntu-Medium", size: 18)
                tabButton.titleLabel?.adjustsFontSizeToFitWidth = true
                tabButton.addTarget(self, action: #selector(clickedTabBarButton(sender:)), for: .touchUpInside)
                switch (dataType.type) {
                case .PUBLIC_TRANSPORT:
                    tabButton.tag = 21
                    tabButton.isSelected = true
                    tabButton.setTitle("TaM", for: .normal)
                case .SNCF:
                    tabButton.tag = 42
                    tabButton.setTitle("SNCF", for: .normal)
                    tabButton.setTitleColor(UIColor(red: 205/255, green: 0.0, blue: 55/255, alpha: 1.0), for: .selected)
                    if (dataType.info != nil) {
                        StationData.getSNCFSchedules(stopArea: dataType.info as! String) { (schedules) in
                            if schedules != nil {
                                for schedule in schedules! {
                                    print(schedule.trainType, schedule.trainNumber, "destination:", schedule.destination, schedule.status)
                                }
                            }
                        }
                    }
                case .SERVICES:
                    tabButton.tag = 84
                    tabButton.setTitle("Services", for: .normal)
                }
                self.headerTabButtons.append(tabButton)
                self.header.addSubview(tabButton)
                tabX += tabWidth
            }
            
            //scroll content size
            self.stationDataScroll.contentSize = CGSize(width: self.stationDataScroll.frame.width * CGFloat(dataTypes.count), height: self.stationDataScroll.frame.height)
        }
        //TaM scroll view
        self.contentTamScroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.stationDataScroll.frame.width, height: self.stationDataScroll.frame.height))
        self.stationDataScroll.addSubview(self.contentTamScroll!)
    }
    
    //MARK: - INIT SNCF SCHEDULES
    
    func displaySNCFSchedules(schedules: [SNCFSchedule]) {
        
    }
    
    //MARK: - TAB BUTTON CLICKED
    
    @objc func clickedTabBarButton(sender: UIButton!) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            //default
            for tabButton in self.headerTabButtons { tabButton.setTitleColor(.black, for: .normal) ; tabButton.isSelected = false }
            //new design values
            sender.isSelected = true
            self.headerTabLine?.frame.origin = CGPoint(x: sender.frame.minX, y: self.headerTabLine!.frame.minY)
            if (sender.tag == 42) {
                //SNCF
                self.headerStationTypeLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
                self.stationNameLabel.textColor = .white
                self.header.backgroundColor = UIColor(red: 0.0, green: 136/255, blue: 206/255, alpha: 1)
                for tabButton in self.headerTabButtons { tabButton.setTitleColor(.white, for: .normal) }
                self.headerTabLine?.backgroundColor = UIColor(red: 205/255, green: 0.0, blue: 55/255, alpha: 1.0)
            } else {
                self.header.backgroundColor = .white
                self.headerStationTypeLabel.textColor = .darkGray
                self.stationNameLabel.textColor = .black
                self.headerTabLine?.backgroundColor = .black
            }
            //scrolling
            self.stationDataScroll.contentOffset = CGPoint(x: self.stationDataScroll.frame.width * CGFloat(self.headerTabButtons.index(of: sender)!), y: 0)
        }, completion: nil)
    }
    
    /*
    **  SCHEDULE DATA DISPLAY
    */
    
    //MARK: - INIT DISPLAY
    
    public func displayInit() {
        //Init pagination
        self.initPages()
        //Init schedules
        self.station.updateTimetable(completion: { (state: Bool) in
            if state == true {
                DisruptionData.getStationDisruptions(station: self.station, completion: {(disturbances: [(disruption: Disruption, lines: [Line])]) in
                    self.displayDisturbances(disturbances: disturbances)
                    self.displaySchedules()
                })
            }
        })
    }
    
    //MARK: - DISPLAY DISTURBANCES
    
    public func displayDisturbances(disturbances: [(disruption: Disruption, lines: [Line])]) {
        if disturbances.count == 0 { return }
        
        self.disturbancesPanel = UIView(frame: CGRect(x: 0, y: -300, width: Int(self.contentTamScroll!.frame.width), height: 304+(32+25)*disturbances.count))
        self.disturbancesPanel!.backgroundColor = UIColor(hex: "f39c12").withAlphaComponent(0.8)
        self.contentTamScroll!.addSubview(self.disturbancesPanel!)
        
        for i in 0..<disturbances.count {
            let disturbance = disturbances[i]
            
            //Icon and lines
            let icon = UIImageView(frame: CGRect(x: 15, y: 304+(28+4+25)*i, width: 28, height: 28))
            icon.image = #imageLiteral(resourceName: "round-error-symbol-white")
            self.disturbancesPanel!.addSubview(icon)
            for i2 in 0..<disturbance.lines.count {
                let line = disturbance.lines[i2]
                let lineLogo = UILineLogo(lineShortName: line.shortName, bgColor: UIColor.white.withAlphaComponent(0.8), fontColor: UIColor(hex: "f39c12"), type: line.type, at: CGPoint(x: 3+48*(i2+1), y: 304+(28+4+25)*i))
                self.disturbancesPanel?.addSubview(lineLogo.panel)
            }
            
            //Disruption title
            let disruptTitle = MarqueeLabel(frame: CGRect(x: 15, y: CGFloat(304+(28+4+25)*i+28), width: self.disturbancesPanel!.frame.width-30, height: 25), duration: 9.0, fadeLength: 6.0)
            let startDate = disturbance.disruption.startDate.split(separator: "-")
            let day = String(startDate[2])
            let endDayStartDateIndex = day.index(day.startIndex, offsetBy: 2)
            let date = day[..<endDayStartDateIndex] + "/" + String(startDate[1]) + "/" + String(startDate[0])
            disruptTitle.text = date + " : " + disturbance.disruption.title
            disruptTitle.textColor = .white
            disruptTitle.font = UIFont(name: "Ubuntu-Medium", size: 21)
            self.disturbancesPanel!.addSubview(disruptTitle)
            
        }
    }
    
    //MARK: - DISPLAY SCHEDULES
    
    public func displaySchedules() {
        
        let schedules = self.station.getShedulesByDirection()
        
        //Creating directions panel if null
        let disturbMaxY = self.disturbancesPanel == nil ? 0 : self.disturbancesPanel!.frame.maxY
        if self.directionsPanel == nil {
            self.directionsPanel = UIView(frame: CGRect(x: 0, y: disturbMaxY, width: self.contentTamScroll!.frame.width, height: 10))
            self.directionsPanel!.backgroundColor = .clear
            self.contentTamScroll!.addSubview(self.directionsPanel!)
        }
        
        //No schedules
        if (schedules.count == 0) {
            self.informationLabel!.frame.origin.y = disturbMaxY+5
            self.informationLabel!.text = NSLocalizedString("Service ended", comment: "")
        } else {
            self.informationLabel!.isHidden = true
        }
        
        //TODO: - when a direction disappear, need to remove it on UI.
        
        for i in 0..<schedules.count {
            let schedule = schedules[i]
            let selected = self.schedulesUI.filter({$0.schedules.line == schedule.line && $0.schedules.dest == schedule.dest})
            
            if selected.count > 0 {
                //Reorganise panel point
                selected[0].panel.frame.origin = CGPoint(x: 0, y: 10+(110*i))
                
                //Updating displayed schedule
                for i in 0..<3 {
                    let waitingTime = i >= schedule.times.count ? -1 : schedule.times[i]
                    
                    if waitingTime == -1 {
                        selected[0].timesUI[i].hideAll()
                    } else if waitingTime != selected[0].timesUI[i].waitingTime {
                        selected[0].timesUI[i].update(withWaitingTime: waitingTime)
                    }
                }
            } else {
                //Creating new direction
                addNewDirection(schedule: schedule)
            }
            
        }
        
    }
    
    //MARK: - SCHEDULES DESIGNER
    
    private func addNewDirection(schedule: (line: Line, dest: Stop, times: [Int])) {
        var scheduleUI: (schedules: (line: Line, dest: Stop, times: [Int]), panel: UIView, lineLogo: UILineLogo, destLabel: MarqueeLabel, timesUI: [UIMonoDirectionSchedule])
        scheduleUI.schedules = schedule
        
        //Panel
        let panel = UIView(frame: CGRect(x: 0, y: Int(self.directionsPanel!.frame.height), width: Int(self.directionsPanel!.frame.width), height: 110))
        panel.backgroundColor = .clear
        self.directionsPanel!.addSubview(panel)
        scheduleUI.panel = panel
        
        //Line logo
        let lineLogo = UILineLogo(lineShortName: schedule.line.shortName, bgColor: schedule.line.bgColor, fontColor: schedule.line.ftColor, type: schedule.line.type, at: CGPoint(x: 15, y: 0))
        panel.addSubview(lineLogo.panel)
        scheduleUI.lineLogo = lineLogo
        
        //Direction text
        let directionLabel = MarqueeLabel(frame: CGRect(x: 15+40+26, y: 0, width: Int(self.directionsPanel!.frame.width-(30+40+25)), height: 28), duration: 6.0, fadeLength: 3.0)
        directionLabel.text = schedule.dest.directionName.uppercased()
        directionLabel.textColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1.0)
        directionLabel.font = UIFont(name: "Ubuntu-Bold", size: 19)
        panel.addSubview(directionLabel)
        scheduleUI.destLabel = directionLabel
        
        //Schedules
        let schedulesWidth = Int((self.directionsPanel!.frame.width-15)/3)
        scheduleUI.timesUI = []
        for i in 0..<3 {
            let waitingTime = i >= schedule.times.count ? -1 : schedule.times[i]
            
            let timeUI = UIMonoDirectionSchedule(frame: CGRect(x: 15+schedulesWidth*i, y: 53, width: schedulesWidth, height: 25), waitingTime: waitingTime)
            if waitingTime == -1 {
                timeUI.hideAll()
            }
            panel.addSubview(timeUI)
            scheduleUI.timesUI.append(timeUI)
        }
        
        //Main container insets (direction panel and scroll view)
        self.directionsPanel!.frame.size = CGSize(width: self.directionsPanel!.frame.width, height: CGFloat(self.directionsPanel!.frame.height)+110)
        self.contentTamScroll!.contentSize = CGSize(width: self.contentTamScroll!.frame.width, height: CGFloat(61*self.disturbances.count)+self.directionsPanel!.frame.maxY)
        
        //Adding scheduleUI to schedulesUI (for updating without redrawing labels/view...)
        self.schedulesUI.append(scheduleUI)
    }
    
    //MARK: - ACTIONS BAR
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func clickFavoriteButton(_ sender: Any) {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()

        if !favoriteButton.isSelected {
            favoriteButton.isSelected = true
            haptic.prepare()
            haptic.selectionChanged()
            UserData.addFavStation(station: station)
        } else {
            favoriteButton.isSelected = false
            haptic.prepare()
            haptic.selectionChanged()
            UserData.removeFavStation(station: station)
        }
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
    
    //MARK: - APPEAR ANIMATION
    
    override func viewDidAppear(_ animated: Bool) {
        //Information label (waiting or finished service)
        MarqueeLabel.controllerLabelsLabelize(mainView)
        if (self.informationLabel == nil) {
            self.informationLabel = UILabel(frame: CGRect(x: 0, y: 5, width: self.stationDataScroll.frame.width, height: 25))
            self.informationLabel!.font = UIFont(name: "Ubuntu-Bold", size: 19.0)
            self.informationLabel!.textColor = .darkGray
            self.informationLabel!.textAlignment = .center
            self.informationLabel!.text = NSLocalizedString("...", comment: "")
            //UI Init
            self.displayInit()
            self.contentTamScroll!.addSubview(self.informationLabel!)
        }
        //Pop up appear
        self.appearAnimation()
        //Timer init
        self.refresher = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        super.viewDidAppear(animated)
    }
    
    private func appearAnimation()
    {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        
        haptic.prepare()
        haptic.selectionChanged()
        self.view.alpha = 0.0
        self.popUpCard.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurBackground.effect = self.effect
            self.view.alpha = 1.0
            self.popUpCard.transform = CGAffineTransform.identity
        })
    }
    
    //MARK: - DISAPPEAR ANIMATION

    @IBOutlet var blurClickAction: UITapGestureRecognizer!
    @IBAction func blurClick(_ sender: Any) {
        let loc = blurClickAction.location(in: blurBackground)
        
        if loc.x >= popUpCard.frame.minX && loc.x <= popUpCard.frame.maxX {
            if loc.y >= popUpCard.frame.minY && loc.y <= popUpCard.frame.maxY {
                return
            }
        }
        self.refresher.invalidate()
        self.refresher = nil
        MarqueeLabel.controllerLabelsAnimate(mainView)
        disappearAnimation()
    }
    
    private func disappearAnimation()
    {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        
        haptic.prepare()
        haptic.selectionChanged()
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpCard.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.view.alpha = 0
            self.blurBackground.effect = nil
        }) { (success:Bool) in
            self.dismiss(animated: false, completion: nil)
        }
    }
}
