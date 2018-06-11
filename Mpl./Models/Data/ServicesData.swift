//
//  ServicesData.swift
//  Mpl.
//
//  Created by Darius Martin on 09/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

enum ServiceType {
    case PARKING
    case BIKE
}

class ServiceBundle {
    
    var parkings: [Parking] = []
    var bikeStations: [BikeStation] = []
    
}

class ServicesData {
    
    static public func getServices(at stopZone: StopZone) -> ServiceBundle? {
        var services = false
        let bundle = ServiceBundle()
        
        bundle.parkings = ParkingData.getNearestParkings(location: stopZone.coords)
        if bundle.parkings.count > 0 { services = true }
        bundle.bikeStations = BikeData.getNearestBikeStations(loc: stopZone.coords)
        if bundle.bikeStations.count > 0 { services = true }
        return services ? bundle : nil
    }
    
}
