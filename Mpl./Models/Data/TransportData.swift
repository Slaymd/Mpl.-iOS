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

class TransportData {

    static var referenceDatabase: Connection?
    
    static var stopZones: [StopZone] = []
    static var stops: [Stop] = []
    static var lines: [Line] = []
    static var directions: [Direction] = []
    
    static var stopDirections: [(stopId: Int, directionId: Int)] = []
    static var stopLines: [(stopZoneId: Int, lines: [Line])] = []
    
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
        let past_result = self.lineStops.filter({$0.line == line})
        
        if (past_result.count == 1) {
            return (past_result[0].dirs)
        }
        print("Getting line stops of \(line)")
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
    
    static func getStopZoneLocationsByLine(stopZone: StopZone) -> [(line: Line, location: CLLocationCoordinate2D)] {
        var stopzoneLocs: [(line: Line, location: CLLocationCoordinate2D)] = []
        
        for ()
        
        return (stopzoneLocs)
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
