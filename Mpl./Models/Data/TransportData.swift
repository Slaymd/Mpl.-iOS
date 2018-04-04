//
//  TransportData.swift
//  Mpl.
//
//  Created by Darius Martin on 30/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import Foundation
import UIKit
import SQLite
import os.log

class TransportData {

    static var referenceDatabase: Connection?
    
    static var stopZones: [StopZone] = []
    static var stops: [Stop] = []
    static var lines: [Line] = []
    static var directions: [Direction] = []
    
    static var stopDirections: [(stopId: Int, directionId: Int)] = []
    static var stopLines: [(stopZoneId: Int, lines: [Line])] = []
    
    static func initDatabase() {
        let databasePath = Bundle.main.path(forResource: "referential_android", ofType: "sqlite")!
        let refdb = try? Connection(databasePath)
        
        if refdb == nil { return }
        self.referenceDatabase = refdb
        os_log("Initializing stop zones...", type: .info)
        initStopsZone(refdb!)
        os_log("Initializing stop...", type: .info)
        initStops(refdb!)
        os_log("Initializing lines...", type: .info)
        initLines(refdb!)
        os_log("Initializing directions...", type: .info)
        initDirections(refdb!)
        os_log("Initializing stop directions...", type: .info)
        initStopDirections(refdb!)
    }
    
    static func getStopZoneById(stopZoneId: Int) -> StopZone? {
        let stopzone = stopZones.filter({$0.id == stopZoneId})
        
        if stopzone.count != 1 { return nil }
        return stopzone[0]
    }
    
    static func getStopById(stopCitywayId: Int) -> Stop? {
        let stop = stops.filter({$0.citywayId == stopCitywayId})
        
        if stop.count != 1 { return nil }
        return stop[0]
    }
    
    static func getStopById(id: Int) -> Stop? {
        let stop = stops.filter({$0.id == id})
        
        if stop.count != 1 { return nil }
        return stop[0]
    }
    
    static func getStopByIdAtStopZone(stopZone: StopZone, stopCitywayId: Int) -> Stop? {
        var fstop: Stop?
        
        for stop in stopZone.stops {
            for dir in stop.directions {
                if (dir.arrival.citywayId == stopCitywayId) { fstop = dir.arrival }
            }
        }
        return (fstop)
    }
    
    static func getLineStopsIdByDirection(line: Line) -> [(direction: Int, stopsId: [Int])] {
        var result: [(direction: Int, stopsId: [Int])] = []
        
        print("Getting line stops of \(line)")
        if (self.referenceDatabase == nil) { return result}
        let direction = Expression<Int64>("direction")
        let stop = Expression<Int64>("stop")
        let dbline = Expression<Int64>("line")
        let lineStopsTable = Table("FLATTEN_LINE_STOP").filter(dbline == Int64(line.id))
        
        for lineStop in try! self.referenceDatabase!.prepare(lineStopsTable) {
            var tmp = result.filter({$0.direction == Int(lineStop[direction])})
            let idx = result.index(where: {$0.direction == Int(lineStop[direction])})
            
            if tmp.count == 1 {
                result.remove(at: idx!)
                tmp[0].stopsId.append(Int(lineStop[stop]))
                result.append(tmp[0])
            } else {
                result.append((direction: Int(lineStop[direction]), stopsId: [Int(lineStop[stop])]))
            }
        }
        return result
    }
    
    static func getLineStopZonesByDirection(line: Line) -> [[StopZone]] {
        let stopsIdByDirection = self.getLineStopsIdByDirection(line: line)
        var result: [[StopZone]] = []
        
        for direction in stopsIdByDirection {
            var dirStopZone: [StopZone] = []
            
            for stopId in direction.stopsId {
                let stop = self.getStopById(id: stopId)
                
                if stop == nil { continue }
                let stopZone = self.getStopZoneById(stopZoneId: stop!.stopZoneId)
                
                if stopZone == nil { continue }
                dirStopZone.append(stopZone!)
            }
            result.append(dirStopZone)
        }
        return result
    }
    
    static func updateStopZoneDirections(stopZone: StopZone) {
        for stop in stopZone.stops {
            if stop.directions.count != 0 { continue }
            let _stopDirs = stopDirections.filter({$0.stopId == stop.id})
            var dirIds: [Int] = []
            
            for dir in _stopDirs {
                let _direction = directions.filter({$0.id == dir.directionId})
                
                if _direction.count != 1 { continue }
                if dirIds.contains(_direction[0].arrival.id) { continue }
                dirIds.append(_direction[0].arrival.id)
                stop.directions.append(_direction[0])
            }
        }
    }
    
