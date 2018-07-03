//
//  ItineraryDetailViewViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 01/07/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel
import Mapbox

class ItineraryDetailViewController: UIViewController, UIGestureRecognizerDelegate, MGLMapViewDelegate {

    //MARK: - VARIABLES
    
    //UI
    
    @IBOutlet weak var headerTitleShadow: MarqueeLabel!
    @IBOutlet weak var headerTitle: MarqueeLabel!
    @IBOutlet weak var headerPanel: UIView!
    
    @IBOutlet weak var mapPanel: UIView!
    
    @IBOutlet weak var timeDepartureTitleLabel: UILabel!
    @IBOutlet weak var timeArrivalTitleLabel: UILabel!
    @IBOutlet weak var timeDepartureLabel: UILabel!
    @IBOutlet weak var timeArrivalLabel: UILabel!
    @IBOutlet weak var timeDurationLabel: UILabel!
    @IBOutlet weak var timeDurationUnitLabel: UILabel!
    
    @IBOutlet weak var itineraryScrollView: UIScrollView!
    
    //Globals
    
    var trip: Trip
    var departureLocation: MPLLocation?
    var destinationLocation: MPLLocation?
    var mapView: MGLMapView?
    
    //MARK: - INITIALIZATION
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, trip: Trip, departure: MPLLocation?, destination: MPLLocation?) {
        self.trip = trip
        self.departureLocation = departure
        self.destinationLocation = destination
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI INITIALIZATION
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Navigation
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //setting header color
        var segment: TripSegment?
        for _segment in self.trip.segments {
            if segment == nil || _segment.intermediateStops.count > segment!.intermediateStops.count {
                if _segment.mode == .BUS || _segment.mode == .TRAMWAY {
                    segment = _segment
                }
            }
        }
        if segment != nil && segment!.line != nil {
            self.headerPanel.backgroundColor = segment!.line!.bgColor
        }
        
        //setting title
        if departureLocation != nil && destinationLocation != nil {
            self.headerTitle.text = departureLocation!.name.uppercased() + " • " + destinationLocation!.name.uppercased()
            self.headerTitleShadow.text = departureLocation!.name.uppercased() + " • " + destinationLocation!.name.uppercased()
        }
        
        //setting map
        self.mapView = MGLMapView(frame: self.mapPanel.bounds, styleURL: MGLStyle.lightStyleURL())
        mapView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView!.setCenter(CLLocationCoordinate2D(latitude: 43.610769, longitude: 3.876716), zoomLevel: 12.5, animated: false)
        mapView!.showsUserLocation = true
        mapView!.delegate = self
        mapView!.minimumZoomLevel = 10
        mapView!.maximumZoomLevel = 18
        self.mapPanel.addSubview(mapView!)
        
        //time panel
        self.timeDepartureTitleLabel.text = NSLocalizedString("departure", comment: "")
        self.timeArrivalTitleLabel.text = NSLocalizedString("arrival", comment: "")
        self.timeDurationUnitLabel.text = NSLocalizedString("mins", comment: "")
        
        if self.trip.departureTime.getMinsFromNow() > 1400 || trip.departureTime.getMinsFromNow() <= 1 {
            self.timeDepartureLabel.text = NSLocalizedString("now", comment: "")
        } else {
            self.timeDepartureLabel.text = NSLocalizedString("%Hh%M", comment: "").replacingOccurrences(of: "%H", with: "\(self.trip.departureTime.hours)").replacingOccurrences(of: "%M", with: self.trip.departureTime.mins < 10 ? "0\(self.trip.departureTime.mins)" : "\(self.trip.departureTime.mins)")
        }
         self.timeArrivalLabel.text = NSLocalizedString("%Hh%M", comment: "").replacingOccurrences(of: "%H", with: "\(self.trip.arrivalTime.hours)").replacingOccurrences(of: "%M", with: self.trip.arrivalTime.mins < 10 ? "0\(self.trip.arrivalTime.mins)" : "\(self.trip.arrivalTime.mins)")
        self.timeDurationLabel.text = String(trip.duration)
        
        //displaying trip
        let visualItinerary = UIItinerary.init(self.trip, at: CGPoint(x: 0, y: 0), width: UIScreen.main.bounds.width)
        self.itineraryScrollView.addSubview(visualItinerary)
        self.itineraryScrollView.contentSize = CGSize(width: visualItinerary.frame.width, height: visualItinerary.frame.height)
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if self.mapView != nil {
            MapData.addLayer(of: self.trip, on: self.mapView!, cameraEdgePadding: nil)
        }
    }
    
    //MARK: - CLICKING BACK BUTTON
    
    @IBAction func clickingBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - STATUS BAR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
