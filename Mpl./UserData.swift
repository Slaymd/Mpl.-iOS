//
//  UserData.swift
//  Mpl.
//
//  Created by Darius Martin on 30/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import Foundation
import NotificationBannerSwift
import CoreLocation

class UserData {
    
    static var favStationsId: [Int] = [Int]()
    static var displayedName: String = "Sur Mpl. !"
    
    static func loadUserData() {
        let defaults = UserDefaults.standard
        if let favList = defaults.value(forKey: "favlist") {
            self.favStationsId = favList as! [Int]
        }
        if let name = defaults.value(forKey: "dispname") {
            self.displayedName = name as! String
        }
    }
    
    static func saveUserData() {
        let defaults = UserDefaults.standard
        defaults.set(favStationsId, forKey: "favlist")
        defaults.set(displayedName, forKey: "dispname")
    }
    
    @discardableResult static func addFavStation(station: StopZone) -> Int {
        if !favStationsId.contains(station.id) {
            self.favStationsId.append(station.id)
            saveUserData()
            return 0
        } else {
            let haptic: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
            
            haptic.prepare()
            haptic.notificationOccurred(.warning)
            if (NotificationBannerQueue.default.numberOfBanners == 0) {
                let banner = NotificationBanner(title: station.name.uppercased(), subtitle: "Cette station est déjà en favoris ;)", style: .info)
                banner.haptic = .none
                banner.show()
            }
            return 84
        }
    }
    
    static func removeFavStation(station: StopZone) {
        for i in 0..<favStationsId.count {
            if favStationsId[i] == station.id {
                favStationsId.remove(at: i)
                break
            }
        }
        saveUserData()
    }
    
    static func getFavStations() -> [StopZone] {
        var stationList: [StopZone] = []
        var _tmpStation: StopZone?

        for id in self.favStationsId {
            _tmpStation = TransportData.getStationById(id)
            if _tmpStation != nil {
                stationList.append(_tmpStation!)
            }
        }
        return (stationList)
    }
    
    static func getFavStationsByLocation(refLocation: CLLocation) -> [StopZone] {
        var sortedLoc: [(station: StopZone, loc: Double)] = []
        var sortedStations: [StopZone] = []

        //getting distance of every stations
        for station in getFavStations() {
            let distanceFromUser = refLocation.distance(from: station.coords)
            sortedLoc.append((station: station, loc: distanceFromUser))
        }
        sortedLoc = sortedLoc.sorted(by: {$0.loc < $1.loc})
        for loc in sortedLoc {
            sortedStations.append(loc.station)
        }
        return sortedStations
    }
    
    static func isFavorite(_ station: StopZone) -> Bool {
        for stationId in self.favStationsId {
            if (station.id == stationId) {
                return (true)
            }
        }
        return (false)
    }
    
}
