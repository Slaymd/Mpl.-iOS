//
//  Station.swift
//  Mpl.
//
//  Created by Darius Martin on 27/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import Foundation
import CoreLocation

/*class Station {
    
    var id: Int
    var subId: [Int] = []
    var name: String
    var lines: [Line]
    var timetable: [Timetable]
    var coords: CLLocation
    
    init(id: Int, name: String, lines: [Line], timetable: [Timetable], coords: [Double]) {
        self.id = id
        self.name = name
        self.lines = lines
        self.timetable = timetable
        self.coords = CLLocation(latitude: CLLocationDegrees(coords[0]), longitude: CLLocationDegrees(coords[1]))
    }
    
    func getLines() -> [Line]! {
        return self.lines
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getTimetable() -> Timetable? {
        if (timetable.count == 0) { return nil }
        return (timetable[0])
    }
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        if lhs.id != rhs.id || lhs.name != rhs.name || lhs.lines != rhs.lines{
            return false
        }
        for i in 0..<lhs.timetable.count {
            if i < rhs.timetable.count {
                if lhs.timetable[0] == rhs.timetable[0] {
                    return true
                }
            } else {
                return false
            }
        }
        return true
    }
}*/