    static func initStopDirections(_ refdb: Connection) {
        let stopDirTable = Table("STOP_DIRECTION")
        let stopId = Expression<Int64>("stop")
        let directionId = Expression<Int64>("direction")
        
        for stopDir in try! refdb.prepare(stopDirTable) {
            stopDirections.append((stopId: Int(stopDir[stopId]), directionId: Int(stopDir[directionId])))
        }
    }
    
    /*static func initStopLines(_ refdb: Connection) {
        let stopLineTable = Table("LINE_STOPZONE")
        let lineId = Expression<Int64>("line")
        let stopZone = Expression<Int64>("stopzone")
        
        for line in try! refdb.prepare(stopLineTable) {
            let _line = lines.filter({$0.id == Int(line[lineId])})
            
            if (_line.count != 1) { continue }
            if stopLines.contains(where: {$0.stopZoneId == Int(line[stopZone])}) {
                var _stops = stopLines.filter({$0.stopZoneId == Int(line[stopZone])})
                let idx = stopLines.index(where: {$0.stopZoneId == Int(line[stopZone])})
                
            } else {
                stopLines.append((stopZoneId: Int(line[stopZone]), lines: [_line[0]]))
            }
            
        }
    }*/
    
    static func initDirections(_ refdb: Connection) {
        let dirTable = Table("DIRECTION")
        let id = Expression<Int64>("_id")
        let lineId = Expression<Int64>("line")
        let depart = Expression<Int64>("stop_departure")
        let arrival = Expression<Int64>("stop_arrival")
        let direction = Expression<Int64>("cityway_direction")
        
        for dir in try! refdb.prepare(dirTable) {
            let _arrivals = stops.filter({$0.id == Int(dir[arrival])})
            let _departures = stops.filter({$0.id == Int(dir[depart])})
            let _lines = lines.filter({$0.id == Int(dir[lineId])})
            
            if _arrivals.count != 1 || _departures.count != 1 || _lines.count != 1 { continue }
            self.directions.append(Direction(id: Int(dir[id]), line: _lines[0], arrival: _arrivals[0], departure: _departures[0], direction: Int(dir[direction])))
        }
        
    }
    
    static func initLines(_ refdb: Connection) {
        let lineTable = Table("LINE")
        let id = Expression<Int64>("_id")
        let tamId = Expression<String>("tam_id")
        let citywayId = Expression<String>("cityway_id")
        let displayId = Expression<Int64>("display_order")
        let name = Expression<String>("line_name")
        let short_name = Expression<String>("short_name")
        let mode = Expression<Int64>("mode")
        let bgColor = Expression<String>("color")
        let ftColor = Expression<String>("line_text_color")
        let forward = Expression<String>("commercial_forward_name")
        let backward = Expression<String>("commercial_backward_name")
        let urban = Expression<Int64>("urban")
        
        for line in try! refdb.prepare(lineTable) {
            self.lines.append(Line(id: Int(line[id]), tamId: Int(line[tamId])!, citywayId: Int(line[citywayId])!, displayId: Int(line[displayId]), name: line[name], shortName: line[short_name], forwardDir: line[forward], backwardDir: line[backward], mode: Int(line[mode]), color: line[bgColor], fontColor: line[ftColor], urban: Int(line[urban])))
        }
    }
    
    static func initStopsZone(_ refdb: Connection) {
        let zoneTable = Table("STOPZONE")
        let id = Expression<Int64>("_id")
        let tamId = Expression<String>("tam_id")
        let citywayId = Expression<String>("cityway_id")
        let name = Expression<String>("stopzone_name")
        let cityName = Expression<String>("locality_name")
        let lat = Expression<Double>("latitude")
        let lon = Expression<Double>("longitude")
        
        for zone in try! refdb.prepare(zoneTable) {
            self.stopZones.append(StopZone(id: Int(zone[id]), tamId: Int(zone[tamId])!, citywayId: Int(zone[citywayId])!, name: zone[name], cityName: zone[cityName].capitalized, lat: zone[lat], lon: zone[lon]))
        }
    }
    
