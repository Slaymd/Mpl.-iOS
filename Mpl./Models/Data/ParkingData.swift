//
//  ParkingData.swift
//  Mpl.
//
//  Created by Darius Martin on 09/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SWXMLHash

class Parking {
    
    //base
    
    var location: CLLocation
    var name: String
    var apiName: String
    
    //data
    var open: Bool = true
    var spotFree: Int = -1
    var spotTotal: Int = -1
    
    init(name: String, lat: Double, long: Double, api: String) {
        self.location = CLLocation(latitude: lat, longitude: long)
        self.name = name
        self.apiName = api
    }
    
}

class ParkingData {
    
    static private var parkings: [Parking] = [Parking(name: "Arc de Triomphe", lat: 43.611002670702007, long: 3.873200752755528, api: "FR_MTP_ARCT"),
                                              Parking(name: "Gare Saint-Roch", lat: 43.603291492467463, long: 3.878550717206318, api: "FR_MTP_GARE"),
                                              Parking(name: "Antigone", lat: 43.608716064433729, long: 3.888818931230324, api: "FR_MTP_ANTI"),
                                              Parking(name: "Triangle", lat: 43.609233841538739, long: 3.88184418052775, api: "FR_MTP_TRIA"),
                                              Parking(name: "Comédie", lat: 43.608560920671742, long: 3.879761960475114, api: "FR_MTP_COME")]
    
    static public func getNearestParkings(location: CLLocation) -> [Parking] {
        let filtered = self.parkings.filter({$0.location.distance(from: location) < 350})

        return filtered
    }
    
    static public func updateData(of parking: Parking, completion: @escaping (Bool) -> Void) {
        Alamofire.request("https://data.montpellier3m.fr/sites/default/files/ressources/\(parking.apiName).xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseString { response in
                if let xmlRaw = response.result.value {
                    let xml = SWXMLHash.parse(xmlRaw)
                    
                    for data in xml["park"].children {
                        let value = data.element?.text
                        
                        if value == nil { continue }
                        if (data.description.starts(with: "<Status>") && value! == "Open") { parking.open = true }
                        if (data.description.starts(with: "<Free>")) { parking.spotFree = Int(value!)! }
                        if (data.description.starts(with: "<Total>")) { parking.spotTotal = Int(value!)! }
                    }
                    completion(true)
                    return
                }
                completion(false)
        }
    }
    
}
