//
//  Disruption.swift
//  Mpl.
//
//  Created by Darius Martin on 21/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

class Disruption {
    
    var line: Line
    var startDate: String
    var endDate: String
    
    var title: String
    var description: String
    
    init(line: Line, startDate: String, endDate: String, title: String, description: String) {
        self.line = line
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
        self.description = description
    }
    
}
