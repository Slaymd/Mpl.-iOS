//
//  Direction.swift
//  Mpl.
//
//  Created by Darius Martin on 25/02/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

class Direction : CustomStringConvertible {
    
    var id: Int
    var line: Line
    var arrival: Stop
    var departure: Stop
    var direction: Int
    
    var description: String {
        return "L\(line) - \(arrival)"
    }
    
    init(id: Int, line: Line, arrival: Stop, departure: Stop, direction: Int) {
        self.id = id
        self.line = line
        self.arrival = arrival
        self.departure = departure
        self.direction = direction
    }
    
    
}
