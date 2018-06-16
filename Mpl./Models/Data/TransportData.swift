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
import CoreLocation

extension CLLocationCoordinate2D {
    
    // MARK: - CLLocationCoordinate2D+MidPoint
    
    func middleLocationWith(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let lon1 = longitude * Double.pi / 180
        let lon2 = location.longitude * Double.pi / 180
        let lat1 = latitude * Double.pi / 180
        let lat2 = location.latitude * Double.pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / Double.pi, lon3 * 180 / Double.pi)
        return center
    }
}

class TransportData {

    static var referenceDatabase: Connection?
    
    static var stopZones: [StopZone] = []
    static var stops: [Stop] = []
    static var lines: [Line] = []
    static var directions: [Direction] = []
    
    static var stopDirections: [(stopId: Int, directionId: Int)] = []
    static var stopLines: [(stopZoneId: Int, lines: [Line])] = []
    static var lines_polylines: [(line: Line, polylines: [[CLLocationCoordinate2D]])] = []
    
    private static var lineStops: [(line: Line, dirs: [(direction: Int, stopsId: [Int])])] = []
    
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
    
    static func getLines(ofStop stop: Stop, atStopZone stopZone: StopZone?) -> [Line]? {
        var finalStopZone: StopZone
        
        if (stop.lines != nil) { return stop.lines }
        stop.lines = []
        //getting stop zone if not specified
        if (stopZone == nil) {
            if let returnvalue = self.getStopZoneById(stopZoneId: stop.stopZoneId) {
                finalStopZone = returnvalue
            } else { return nil }
        } else { finalStopZone = stopZone! }
        for tmpline in finalStopZone.getLines() {
            for dir in self.getLineStopsIdByDirection(line: tmpline) {
                for stopid in dir.stopsId {
                    if stopid == stop.id && !stop.lines!.contains(tmpline) {
                        stop.lines!.append(tmpline)
                    }
                }
            }
        }
        return stop.lines
    }
    
    static func getLines(atStop stop: Stop) -> [Line] {
        var result: [Line] = []
        var tmpLineIds: [Int] = []
        var tmpLine: Line?
        let lineId = Expression<Int64>("line")
        let stopId = Expression<Int64>("stop")
        let lineStopZonesTable = Table("LINE_STOP").filter(stopId == Int64(stop.id))
        
        if (self.referenceDatabase == nil) { return result }
        for lineDirs in try! self.referenceDatabase!.prepare(lineStopZonesTable) {
            if !tmpLineIds.contains(Int(lineDirs[lineId])) {
                tmpLine = self.getLineById(Int(lineDirs[lineId]))
                
                if tmpLine == nil { continue }
                result.append(tmpLine!)
                tmpLineIds.append(tmpLine!.id)
            }
        }
        return result
    }
    
