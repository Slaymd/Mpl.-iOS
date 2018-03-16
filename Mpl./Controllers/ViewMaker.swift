//
//  ViewMaker.swift
//  Mpl.
//
//  Created by Darius Martin on 05/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class ViewMaker {

    class func createStationPopUpFromResearcherView(view: UIViewController, researcherView: ResearcherViewController, station: StopZone)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let stPopUp = storyBoard.instantiateViewController(withIdentifier: "StationPopUp") as! StationViewController
        view.present(stPopUp, animated: false, completion: nil)
        
        //Setting station informations
        stPopUp.stationName.text = station.name.folding(options: .diacriticInsensitive, locale: NSLocale.current).uppercased()
        stPopUp.station = station
        stPopUp.researchView = researcherView
        stPopUp.update()
        //Display directions
        stPopUp.displayDirections()
        //Fav icon
        if UserData.isFavorite(station) {
            stPopUp.favButton.setImage(#imageLiteral(resourceName: "star_filled"), for: .normal)
        } else {
            stPopUp.favButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
        }
    }
    
    class func createStationPopUpFromHome(view: HomeView, station: StopZone)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let stPopUp = storyBoard.instantiateViewController(withIdentifier: "StationPopUp") as! StationViewController
        view.present(stPopUp, animated: false, completion: nil)
        
        //Setting station informations
        stPopUp.stationName.text = station.name.folding(options: .diacriticInsensitive, locale: NSLocale.current).uppercased()
        stPopUp.station = station
        stPopUp.homeView = view
        stPopUp.update()
        //Display directions
        stPopUp.displayDirections()
        //Fav icon
        if UserData.isFavorite(station) {
            stPopUp.favButton.setImage(#imageLiteral(resourceName: "star_filled"), for: .normal)
        } else {
            stPopUp.favButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
        }
    }
}
