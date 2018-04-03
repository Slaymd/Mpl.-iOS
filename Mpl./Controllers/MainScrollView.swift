//
//  MainScrollView.swift
//  Mpl.
//
//  Created by Darius Martin on 23/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import CoreLocation
import MarqueeLabel

class MainScrollView: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    var isScrolling: Bool = false
    
    //Location
    let locManager = CLLocationManager()
    var userLocation: CLLocation? = nil
    
    //Sub controllers
    var homeController: HomeView?
    var mapController: MapView?

    //Header
    @IBOutlet weak var header: UIAdvanced!
    @IBOutlet weak var headerWelcomeLabel: UILabel!
    @IBOutlet weak var headerLightNameLabel: UILabel!
    @IBOutlet weak var headerShadowNameLabel: UILabel!
    //Other
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hamburger: UIButton!
    //Navigation bar
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    //Station researcher click
    
    @IBAction func stationResearcherClick(_ sender: Any) {
        let researchView: ResearcherViewController = ResearcherViewController.init(nibName: "ResearcherViewController", bundle: nil, mainScrollView: self)
        self.navigationController?.pushViewController(researchView, animated: true)
    }
    
    
    //View did load

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Scroll view fill the entire screen
        scrollView.frame = self.view.frame
        
        //Scrollview and keyboard dismiss
        //scrollView.keyboardDismissMode = .onDrag
        scrollView.keyboardDismissMode = .interactive
        
        //Change header height percentage
        header.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 3, height: UIScreen.main.bounds.height*0.22)
        
        //set other app page (home page, itinary page...)
        let userView: UserView = UserView(nibName: "UserView", bundle: nil)
        let homeView: HomeView = HomeView(nibName: "HomeView", bundle: nil)
        let mapView: MapView = MapView(nibName: "MapView", bundle: nil)
        userView.view.frame = self.view.frame
        userView.viewDidLoad()
        userView.mainController = self
        homeView.view.frame = self.view.frame
        homeView.mainController = self
        self.homeController = homeView
        homeView.viewDidLoad()
        mapView.view.frame = self.view.frame
        mapView.viewDidLoad()
        self.mapController = mapView
        
        self.addChildViewController(homeView)
        self.scrollView.addSubview(homeView.view)
        homeView.didMove(toParentViewController: self)
        
        self.addChildViewController(userView)
        self.scrollView.addSubview(userView.view)
        userView.didMove(toParentViewController: self)
        
        self.addChildViewController(mapView)
        self.scrollView.addSubview(mapView.view)
        mapView.didMove(toParentViewController: self)
        
        var homeViewFrame = homeView.view.frame
        homeViewFrame.origin.x = homeView.view.frame.width
        homeView.view.frame = homeViewFrame
        
        var mapViewFrame = mapView.view.frame
        mapViewFrame.origin.x = homeView.view.frame.width * 2
        mapView.view.frame = mapViewFrame
        
        scrollView.addSubview(hamburger)
        scrollView.addSubview(header)
        header.addSubview(headerWelcomeLabel)
        header.addSubview(headerShadowNameLabel)
        header.addSubview(headerLightNameLabel)
        
        self.scrollView.contentOffset = CGPoint(x: homeView.view.frame.width, y: 0)
        self.scrollView.contentSize = CGSize(width: homeView.view.frame.width * 3, height: homeView.view.frame.height)
        self.scrollView.delegate = self
        
        //layouts
        hamburger.frame = CGRect(x: self.scrollView.contentOffset.x + hamburger.frame.minX, y: header.frame.maxY+43, width: hamburger.frame.width, height: hamburger.frame.height)
        //Label position
        headerLightNameLabel.frame = CGRect(x: self.view.frame.width+12, y: header.frame.maxY-45, width: self.view.frame.width-20, height: headerLightNameLabel.frame.height)
        headerShadowNameLabel.frame = CGRect(x: self.view.frame.width+16, y: header.frame.maxY-42, width: self.view.frame.width-20, height: headerLightNameLabel.frame.height)
        headerWelcomeLabel.frame = CGRect(x: self.view.frame.width+14, y: header.frame.maxY-62, width: self.view.frame.width-20, height: 15)
        
        //Setting displayed name
        self.headerWelcomeLabel.text = NSLocalizedString("welcome", comment: "")
        updateDisplayedUserName()
        
        //Request location
        locManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
            homeController?.update()
        }
    }
    
    func updateDisplayedUserName() {
        headerLightNameLabel.text = UserData.displayedName.uppercased()
        headerShadowNameLabel.text = UserData.displayedName.uppercased()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pct: Int = Int(scrollView.contentOffset.x / self.view.frame.width * 100)

        if pct >= 100 {
            let fromColor = UIColor(red: 26/255, green: 186/255, blue: 254/255, alpha: 1)
            let toColor = UIColor.init(red: 235.0/255.0, green: 61.0/255, blue: 145.0/255.0, alpha: 1.0)
            let opacity = (CGFloat(pct)-100)/50-1
            header.backgroundColor = UIColor.init(red: fromColor.cgColor.components![0] + ((toColor.cgColor.components![0] - fromColor.cgColor.components![0])/100)*(CGFloat(pct)-100), green: fromColor.cgColor.components![1] + ((toColor.cgColor.components![1] - fromColor.cgColor.components![1])/100)*(CGFloat(pct)-100), blue: fromColor.cgColor.components![2] + ((toColor.cgColor.components![2] - fromColor.cgColor.components![2])/100)*(CGFloat(pct)-100), alpha: 1)
            if opacity < 0 {
                headerWelcomeLabel.alpha = abs(opacity)
                headerShadowNameLabel.alpha = abs(opacity)
                headerLightNameLabel.alpha = abs(opacity)
            }
        } else {
            
        }
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
