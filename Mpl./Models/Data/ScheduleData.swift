//
//  ScheduleData.swift
//  Mpl.
//
//  Created by Darius Martin on 04/04/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import Alamofire
import os.log
import SwiftyJSON

class ScheduleData {
    
    static var lastUpdates: [(line: Line, lastUpdate: Double)] = []
    
    static func getSchedules(of line: Line, completion: @escaping (_ result: Bool) -> Void) {
        //Min request every 30 seconds
        if canUpdate(line: line) {
            let lineStations = TransportData.getLineStopZonesByDirection(line: line)
            let stations: [StopZone] = lineStations.count > 0 ? lineStations[0] : []
            os_log("TaM API : Getting line schedules...", type: .info)
            
            //Building request...
            var requestParams = ["stops": [], "lineNumber": "\(line.tamId)", "directions": [], "urbanLine": line.urban == 1 ? true : false] as [String : Any]
            var stopsId: [Int] = []
            var directions: [Int] = []
            for station in stations {
                TransportData.updateStopZoneDirections(stopZone: station)
                for stop in station.stops {
                    let dirs = stop.directions.filter({$0.line == line})
                    
                    for dir in dirs {
                        if !directions.contains(dir.arrival.citywayId) {
                            directions.append(dir.arrival.citywayId)
                        }
                    }
                    stopsId.append(stop.citywayId)
                }
            }
            requestParams["stops"] = stopsId
            requestParams["directions"] = directions
            
            //Sending request
            Alamofire.request("https://apimobile.tam-voyages.com/api/v1/hours/next/line", method: .post, parameters: requestParams, encoding: JSONEncoding.default).responseJSON { response in
                if (response.data != nil) {
                    self.updateTimetable(fromJson: JSON(response.data!))
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(true)
        }
    }
    
    static func updateTimetable(fromJson json: JSON) {
        for (_,subJson):(String, JSON) in json {
            let stopId = subJson["cityway_stop_id"].intValue
            let stopArrivalId = subJson["line_direction"].intValue
            let lineId = Int(subJson["tam_line_id"].stringValue)!
            
            let stop = TransportData.getStop(byCitywayId: stopId)
            if stop == nil { continue }
            let stopZone = TransportData.getStopZoneById(stopZoneId: stop!.stopZoneId)
            if stopZone == nil { continue }
            
            for (_,subArrivals):(String, JSON) in subJson["stop_next_time"] {
                let waitingTime: Int? = Int(subArrivals["waiting_time"].stringValue.replacingOccurrences(of: " min", with: ""))
                let passingHour: Int? = Int(subArrivals["passing_hour"].stringValue)
                let passingMin: Int? = Int(subArrivals["passing_minute"].stringValue)
                
                if (waitingTime == nil || passingHour == nil || passingMin == nil) { continue }
                let schedule = Schedule(waitingTime: waitingTime!, scheduledHour: passingHour!, scheduledMinute: passingMin!, destCitywayId: stopArrivalId, lineTamId: lineId, atStopZone: stopZone!)
                
                if (schedule == nil) { continue }
                stopZone!.schedules.append(schedule!)
            }
            stopZone!.sortSchedules()
        }
    }
    
    //MARK: - UPDATE MANAGER
    
    static func canUpdate(line: Line) -> Bool {
        if lastUpdates.contains(where: {$0.line == line}) {
            var lastUpdate = lastUpdates.filter({$0.line == line})
            
            if Date.timeIntervalSinceReferenceDate-lastUpdate[0].lastUpdate > 30 {
                //Can update
                let index = lastUpdates.index(where: {$0.line == line})
                
                self.lastUpdates.remove(at: index!)
                lastUpdate[0].lastUpdate = Date.timeIntervalSinceReferenceDate
                return true
            }
            return false
            
        }
        lastUpdates.append((line: line, lastUpdate: Date.timeIntervalSinceReferenceDate))
        return true
    }
    
    
}
