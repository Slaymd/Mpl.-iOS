//
//  HomeView.swift
//  Mpl.
//
//  Created by Darius Martin on 23/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationBannerSwift
import MarqueeLabel

class HomeView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var mainController: MainScrollView? = nil

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerWelcomeLabel: UILabel!
    @IBOutlet weak var headerLightNameLabel: UILabel!
    @IBOutlet weak var headerShadowNameLabel: UILabel!
    @IBOutlet weak var favStationHeaderLabel: UILabel!
    
    @IBOutlet weak var stationCollectionView: UICollectionView!
    let cellIdentifier = "favstation"
    
    var refresher: Timer!
    
    var favStations: [StopZone] = []
    //var favStationsCards: [UIStationCard] = [UIStationCard]()
    
    let gradient = CAGradientLayer()
    
    // STATION COLLECTION VIEW
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favStations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Getting station
        let station = favStations[indexPath.item]
        //Getting cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HomeStationCollectionViewCell
        
        //Fill cell
        if cell.station == nil || cell.station!.id != station.id {
            cell.fill(station, fromView: self)
        }
        cell.updateDisplayedArrivals()
        
        return cell
    }
    
    //CONTEXTUAL MENU
    
    func dispContextualMenu(station: StopZone) {
        let haptic: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator()
        
        haptic.prepare()
        haptic.impactOccurred()
        let alert = UIAlertController(title: "Station : \(station.name)", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { _ in
            UserData.removeFavStation(station: station)
            self.update()
        }))
        alert.addAction(UIAlertAction(title: "Plus d'informations", style: .default, handler: { _ in
            let stationPopUp: StationPopUpView = StationPopUpView.init(nibName: "StationPopUpView", bundle: nil, station: station, mainView: self)
            stationPopUp.modalPresentationStyle = .overCurrentContext
            self.present(stationPopUp, animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "S'y rendre", style: .default, handler: { _ in
            let banner = NotificationBanner(title: "S'y rendre", subtitle: "Bientôt disponible.", style: .info)
            banner.haptic = .light
            banner.show()
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Appear event
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresher.invalidate()
        self.refresher = nil
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        update()
    }
    
    //MARK: refresher
    
    @objc func update() {
        var newFavStations: [StopZone]
        var userLocation: CLLocation? = nil
        
        //User location
        if self.mainController == nil { return }
        if self.mainController?.userLocation != nil { userLocation = self.mainController?.userLocation}
        
        //Getting fav stations by location
        newFavStations = userLocation != nil ? UserData.getFavStationsByLocation(refLocation: userLocation!) : UserData.getFavStations()
        
        if self.favStations != newFavStations {
            self.stationCollectionView.reloadData()
        } else {
            for i in 0..<newFavStations.count {
                //Update station
                newFavStations[i].updateTimetable(completion: { (result: Bool) in
                    if result == true {
                        if newFavStations[i].needDisplayUpdate == 1 {
                            newFavStations[i].needDisplayUpdate = 0
                            let cell = self.stationCollectionView.cellForItem(at: IndexPath.init(item: i, section: 0)) as? HomeStationCollectionViewCell
                            
                            if (cell != nil) {
                                cell!.updateDisplayedArrivals()
                            }
                        }
                    }
                })
                
            }
        }
        
        favStations = newFavStations
    }
    
    //View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainHeader: UIView
        
        if (mainController == nil) { return }
        mainHeader = mainController!.header
        //let gradientTopColor = UIColor.init(red: 51.0/255.0, green: 206.0/255, blue: 255.0/255.0, alpha: 1.0)
        //let gradientBotColor = UIColor.init(red: 11.0/255.0, green: 173.0/255, blue: 254.0/255.0, alpha: 1.0)
        //Favorite stations
        stationCollectionView.frame = CGRect(x: 0, y: mainHeader.frame.maxY+40, width: stationCollectionView.frame.width, height: stationCollectionView.frame.height)
        favStationHeaderLabel.frame = CGRect(x: 16, y: mainHeader.frame.maxY+50, width: stationCollectionView.frame.width, height: 20)
        
        favStationHeaderLabel.text = NSLocalizedString("Favorite stations", comment: "")
        
        //Station Collection
        self.stationCollectionView.register(UINib(nibName:"HomeStationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        self.stationCollectionView.delegate = self
        self.stationCollectionView.dataSource = self
        
        //Refresher
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        //Background state event
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        //self.view.backgroundColor = UIColor.concreteGray
        //self.view.backgroundColor = ColorManager.getColor(color: UIColor.concreteGray, dark: true)
    }
    
    //MARK: - BACKGROUND STATE
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        //return;
        self.refresher?.invalidate()
        self.refresher = nil
        MarqueeLabel.controllerLabelsLabelize(self)
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        //return;
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        self.update()
        MarqueeLabel.controllerLabelsAnimate(self)
    }

}
