//
//  ItinerariesOverviewViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 17/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import Mapbox
import NotificationBannerSwift

class ItinerariesOverviewViewController: UIViewController, UIGestureRecognizerDelegate, MGLMapViewDelegate, UIScrollViewDelegate {
    
    //MARK: - VARIABLES
    
    //UI
    
    @IBOutlet weak var headerTitleShadow: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var departurePanel: UIView!
    @IBOutlet weak var arrivalPanel: UIView!
    @IBOutlet weak var mapViewPanel: UIView!
    @IBOutlet weak var itinerariesScrollView: UIScrollView!
    
    @IBOutlet weak var arrivalButton: UIButton!
    @IBOutlet weak var departureButton: UIButton!
    
    //Global
    
    var lastLocationFinderPopUp: LocationFinderPopUpViewController?
    
    var departureLocation: MPLLocation?
    var arrivalLocation: MPLLocation?
    
    var mapView: MGLMapView?
    var mapDisplayedTrip: Trip?
    
    var displayedTripCards: [UITripCard] = []
    
    convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, departure: MPLLocation?, arrival: MPLLocation?) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.departureLocation = departure
        self.arrivalLocation = arrival
    }
    
    //MARK: - LOAD UI

    override func viewDidLoad() {
        super.viewDidLoad()

        //Additional UI
        departurePanel.layer.cornerRadius = 10
        arrivalPanel.layer.cornerRadius = 10
        self.arrivalButton.tag = 42
        self.departureButton.tag = 84
        updateMainButtons()
        self.headerTitle.text = NSLocalizedString("Itinerary", comment: "").uppercased()
        self.headerTitleShadow.text = NSLocalizedString("Itinerary", comment: "").uppercased()
        
        //Navigation
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //Map load
        self.mapView = MGLMapView(frame: self.mapViewPanel.bounds, styleURL: MGLStyle.lightStyleURL())
        mapView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView!.setCenter(CLLocationCoordinate2D(latitude: 43.610769, longitude: 3.876716), zoomLevel: 12.5, animated: false)
        mapView!.showsUserLocation = true
        mapView!.delegate = self
        mapView!.minimumZoomLevel = 10
        mapView!.maximumZoomLevel = 18
        self.mapViewPanel.addSubview(mapView!)
        self.mapViewPanel.addSubview(self.itinerariesScrollView)
        
        //Scroll view delegate
        self.itinerariesScrollView.delegate = self
    }
    
    //MARK: - UPDATE ITINERARIES BUTTON TEXT
    
    func updateMainButtons() {
        if departureLocation == nil {
            self.departureButton.setTitle(NSLocalizedString("Type your departure", comment: ""), for: .normal)
        } else {
            self.departureButton.setTitle(self.departureLocation!.name, for: .normal)
        }
        if arrivalButton == nil {
            self.departureButton.setTitle(NSLocalizedString("Type your arrival", comment: ""), for: .normal)
        } else {
            self.arrivalButton.setTitle(self.arrivalLocation!.name, for: .normal)
        }
        //Clear trips
        for view in self.itinerariesScrollView.subviews {
            view.removeFromSuperview()
        }
        //Getting itinaries
        if (arrivalLocation != nil && departureLocation != nil) {
            ItinerariesData.get(from: departureLocation!, to: arrivalLocation!) { (result) in
                self.displayTrips(trips: result)
            }
        }
    }
    
    //MARK: - SETTINGS ITINERARIES PROPOSITIONS
    
    func displayTrips(trips: [Trip]) {
        //No trips found
        if trips.count == 0 {
            let banner = NotificationBanner(title: NSLocalizedString("No itineraries found", comment: ""), subtitle: NSLocalizedString("Please try another locations or try again later", comment: ""), style: .danger)
            banner.haptic = .medium
            banner.show()
            return
        }
        //Clear trips
        for view in self.itinerariesScrollView.subviews {
            view.removeFromSuperview()
        }
        self.displayedTripCards.removeAll()
        self.clearTripsLayers()
        
        //display new
        var x = 15
        for trip in trips {
            let UITrip = UITripCard(frame: CGRect(x: x, y: 0, width: 275, height: Int(self.itinerariesScrollView.frame.height)), trip: trip)
            let tap = UITapGestureRecognizer(target: self, action: #selector(itineraryTap(sender:)))
            UITrip.addGestureRecognizer(tap)
            self.itinerariesScrollView.addSubview(UITrip)
            x += Int(UITrip.frame.width) + 15
            self.itinerariesScrollView.contentSize = CGSize(width: x, height: Int(self.itinerariesScrollView.frame.height))
            self.displayedTripCards.append(UITrip)
        }
        self.updateDisplayedItinerary()
    }
    
    //MARK: - TRIPS ON MAP
    
    func clearTripsLayers() {
        guard let mapStyle = self.mapView?.style else { return }
        for layer in mapStyle.layers {
            if layer.identifier.starts(with: "trip") {
                mapStyle.removeLayer(layer)
            }
        }
        for source in mapStyle.sources {
            if source.identifier.starts(with: "trip") {
                mapStyle.removeSource(source)
            }
        }
        self.mapDisplayedTrip = nil
    }
    
    func displayTripOnMap(_ trip: Trip) {
        self.mapDisplayedTrip = trip
        if self.mapView != nil {
            MapData.addLayer(of: trip, on: self.mapView!, cameraEdgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 125, right: 10))
        }
    }
    
    //MARK: - SCROLLING ITINERARIES PROPOSITIONS
    
    
    private func updateDisplayedItinerary() {
        let offset = self.itinerariesScrollView.contentOffset
        
        for card in self.displayedTripCards {
            if offset.x + self.itinerariesScrollView.frame.width/2.5 < card.frame.maxX {
                if self.mapDisplayedTrip == nil || card.trip != self.mapDisplayedTrip! {
                    self.clearTripsLayers()
                    self.displayTripOnMap(card.trip)
                    for othercard in self.displayedTripCards {
                        if othercard.trip != card.trip {
                            othercard.alpha = 0.8
                        } else {
                            othercard.alpha = 1.0
                        }
                    }
                    break
                }
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateDisplayedItinerary()
    }
    
    //MARK: - CLICKING ITINERARY PROPOSITION
    
    @objc func itineraryTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.itinerariesScrollView)
        
        for tripCard in self.displayedTripCards {
            if clickLoc.x < tripCard.frame.minX || clickLoc.x > tripCard.frame.maxX { continue }
            if clickLoc.y < tripCard.frame.minY || clickLoc.y > tripCard.frame.maxY { continue }
            
            let itineraryDetailView = ItineraryDetailViewController(nibName: "ItineraryDetailView", bundle: nil, trip: tripCard.trip, departure: self.departureLocation, destination: self.arrivalLocation)
            self.navigationController?.pushViewController(itineraryDetailView, animated: true)
            break
        }
    }
    
    //MARK: - CLICKING ITINERARIES CONSTRUCTOR
    
    @IBAction func clickingDepartureConstructor(_ sender: Any) {
        let locationPopUp: LocationFinderPopUpViewController = LocationFinderPopUpViewController.init(nibName: "LocationFinderPopUpView", bundle: nil, id: 84,  mainView: self)
        locationPopUp.modalPresentationStyle = .overCurrentContext
        self.present(locationPopUp, animated: false, completion: nil)
        self.lastLocationFinderPopUp = locationPopUp
    }
    
    @IBAction func clickingArrivalConstructor(_ sender: Any) {
        let locationPopUp: LocationFinderPopUpViewController = LocationFinderPopUpViewController.init(nibName: "LocationFinderPopUpView", bundle: nil, id: 42,  mainView: self)
        locationPopUp.modalPresentationStyle = .overCurrentContext
        self.present(locationPopUp, animated: false, completion: nil)
        self.lastLocationFinderPopUp = locationPopUp
    }
    
    //MARK: - FINISHING WITH LOCATION FINDER POPUP
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.lastLocationFinderPopUp == nil { return }
        guard let resultLocation = self.lastLocationFinderPopUp!.resultLocation else { return }
        let tag = self.lastLocationFinderPopUp!.id
        
        if self.departureButton.tag == tag {
            self.departureLocation = resultLocation
        } else {
            self.arrivalLocation = resultLocation
        }
        updateMainButtons()
        self.lastLocationFinderPopUp = nil
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