    static func initStops(_ refdb: Connection) {
        let stopTable = Table("STOP")
        let id = Expression<Int64>("_id")
        let tamId = Expression<Int64>("tam_id")
        let citywayId = Expression<Int64>("cityway_id")
        let name = Expression<String>("stop_name")
        let lat = Expression<Double>("latitude")
        let lon = Expression<Double>("longitude")
        let stopZone = Expression<Int64>("stopzone")
        let pmr = Expression<Int64>("pmr")
        
        for stop in try! refdb.prepare(stopTable) {
            let parsedStop = Stop(id: Int(stop[id]), tamId: Int(stop[tamId]), citywayId: Int(stop[citywayId]), stopZoneId: Int(stop[stopZone]), name: stop[name], lat: stop[lat], lon: stop[lon], pmr: Int(stop[pmr]))
            let stopZones = self.stopZones.filter({$0.id == parsedStop.stopZoneId})

            self.stops.append(parsedStop)
            if stopZones.count == 1 {
                stopZones[0].stops.append(parsedStop)
            }
        }
    }
    
    /*static func getDbLineDirections(forward_name: String, backward_name: String) -> [String] {
        var directions: [String] = []
        let dir1 = String(forward_name[forward_name.index(forward_name.startIndex, offsetBy: 5)...])
        let dir2 = String(backward_name[backward_name.index(backward_name.startIndex, offsetBy: 5)...])
        let alldirs = "\(dir1) / \(dir2)"
        
        for dir in alldirs.replacingOccurrences(of: " / ", with: "$").split(separator: "$") {
            directions.append(String(dir))
        }
        return (directions)
    }
    
    static func initLines(_ refdb: Connection) {
        let lines = Table("LINE")
        let id = Expression<Int64>("_id")
        let name = Expression<String>("short_name")
        let type = Expression<Int64>("mode")
        let bgColor = Expression<String>("color")
        let ftColor = Expression<String>("line_text_color")
        let forward = Expression<String>("commercial_forward_name")
        let backward = Expression<String>("commercial_backward_name")
        
        for line in try! refdb.prepare(lines) {
            self.lineList.append(Line(id: Int(line[id]),
                                      name: line[name],
                                      type: line[type] == 0 ? LineType.TRAMWAY : LineType.BUS,
                                      bgColor: hexStringToUIColor(hex: line[bgColor]),
                                      fontColor: hexStringToUIColor(hex: line[ftColor]),
                                      directions: getDbLineDirections(forward_name: line[forward], backward_name: line[backward])))
        }
    }*/
    
    /*static func get_line_stops(_ refdb: Connection) -> [(lineId: Int, stopIds: [Int])] {
        var line_stops: [(lineId: Int, stopIds: [Int])] = []
        let line_stops_table = Table("LINE_STOPZONE")
        let lineId = Expression<Int64>("line")
        let stopId = Expression<Int64>("stopzone")
        
        for stop in try! refdb.prepare(line_stops_table) {
            if line_stops.contains(where: {$0.lineId == stop[lineId]}) {
                var linestop = line_stops.filter({$0.lineId == stop[lineId]})
                let index = line_stops.index(where: {$0.lineId == stop[lineId]})
                line_stops.remove(at: index!)
                linestop[0].stopIds.append(Int(stop[stopId]))
                line_stops.insert(linestop[0], at: index!)
            } else {
                line_stops.append((lineId: Int(stop[lineId]), stopIds: [Int(stop[stopId])]))
            }
        }
        return (line_stops)
    }
    
    static func initStations(_ refdb: Connection) {
        let line_stops = get_line_stops(refdb)
        let stop_zone = Table("STOPZONE")
        let id = Expression<Int64>("_id")
        //let tam_id = Expression<Int64>("tam_id")
        let name = Expression<String>("stopzone_name")
        let lat = Expression<Double>("latitude")
        let lon = Expression<Double>("longitude")
        
        for stop in try! refdb.prepare(stop_zone) {
            var lines: [Line] = []
            var linestops = line_stops.filter({$0.stopIds.contains(Int(stop[id]))})
            for i in 0..<linestops.count {
                let line = getLineById(linestops[i].lineId)
                if line != nil { lines.append(line!) }
            }
            self.stationList.append(Station(id: Int(stop[id]), name: stop[name], lines: lines, timetable: [], coords: [stop[lat], stop[lon]]))
        }
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }*/
    
