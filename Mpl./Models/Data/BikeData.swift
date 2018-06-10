//
//  BikeData.swift
//  Mpl.
//
//  Created by Darius Martin on 09/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SWXMLHash

class BikeStation {
    
    var id: Int
    var name: String
    var spotWithBike: Int
    var spotFree: Int
    var location: CLLocation
    var cb: Bool
    
    init(id: Int, name: String, bikes: Int, free: Int, lat: Double, lon: Double, cb: Int) {
        self.id = id
        self.name = name
        self.spotWithBike = bikes
        self.spotFree = free
        self.location = CLLocation(latitude: lat, longitude: lon)
        self.cb = cb == 1 ? true : false
    }
    
}

class BikeData {
    
    static private var lastUpdate: Double = 0.0
    static private var bikeStations: [BikeStation] = []
    
    static public func getNearestBikeStations(loc: CLLocation) -> [BikeStation] {
        let filtered = self.bikeStations.filter({$0.location.distance(from: loc) < 350})
        
        return filtered
    }
    
    static public func updateIfNeeded(completion: @escaping (Bool) -> Void) {
        if bikeStations.count == 0 || Date.timeIntervalSinceReferenceDate-self.lastUpdate > 120.0 {
            self.updateBikeStations { (result) in
                completion(result)
            }
        } else {
            completion(false)
        }
    }
    
    static public func updateBikeStations(completion: @escaping (Bool) -> Void) {
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        Alamofire.request("https://data.montpellier3m.fr/sites/default/files/ressources/TAM_MMM_VELOMAG.xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            if let xmlRaw = response.result.value {
                
                let xml = SWXMLHash.parse(xmlRaw.data(using: String.Encoding.isoLatin1)!)
                
                for data in xml["vcs"]["sl"].children {
                    var name = data.element?.attribute(by: "na")?.text
                    let id = data.element?.attribute(by: "id")?.text
                    let lat = data.element?.attribute(by: "la")?.text
                    let lon = data.element?.attribute(by: "lg")?.text
                    let av = data.element?.attribute(by: "av")?.text
                    let fr = data.element?.attribute(by: "fr")?.text
                    let cb = data.element?.attribute(by: "cb")?.text

                    if name == nil || id == nil || lat == nil || lon == nil || av == nil || fr == nil || cb == nil { continue }
                    var filtered = self.bikeStations.filter({$0.id == Int(id!)})
                    
                    if filtered.count == 0 {
                        name = name!.replacingOccurrences(of: "\(id!) ", with: "")
                        self.bikeStations.append(BikeStation(id: Int(id!)!, name: name!, bikes: Int(av!)!, free: Int(fr!)!, lat: Double(lat!)!, lon: Double(lon!)!, cb: Int(cb!)!))
                    } else {
                        filtered[0].spotFree = Int(fr!)!
                        filtered[0].spotWithBike = Int(av!)!
                    }
                }
                completion(true)
                return
            }
            completion(false)
        }
    }
    
}
