//
//  LocationFinderPopUpViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 17/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationBannerSwift

enum MPLLocationType {
    case station
    case geocoords
}

class MPLLocation {
    
    var type: MPLLocationType
    var data: Any
    var name: String
    
    init(type: MPLLocationType, data: Any, name: String) {
        self.type = type
        self.data = data
        self.name = name
    }
    
    convenience init(station: StopZone) {
        self.init(type: .station, data: station, name: station.name)
    }
    
    convenience init(location: CLLocation, name: String) {
        self.init(type: .geocoords, data: location, name: name)
    }
    
}

class LocationFinderPopUpViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    //MARK: - VARIABLES
    
    //UI
    
    @IBOutlet weak var blurBackground: UIVisualEffectView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultScrollView: UIScrollView!
    @IBOutlet weak var myPositionCard: UIView!
    @IBOutlet weak var myPositionLabel: UILabel!
    
    //Constraints
    
    @IBOutlet weak var bottomResultScrollViewConstraint: NSLayoutConstraint!

    //GLOBAL
    
    var effect: UIVisualEffect?
    var lastFilteredStations: [StopZone] = []
    var stationCards: [UILightStationCard] = []
    var resultLocation: MPLLocation?
    var mainView: UIViewController
    var id: Int
    let locationManager = CLLocationManager()
    var userLocation: CLLocation? = nil
    
    //MARK: - INITS
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, id: Int, mainView: UIViewController) {
        self.mainView = mainView
        self.id = id
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
        self.searchTextField.delegate = self
        
        //Tap recognisers
        let tap = UITapGestureRecognizer(target: self, action: #selector(blurClick(sender:)))
        self.blurBackground.addGestureRecognizer(tap)
        let positionTap = UITapGestureRecognizer(target: self, action: #selector(handleMyPositionTap(sender:)))
        self.myPositionCard.addGestureRecognizer(positionTap)
        
        //UI improvements
        
        self.headerView.layer.cornerRadius = 10
        self.headerView.layer.shadowColor = UIColor.black.cgColor
        self.headerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.headerView.layer.shadowRadius = 10
        self.headerView.layer.shadowOpacity = 0.5
        self.myPositionCard.layer.cornerRadius = 15
        self.myPositionLabel.text = NSLocalizedString("My Position", comment: "")
        
        //Observer when keyboard is opened to get its size.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        //User location
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: - LOCATION MANAGER
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first { userLocation = location }
    }
    
    //MARK: - EDITING TEXTFIELD
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str = searchTextField.text
        let endindex = str!.index(str!.endIndex, offsetBy: range.length * -1)
        
        str = String(str![..<endindex])
        if (string.count > 1) { return true }
        if (str == nil) { str = string } else { str!.append(string) }
        str = str!.toASCII().lowercased()
        if (str!.count > 2) {
            //Hide main controls
            for view in self.resultScrollView.subviews {
                if view.tag < 0 {
                    view.isHidden = true
                }
            }
            //Display
            self.lastFilteredStations = getStationListFiltered(byName: str!.replacingOccurrences(of: "-", with: " "))
            updateStationList(with: self.lastFilteredStations)
        } else {
            //Clear
            for view in self.resultScrollView.subviews {
                if view.tag >= 0 {
                    view.removeFromSuperview()
                } else { view.isHidden = false } }
        }
        return true
    }
    
    //MARK: - GET STATIONS LIST BY STRING
    
    func getStationListFiltered(byName name: String) -> [StopZone] {
        var filteredStations: [StopZone] = []
        
        //Filter each stations with good name
        filteredStations = TransportData.stopZones.filter({$0.name.toASCII().lowercased().replacingOccurrences(of: "-", with: " ").contains(name)})
        //Sort by number of lines
        filteredStations.sort(by: {($0.getLines().count > 0 && $1.getLines().count > 0) && $0.getLines()[0].tamId < $1.getLines()[0].tamId})
        filteredStations.sort(by: {$0.getLines().count > $1.getLines().count})
        filteredStations.sort(by: {$0.lines.filter({$0.type == .TRAMWAY}).count > $1.lines.filter({$0.type == .TRAMWAY}).count})
        updateStationList(with: filteredStations)
        return filteredStations
    }
    
    //MARK: - DISP STATION LIST
    
    func updateStationList(with stations: [StopZone]) {
        var y = 10;
        var stationCard: UILightStationCard
        var tap: UITapGestureRecognizer
        
        //Clear displayed stations
        for view in self.resultScrollView.subviews {
            if view.tag >= 0 { view.removeFromSuperview() }
        }
        self.stationCards.removeAll()
        //Display new station list
        for i in 0..<stations.count {
            stationCard = UILightStationCard(frame: CGRect(x: 0, y: y, width: Int(self.resultScrollView.frame.width), height: 50), station: stations[i], distance: 1000)
            y += Int(stationCard.frame.height)+15
            tap = UITapGestureRecognizer(target: self, action: #selector(handleStationTap(sender:)))
            stationCard.addGestureRecognizer(tap)
            self.stationCards.append(stationCard)
            self.resultScrollView.addSubview(stationCard)
            self.resultScrollView.contentSize = CGSize(width: Int(self.resultScrollView.frame.width), height: y)
        }
    }
    
    //MARK: - CLICKING ON STATION CARD
    
    @objc func handleStationTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.resultScrollView)
        
        for stationCard in self.stationCards {
            if clickLoc.x < stationCard.frame.minX || clickLoc.x > stationCard.frame.maxX { continue }
            if clickLoc.y < stationCard.frame.minY || clickLoc.y > stationCard.frame.maxY { continue }
            
            self.resultLocation = MPLLocation(station: stationCard.station)
            self.disappearAnimation()
            break
        }
    }
    
    @objc func handleMyPositionTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.resultScrollView)

        if clickLoc.x < myPositionCard.frame.minX || clickLoc.x > myPositionCard.frame.maxX { return }
        if clickLoc.y < myPositionCard.frame.minY || clickLoc.y > myPositionCard.frame.maxY { return }
        if self.userLocation != nil {
            self.resultLocation = MPLLocation(location: self.userLocation!, name: NSLocalizedString("My Position", comment: ""))
        } else {
            let banner = NotificationBanner(title: NSLocalizedString("My Position", comment: ""), subtitle: NSLocalizedString("Turn on localization to use \"My Position\" feature", comment: ""), style: .warning)
            banner.haptic = .medium
            banner.show()
        }
        self.disappearAnimation()
    }
    
    //MARK: - GETTING KEYBOARD HEIGHT
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.bottomResultScrollViewConstraint.constant = keyboardRectangle.height
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - APPEAR ANIMATION
    
    override func viewDidAppear(_ animated: Bool) {
        self.appearAnimation()
    }
    
    private func appearAnimation() {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        
        haptic.prepare()
        haptic.selectionChanged()
        self.view.alpha = 0.0
        
        self.headerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.resultScrollView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.2, animations: {
            self.blurBackground.effect = self.effect
            self.view.alpha = 1.0
            self.headerView.transform = CGAffineTransform.identity
            self.resultScrollView.transform = CGAffineTransform.identity
            //Keyboard load
            self.searchTextField.becomeFirstResponder()
        })
    }
    
    //MARK: - DISAPPEAR ANIMATION
    
    @objc func blurClick(sender: UITapGestureRecognizer) {
        disappearAnimation()
    }
    
    private func disappearAnimation()
    {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        
        haptic.prepare()
        haptic.selectionChanged()
        self.view.endEditing(true)
        self.mainView.viewWillAppear(false)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
            self.blurBackground.effect = nil
            self.headerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (success:Bool) in
            self.dismiss(animated: false, completion: nil)
        }
    }

}