    /*static func initLines() {
        /*print("initialising directions...")
        var directions: [(dirId: Int, lineId: Int, dirName: String)] = []
        do {
            //Récupération du fichier de trips
            let path = Bundle.main.path(forResource: "trips", ofType: "txt")
            let rawData = try String(contentsOfFile: path!, encoding: .utf8)
            let data = rawData.components(separatedBy: .newlines)
            for tripLine in data {
                let splt = tripLine.split(separator: ",")
                if (splt.count < 5 || Int(splt[2]) == nil || Int(splt[0]) == nil) { continue }
                let dirStrId = splt[3].replacingOccurrences(of: " - ", with: "€").split(separator: "€")[1]
                directions.append((dirId: Int(splt[2])!, lineId: Int(splt[0])!, dirName: String(dirStrId)))
            }
        } catch {
            print(error)
        }
        print("initialising lines...")
        do {
            //Récupération du fichier de lines (routes)
            let path = Bundle.main.path(forResource: "routes", ofType: "txt")
            let rawData = try String(contentsOfFile: path!, encoding: .utf8)
            let data = rawData.components(separatedBy: .newlines)
            for tripLine in data {
                var splt = tripLine.replacingOccurrences(of: "\"", with: "").split(separator: ",")
                if (splt.count < 5 || Int(splt[0]) == nil) { continue }
                var directions: [String] = []
                for dir in splt[3].replacingOccurrences(of: " - ", with: "€").split(separator: "€") {
                    directions.append(String(dir))
                }
                let lineId = Int(splt[0])!
                let lineName = String(splt[2])
                let lineType = (splt[4] == "3" ? LineType.BUS : LineType.TRAMWAY)
                Data.lineList.append(Line(id: lineId, name: String(lineName), type: lineType, bgColor: UIColor.lightGray, fontColor: UIColor.black, directions: directions))
            }
        } catch {
            print(error)
        }
        print("initialising timetables...")
        do {
            //Récupération du fichier de timetable (stop_time)
            let path = Bundle.main.path(forResource: "stop_times", ofType: "txt")
            let rawData = try String(contentsOfFile: path!, encoding: .utf8)
            let data = rawData.components(separatedBy: .newlines)
            for timeLine in data {
                var splt = timeLine.split(separator: ",")
                if (splt.count < 5 || Int(splt[0]) == nil) { continue }
                
                let stationId = Int(splt[3])
                if (stationId == nil || !self.isFavorite(stationId: stationId!)) { continue }
                
                let tripId = Int(splt[0])!
                let arrSplt = String(splt[1]).split(separator: ":")
                let arrDate = DayDate(Int(arrSplt[0])!, Int(arrSplt[1])!, Int(arrSplt[2])!)
                if (arrDate.getMinsFromNow() > 120 && arrDate.getMinsFromNow() < 800) { continue }
                var station: Station? = self.getStationById(Int(splt[3])!)
                
                if station == nil  { continue }
                for dir in directions {
                    if dir.dirId == tripId {
                        var line: Line? = self.getLineById(dir.lineId)
                        
                        if line == nil { continue }
                        if !station!.getLines().contains(line!) {
                            station?.lines.append(line!)
                        }
                        if !(station!.lines.contains(line!)) { station!.lines.append(line!) }
                        
                        var destId: Int? = nil
                        if line!.directions.contains(dir.dirName) { destId = line!.directions.index(of: dir.dirName) }
                        if destId == nil { continue }
                        
                        if (station!.timetable.count == 0) { station!.timetable.append(Timetable(calendars: [], schedules: [])) }
                        station!.timetable[0].addSchedule(date: arrDate, lineId: dir.lineId, destId: destId!)
                        line = nil
                    }
                }
                station = nil
                
            }
        } catch {
            print(error)
        }
        print("timetables initializing finished...")*/
        let line1: Line = Line(id: 1, name: "1", type: LineType.TRAMWAY, bgColor: UIColor(red: 0.0/255.0, green: 83.0/255.0, blue: 156.0/255.0, alpha: 1.0), fontColor: UIColor.white, directions: ["Mosson", "Odysseum"])
        self.lineList.append(line1)
        let line2: Line = Line(id: 2, name: "2", type: LineType.TRAMWAY, bgColor: UIColor(red: 238.0/255.0, green: 127.0/255.0, blue: 2.0/255.0, alpha: 1.0), fontColor: UIColor.white, directions: ["Jacou", "Sablassou", "Sabines", "St Jean de Vedas"])
        self.lineList.append(line2)
        let line3: Line = Line(id: 3, name: "3", type: LineType.TRAMWAY, bgColor: UIColor(red: 203.0/255.0, green: 211.0/255.0, blue: 1.0/255.0, alpha: 1.0), fontColor: UIColor.black, directions: ["Juvignac", "Mosson", "Pérols étang de l'or", "Lattes centre", "Boirargues"])
        self.lineList.append(line3)
        let line4: Line = Line(id: 4, name: "4", type: LineType.TRAMWAY, bgColor: UIColor(red: 84.0/255.0, green: 43.0/255.0, blue: 33.0/255.0, alpha: 1.0), fontColor: UIColor.white, directions: ["Sens A", "Sens B"])
        self.lineList.append(line4)
        //Ligne 6 rgb(230, 64, 144)
        //Ligne 7 rgb(166, 120, 174)
        //Ligne 8 rgb(255, 221, 0) BLK IN
        //Ligne 9 rgb(150, 191, 14)
    }*/
    
    /*static func initStations() {
        let stationsFileList: [String] = ["antigone", "moulares", "comedie"]
        
        for stationFile in stationsFileList {
            if let path = Bundle.main.path(forResource: stationFile, ofType: "json") {
                do {
                    //Getting json object
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    //Parsing json
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                        //Getting raw data in swift objects
                        let stationName: String? = jsonResult["name"] as? String
                        let stationId: Int? = jsonResult["id"] as? Int
                        let stationLogicIds: [Int]? = jsonResult["logicIds"] as? [Int]
                        let stationLines: [Int]? = jsonResult["lines"] as? [Int]
                        let stationCoords: [Double]? = jsonResult["coords"] as? [Double]
                        var stationTimetableWeekdays: [String: Any]? = [:]
                        
                        //Getting timetable
                        if let stationTimetables = jsonResult["timetables"] as? [String: Any] {
                            if stationTimetables["weekdays"] as? [String: Any] != nil {
                                stationTimetableWeekdays = (stationTimetables["weekdays"] as! [String: Any])
                            }
                        }
                        
                        if stationName != nil && stationId != nil && stationLogicIds != nil && stationLines != nil && stationTimetableWeekdays != nil && stationCoords != nil {
                            let timetable: Timetable = Timetable(calendars: [], schedules: [])
                            var stationLinesConverted: [Line] = []
                            
                            for lineId in stationLines! {
                                let lineObj: Line? = self.getLineById(lineId)
                                if (lineObj != nil) {
                                    stationLinesConverted.append(lineObj!)
                                }
                            }
                            
                            //Parsing timetable
                            for line in stationLinesConverted {
                                if let lineTimetable = stationTimetableWeekdays!["\(line.id)"] as? [String: Any] {
                                    for lineDestId in 0..<line.directions.count {
                                        if let destTimetable = lineTimetable["\(lineDestId)"] as? [String: [Int]] {
                                            for hour in destTimetable.keys {
                                                if Int(hour) != nil {
                                                    for mins in destTimetable[hour]! {
                                                        timetable.addSchedule(date: DayDate(Int(hour)!, mins, 0), lineId: line.id, destId: lineDestId)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            timetable.sortSchedules()
                            self.stationList.append(Station(id: stationId!, name: stationName!, lines: stationLinesConverted, timetable: [timetable], coords: stationCoords!))
                        } else {
                            print("Failed to parse", stationFile, "file.")
                            print("StationId:", stationId == nil ? "null" : stationId!)
                            print("StationName:", stationName == nil ? "null" : stationName!)
                            print("StationLines:", stationLines == nil ? "null" : stationLines!)
                            print("StationLogicIds:", stationLogicIds == nil ? "null" : stationLogicIds!)
                            print("StationTimetable:", stationTimetableWeekdays == nil ? "null" : "founded and filled")
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }*/
    
    static func getLine(byTamId id: Int) -> Line? {
        let _line = self.lines.filter({$0.tamId == id})
        
        if _line.count != 1 { return nil }
        return _line[0]
    }
    
    static func getLine(byCitywayId id: Int) -> Line? {
        let _line = self.lines.filter({$0.citywayId == id})
        
        if _line.count != 1 { return nil }
        return _line[0]
    }
    
    static func getStop(byCitywayId id: Int) -> Stop? {
        let _stop = self.stops.filter({$0.citywayId == id})
        
        if _stop.count != 1 { return nil }
        return _stop[0]
    }
    
    static func getLineById(_ id: Int) -> Line? {
        let _line = self.lines.filter({$0.id == id})
        
        if _line.count != 1 { return nil }
        return _line[0]
    }
    
    static func getStationById(_ id: Int) -> StopZone? {
        let _stopzone = self.stopZones.filter({$0.id == id})
        
        if _stopzone.count != 1 { return nil }
        return _stopzone[0]
    }
    
    static func isFavorite(stationId: Int) -> Bool {
        if UserData.favStationsId.contains(stationId) {
            return true
        }
        return false
    }
}
