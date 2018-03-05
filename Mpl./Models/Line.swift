//
//  Line.swift
//  Mpl.
//
//  Created by Darius Martin on 27/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import Foundation
import UIKit

enum LineType {
    case TRAMWAY,BUS,UNKNOWN
}

class Line : Hashable, CustomStringConvertible {
    
    var id: Int
    var tamId: Int
    var citywayId: Int
    var displayId: Int
    var name: String
    var shortName: String
    var type: LineType
    var bgColor: UIColor
    var ftColor: UIColor
    var urban: Int
    var directions: [String]
    
    var description: String { return self.shortName }
    
    var hashValue: Int { return bgColor.hashValue }
    
    init(id: Int, tamId: Int, citywayId: Int, displayId: Int, name: String, shortName: String, forwardDir: String, backwardDir: String, mode: Int, color: String, fontColor: String, urban: Int) {
        self.id = id
        self.tamId = tamId
        self.citywayId = citywayId
        self.displayId = displayId
        self.name = name
        self.shortName = shortName
        self.type = (mode == 0) ? LineType.TRAMWAY : (mode == 3) ? LineType.BUS : LineType.UNKNOWN
        self.bgColor = UIColor(hex: color)
        self.ftColor = UIColor(hex: fontColor)
        self.urban = urban
        
        //Directions
        self.directions = []
        if (forwardDir.count > 5 && backwardDir.count > 5) {
            let dir1 = String(forwardDir[forwardDir.index(forwardDir.startIndex, offsetBy: 5)...])
            let dir2 = String(backwardDir[backwardDir.index(backwardDir.startIndex, offsetBy: 5)...])
            let alldirs = "\(dir1) / \(dir2)"
            
            for dir in alldirs.replacingOccurrences(of: " / ", with: "$").split(separator: "$") {
                self.directions.append(String(dir))
            }
        }
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.bgColor == rhs.bgColor
    }
}
