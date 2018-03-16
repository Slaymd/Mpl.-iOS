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
            ViewMaker.createStationPopUpFromHome(view: self, station: station)
        }))
        alert.addAction(UIAlertAction(title: "S'y rendre", style: .default, handler: { _ in
            let banner = NotificationBanner(title: "S'y rendre", subtitle: "Bientôt disponible.", style: .info)
            banner.haptic = .light
            banner.show()
            /*let researchView: ResearcherViewController = ResearcherViewController(nibName: "ResearcherViewController", bundle: nil)
            self.present(researchView, animated: true, completion: nil)*/
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Appear event
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresher.invalidate()
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        update()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.update()
        }
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
                newFavStations[i].updateTimetable()
                if newFavStations[i].needDisplayUpdate == 1 {
                    newFavStations[i].needDisplayUpdate = 0
                    let cell = self.stationCollectionView.cellForItem(at: IndexPath.init(item: i, section: 0)) as? HomeStationCollectionViewCell
                    
                    if (cell == nil) { continue }
                    cell!.updateDisplayedArrivals()
                }
            }
        }
        
        favStations = newFavStations
        /*if Set<StopZone>(favStations) == Set<StopZone>(newFavStations) {
            
        }*/
        
        //Timetable update
        /*var newFavStations: [StopZone]
        var userLocation: CLLocation? = nil
        
        //User location
        if self.mainController == nil { return }
        if self.mainController?.userLocation != nil { userLocation = self.mainController?.userLocation}
        
        //Getting fav stations by location
        newFavStations = userLocation != nil ? UserData.getFavStationsByLocation(refLocation: userLocation!) : UserData.getFavStations()
        */
        //set view elemts
        /*self.stationCollectionView.reloadInputViews()
        self.stationCollectionView.reloadData()
        favStationScrollView.contentSize = CGSize(width: newFavStations.count*265+15, height: 100)
        for i in 0..<newFavStations.count {
            let nextarrivals: Bool = favStationsCards.count-1 >= i && favStationsCards[i].station == newFavStations[i] && favStationsCards[i].nextSchedules.count > 0 && favStationsCards[i].nextSchedules[0] == favStations[i].timetable.schedules[0].date.getMinsFromNow() ? true : false
            if !(favStationsCards.count-1 >= i && favStationsCards[i].station == newFavStations[i]) || nextarrivals == false {
                if i < favStationsCards.count {
                    for view in favStationsCards[i].card.subviews {
                        view.removeFromSuperview()
                    }
                    favStationsCards[i].card.removeFromSuperview()
                    favStationsCards.remove(at: i)
                }
                newFavStations[i].updateTimetable()
                let timetable = newFavStations[i].timetable
                
                timetable.sortSchedules()
                favStationsCards.insert(UIStationCard(x: CGFloat(16+(250*i+15*i)), y: 45, station: newFavStations[i]), at: i)
                let click = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLittlePress(sender:)))
                longPressRecognizer.minimumPressDuration = 0.1;
                favStationsCards[i].card.addGestureRecognizer(click)
                favStationsCards[i].card.addGestureRecognizer(longPressRecognizer)
                self.favStationScrollView.addSubview(favStationsCards[i].card)
            }
        }
        if newFavStations.count < favStationsCards.count {
            for i in newFavStations.count..<favStationsCards.count {
                for view in favStationsCards[i].card.subviews {
                    view.removeFromSuperview()
                }
                favStationsCards[i].card.removeFromSuperview()
                favStationsCards.remove(at: i)
            }
        }
        favStations = newFavStations*/
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
        
        //Station Collection
        self.stationCollectionView.register(UINib(nibName:"HomeStationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        self.stationCollectionView.delegate = self
        self.stationCollectionView.dataSource = self
        
        //Refresher
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    /*@objc func handleTap(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: favStationScrollView)
        var station: StopZone!
        //Getting station from X, Y
        for i in 0..<favStationsCards.count {
            if loc.x >= favStationsCards[i].card.frame.minX && loc.x <= favStationsCards[i].card.frame.maxX {
                station = favStations[i]
            }
        }
        //Displaying station pop-up
        ViewMaker.createStationPopUpFromHome(view: self, station: station)
    }
    
    @objc func handleLittlePress(sender: UILongPressGestureRecognizer) {
        let loc = sender.location(in: favStationScrollView)
        var station: UIStationCard? = nil
        //Getting station from X, Y
        for i in 0..<favStationsCards.count {
            if loc.x >= favStationsCards[i].card.frame.minX && loc.x <= favStationsCards[i].card.frame.maxX {
                station = favStationsCards[i]
            }
        }
        //Animation
        if (station == nil) { return }
        if sender.state == .began {
            station!.evt_startpress = Date.timeIntervalSinceReferenceDate
            station!.longPressAnimationStart()
        } else if sender.state == .ended {
            if (station!.evt_startpress != nil) {
                //Si le doigt n'a pas été déplacé sur une autre station
                let duration = Date.timeIntervalSinceReferenceDate - station!.evt_startpress!
                station!.longPressAnimationClose()
                station!.evt_startpress = nil
                if duration >= 0.4 {
                    station!.dispContextualMenu(viewController: self)
                } else {
                    ViewMaker.createStationPopUpFromHome(view: self, station: station!.station)
                }
            } else {
                //Doigt déplacé, reset toutes les cartes.
                for stationCard in favStationsCards {
                    if (stationCard.evt_startpress != nil) {
                        stationCard.longPressAnimationClose()
                        stationCard.evt_startpress = nil
                    }
                }
            }
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
