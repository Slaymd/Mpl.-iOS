//
//  StopZone.swift
//  Mpl.
//
//  Created by Darius Martin on 25/02/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire
import os.log
import SwiftyJSON

class StopZone : CustomStringConvertible, Equatable {
    
    var id: Int
    var tamId: Int
    var citywayId: Int
    var name: String
    var cityName: String
    var coords: CLLocation
    var stops: [Stop] = []
    var lines: [Line] = []
    
    var needDisplayUpdate = 0
    
    var lastupdate: Double = 0.0
    var timetable: Timetable = Timetable.init(schedules: [])
    
    var description: String {
        return "\(self.name) {\(self.stops.count)}"
    }
    
    init(id: Int, tamId: Int, citywayId: Int, name: String, cityName: String, lat: Double, lon: Double) {
        self.id = id
        self.tamId = tamId
        self.citywayId = citywayId
        self.name = name
        self.cityName = cityName
        self.coords = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
    }
    
    func getLine(byTamId id: Int) -> Line? {
        if lines.count == 0 { self.lines = self.getLines() }
        let _line = lines.filter({$0.tamId == id})
        
        if _line.count != 1 { return nil }
        return _line[0]
    }

    func getLines() -> [Line] {
        if lines.count == 0 {
            TransportData.updateStopZoneDirections(stopZone: self)
            for stop in self.stops {
                for dir in stop.directions {
                    if (!lines.contains(dir.line)) {
                        lines.append(dir.line)
                    }
                }
            }
        }
        return self.lines
    }
    
    func updateTimetable() {
        if lastupdate == 0 || Date.timeIntervalSinceReferenceDate-lastupdate > 15.0 {
            TransportData.updateStopZoneDirections(stopZone: self)
            lastupdate = Date.timeIntervalSinceReferenceDate
            os_log("Updating timetable...", type: .info)
            self.timetable.state = 1
            self.needDisplayUpdate = 1
            //Building request
            var requestparams = ["stopList": []]
            for stop in stops {
                for dir in stop.directions {
                    requestparams["stopList"]!.append(["citywayStopId": stop.citywayId, "lineNumber": dir.line.tamId, "urbanLine": dir.line.urban, "directions": [dir.arrival.citywayId]])
                }
            }
            Alamofire.request("https://apimobile.tam-voyages.com/api/v1/hours/next/stops", method: .post, parameters: requestparams, encoding: JSONEncoding.default).responseJSON { response in
                if (response.data != nil) {
                    self.timetable.state = 0
                    self.timetable.schedules.removeAll()
                    self.updateTimetable(fromJson: JSON(response.data!))
                }
            }
        } else {
            os_log("Timetable update refused. Please wait.", type: .info)
        }
    }
    
    func updateTimetable(fromJson json: JSON) {
        for (_,subJson):(String, JSON) in json {
            let stopArrivalId = subJson["line_direction"].intValue
            let lineId = Int(subJson["tam_line_id"].stringValue)!
            var arrivalStop: Stop?
            
            for stop in stops {
                for dir in stop.directions {
                    if (dir.arrival.citywayId == stopArrivalId) { arrivalStop = dir.arrival }
                }
            }
            
            if arrivalStop == nil { continue }
            print("Line", lineId, " - ", arrivalStop!)
            for (_,subArrivals):(String, JSON) in subJson["stop_next_time"] {
                let arrivalDate = DayDate.init(minsFromNow: Int(subArrivals["waiting_time"].stringValue.replacingOccurrences(of: " min", with: ""))!)
                print(subArrivals["waiting_time"])
                print(arrivalDate)
                self.timetable.addSchedule(date: arrivalDate, lineId: lineId, dest: arrivalStop!)
            }
            self.timetable.sortSchedules()
            self.needDisplayUpdate = 1
        }
    }
    
    static func == (lhs: StopZone, rhs: StopZone) -> Bool {
        if lhs.id != rhs.id || lhs.tamId != rhs.tamId || lhs.citywayId != rhs.citywayId {
            return false
        }
        return true
    }
    
}
