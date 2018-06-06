//
//  Stop.swift
//  Mpl.
//
//  Created by Darius Martin on 25/02/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import CoreLocation
import Foundation

class Stop : CustomStringConvertible, Equatable {

    var id: Int
    var tamId: Int
    var citywayId: Int
    var stopZoneId: Int
    var name: String
    var directionName: String
    var coords: CLLocation
    var pmrAccess: Bool
    var lines: [Line]?
    
    var timetable: Timetable = Timetable(schedules: [])
    var directions: [Direction] = []
    
    var description: String {
        return "\(self.name) \(self.id)"
    }
    
    init(id: Int, tamId: Int, citywayId: Int, stopZoneId: Int, name: String, lat: Double, lon: Double, pmr: Int) {
        self.id = id
        self.tamId = tamId
        self.citywayId = citywayId
        self.stopZoneId = stopZoneId
        self.name = name
        self.directionName = name
        self.coords = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        self.pmrAccess = pmr == 1 ? true : false
        
        //Special cases
        if (id == 567) { self.directionName = "\(name) - Sens A"}
        if (id == 569) { self.directionName = "\(name) - Sens B"}
        if (id == 711) { self.directionName = "\(name) T3"}
        if (id == 713) { self.directionName = "\(name) T1"}
    }
    
    static func ==(lhs: Stop, rhs: Stop) -> Bool {
        if lhs.id == rhs.id && lhs.citywayId == rhs.citywayId && lhs.stopZoneId == rhs.stopZoneId {
            return true
        }
        return false
    }
    
}
