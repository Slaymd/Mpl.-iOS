//
//  ItinerariesOverviewViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 17/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class ItinerariesOverviewViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - VARIABLES
    
    //UI
    
    @IBOutlet weak var headerTitleShadow: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var departurePanel: UIView!
    @IBOutlet weak var arrivalPanel: UIView!
    
    @IBOutlet weak var arrivalButton: UIButton!
    @IBOutlet weak var departureButton: UIButton!
    
    //Global
    
    var lastLocationFinderPopUp: LocationFinderPopUpViewController?
    
    var departureLocation: MPLLocation?
    var arrivalLocation: MPLLocation?
    
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
        
        //Base location
        self.arrivalButton.setTitle(arrivalLocation != nil ? arrivalLocation!.name : "Entrez votre destination", for: .normal)
        
        //Navigation
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
        let button: UIButton
        
        if self.departureButton.tag == tag { button = self.departureButton } else { button = self.arrivalButton }
        button.setTitle(resultLocation.name, for: .normal)
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
