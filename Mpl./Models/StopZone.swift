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
    var updateState = 0
    
    var lastupdate: Double = 0.0
    var schedules: [Schedule] = []
    
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
    
    func getSchedules(of line: Line) -> [Schedule] {
        return (self.schedules.filter({$0.line == line}))
    }
    
    func getShedulesByDirection() -> [(line: Line, dest: Stop, times: [Int])] {
        var sortedSchedules: [(line: Line, dest: Stop, times: [Int])] = []
        
        for schedule in self.schedules {
            var _tmp = sortedSchedules.filter({$0.dest.id == schedule.destination.id && $0.line == schedule.line})
            let _tmpIndex = sortedSchedules.index(where: {$0.dest.id == schedule.destination.id && $0.line == schedule.line})
            
            if (_tmp.count == 1) {
                //Add schedule to direction
                sortedSchedules.remove(at: _tmpIndex!)
                _tmp[0].times.append(schedule.waitingTime)
                sortedSchedules.insert(_tmp[0], at: _tmpIndex!)
            } else {
                //Create new direction
                sortedSchedules.append((line: schedule.line, dest: schedule.destination, times: [schedule.waitingTime]))
            }
            
            
        }
        return (sortedSchedules.sorted(by: {$0.times[0] < $1.times[0]}))
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
    
    func updateTimetable(completion: @escaping (_ result: Bool) -> Void) {
        if lastupdate == 0 || Date.timeIntervalSinceReferenceDate-lastupdate > 20.0 {
            TransportData.updateStopZoneDirections(stopZone: self)
            lastupdate = Date.timeIntervalSinceReferenceDate
            os_log("Updating timetable...", type: .info)
            self.updateState = 1
            //Building request
            var requestparams = ["stopList": []]
            for stop in stops {
                for dir in stop.directions {
                    requestparams["stopList"]!.append(["citywayLineId": dir.line.citywayId, "citywayStopId": stop.citywayId, "tamStopId": stop.tamId, "lineNumber": dir.line.tamId, "urbanLine": dir.line.urban, "sens": dir.direction,"directions": [dir.arrival.citywayId]])
                }
            }
            Alamofire.request("https://apimobile.tam-voyages.com/api/v1/hours/next/stops", method: .post, parameters: requestparams, encoding: JSONEncoding.default).responseJSON { response in
                if (response.data != nil) {
                    self.updateState = 0
                    self.schedules.removeAll()
                    self.updateTimetable(fromJson: JSON(response.data!))
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            os_log("Timetable update refused. Please wait.", type: .info)
            completion(true)
        }
    }
    
    private func updateTimetable(fromJson json: JSON) {
        for (_,subJson):(String, JSON) in json {
            var stopArrivalId = subJson["line_direction"].intValue
            let tam_stop_id = subJson["tam_stop_id"].intValue
            let direction_name = subJson["line_direction_name"].stringValue
            let tam_line_id = subJson["tam_line_id"].stringValue
            let cityway_line_number = subJson["cityway_line_number"].stringValue
            let lineId = tam_line_id.count == 0 ? cityway_line_number.count == 0 ? -1 : Int(cityway_line_number) : Int(tam_line_id)
            
            if lineId == nil || lineId == -1 { continue }
            //subbus lines getting stop arrival id
            if tam_stop_id != -1 {
                for fstop in self.stops.filter({$0.tamId == tam_stop_id}) {
                    for dir in fstop.directions {
                        if direction_name.contains(dir.arrival.name) {
                            stopArrivalId = dir.arrival.citywayId
                            break
                        }
                    }
                }
            }
            //check if it is the terminus
            if self.stops.filter({$0.citywayId == stopArrivalId}).count > 0 { continue }
            
            for (_,subArrivals):(String, JSON) in subJson["stop_next_time"] {
                let waitingTime: Int? = Int(subArrivals["waiting_time"].stringValue.replacingOccurrences(of: " min", with: ""))
                let passingHour: Int? = Int(subArrivals["passing_hour"].stringValue)
                let passingMin: Int? = Int(subArrivals["passing_minute"].stringValue)
                
                if (waitingTime == nil || passingHour == nil || passingMin == nil) { continue }
                let schedule = Schedule(waitingTime: waitingTime!, scheduledHour: passingHour!, scheduledMinute: passingMin!, destCitywayId: stopArrivalId, lineTamId: lineId!, atStopZone: self)
                
                if (schedule == nil) { continue }
                self.schedules.append(schedule!)
            }
            self.sortSchedules()
            self.needDisplayUpdate = 1
        }
    }
    
    func sortSchedules() {
        self.schedules.sort(by: {$0.waitingTime < $1.waitingTime})
    }
    
    static func == (lhs: StopZone, rhs: StopZone) -> Bool {
        if lhs.id != rhs.id || lhs.tamId != rhs.tamId || lhs.citywayId != rhs.citywayId {
            return false
        }
        return true
    }
    
}
