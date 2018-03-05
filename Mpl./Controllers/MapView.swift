//
//  MapView.swift
//  Mpl.
//
//  Created by Darius Martin on 23/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import Mapbox

class MapView: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var header: UIAdvanced!
    @IBOutlet weak var mapBack: UIView!
    
    let gradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientTopColor = UIColor.init(red: 254.0/255.0, green: 106.0/255, blue: 166.0/255.0, alpha: 1.0)
        let gradientBotColor = UIColor.init(red: 235.0/255.0, green: 61.0/255, blue: 145.0/255.0, alpha: 1.0)
        
        //Change header height percentage
        header.frame = CGRect(x: header.frame.minX, y: header.frame.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.22)
        
        //Map
        let url = URL(string: "mapbox://styles/slaymd/cjdj47fr31ex32sqp8dy4h9m7")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 43.610769, longitude: 3.876716), zoomLevel: 11, animated: false)
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        //Creating header gradient
        header.backgroundColor = gradientBotColor
        gradient.frame = header.bounds
        gradient.colors = [gradientTopColor.cgColor, gradientBotColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        header.layer.insertSublayer(gradient, at: 0)
        self.view.addSubview(header)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