    private static func getPolyline(from polylineStr: String) -> [CLLocationCoordinate2D] {
        var polyline: [CLLocationCoordinate2D] = []
        
        for point in polylineStr.split(separator: " ") {
            let coords = String(point).split(separator: ",")
            let lat = Double(coords[1])!
            let lon = Double(coords[0])!
            polyline.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        return polyline
    }
    
    static func getLinesPolylines() -> [(line: Line, polylines: [[CLLocationCoordinate2D]])] {
        if self.lines_polylines.count != 0 { return self.lines_polylines }
        var result: [(line: Line, polylines: [[CLLocationCoordinate2D]])] = []
        var dirNames: [(line: Int, dirName: String)] = []
        let lineId = Expression<Int64>("line")
        let dirName = Expression<String>("name")
        let dirType = Expression<String?>("direction_str")
        let polylineString = Expression<String>("polyline")
        let polylineTable = Table("LINE_TRACE")
        
        if (self.referenceDatabase == nil) { return result }
        for dbline in try! self.referenceDatabase!.prepare(polylineTable) {
            var tmp_res = result.filter({$0.line.id == Int(dbline[lineId])})
            
            if dbline[dirType] != nil && dbline[dirType]! == "A" { continue }
            if (tmp_res.count == 0) {
                //New line
                guard let line = self.getLineById(Int(dbline[lineId])) else { continue }
                var tmp: (line: Line, polylines: [[CLLocationCoordinate2D]]) = (line: line, polylines: [])
                
                tmp.polylines.append(self.getPolyline(from: dbline[polylineString]))
                dirNames.append((line: Int(dbline[lineId]), dirName: dbline[dirName]))
                result.append(tmp)
            } else {
                //Existing line
                guard let index = result.index(where: {$0.line == tmp_res[0].line}) else { continue }
                if dirNames.filter({$0.line == Int(dbline[lineId]) && $0.dirName.count == dbline[dirName].count}).count > 0 { continue }
                var tmp: (line: Line, polylines: [[CLLocationCoordinate2D]]) = (line: tmp_res[0].line, polylines: tmp_res[0].polylines)
                tmp.polylines.append(self.getPolyline(from: dbline[polylineString]))
                result.remove(at: index)
                result.insert(tmp, at: index)
                dirNames.append((line: Int(dbline[lineId]), dirName: dbline[dirName]))
            }
        }
        return result.sorted(by: {$0.line.displayId > $1.line.displayId})
    }
    
    private static func fixLocation(ofStop stop: Stop, onLine line: Line) {
        let fixes: [(String, [Int], Double, Double)] = [("Millénaire", [1], 43.603330, 3.909953),("Mondial 98", [1], 43.602770, 3.903944),
                                                        ("Voltaire", [3], 43.603710, 3.889107),("Gare Saint-Roch", [3,4], 43.605209, 3.879704),
                                                        ("Corum", [2], 43.614452, 3.882029)]
        
        for fix in fixes {
            if stop.name == fix.0 && fix.1.contains(line.tamId) {
                stop.coords = CLLocation(latitude: fix.2, longitude: fix.3)
            }
        }
    }
    
    static func getStopZoneLocationsByLine(stopZone: StopZone) -> [(lines: [Line], location: CLLocationCoordinate2D)] {
        var stopZoneLocs: [(lines: [Line], location: CLLocationCoordinate2D)] = []
        
        for stop in stopZone.stops {
            let lines = self.getLines(atStop: stop)
            if (lines.count == 0) { continue }
            var stopZoneLoc = stopZoneLocs.filter({$0.lines == lines})
            
            if lines.count > 0 {
                self.fixLocation(ofStop: stop, onLine: lines[0])
            }
            if stopZoneLoc.count == 1 {
                stopZoneLoc[0].location = stopZoneLoc[0].location.middleLocationWith(location: stop.coords.coordinate)
            } else {
                stopZoneLocs.append((lines: lines, location: stop.coords.coordinate))
            }
        }
        return (stopZoneLocs)
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
    
    static func getLineStopZones(line: Line) -> [StopZone] {
        var result: [StopZone] = []
        let lineId = Expression<Int64>("line")
        let stopZone = Expression<Int64>("stopzone")
        var tmpStopZoneId: Int
        var tmpStopZone: StopZone?
        let lineStopZonesTable = Table("LINE_STOPZONE").filter(lineId == Int64(line.id))
        
        if (self.referenceDatabase == nil) { return result }
        for lineStopZone in try! self.referenceDatabase!.prepare(lineStopZonesTable) {
            tmpStopZoneId = Int(lineStopZone[stopZone])
            tmpStopZone = self.getStopZoneById(stopZoneId: tmpStopZoneId)
            
            if tmpStopZone == nil { continue }
            result.append(tmpStopZone!)
        }
        return result
    }
    
    static func getLineStopsIdByDirection(line: Line) -> [(direction: Int, stopsId: [Int])] {
        var result: [(direction: Int, stopsId: [Int])] = []
        let past_result = self.lineStops.filter({$0.line == line})
        
        if (past_result.count == 1) {
            return (past_result[0].dirs)
        }
        if (self.referenceDatabase == nil) { return result }
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
        self.lineStops.append((line: line, dirs: result))
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
