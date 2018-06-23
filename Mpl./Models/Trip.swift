//
//  Trip.swift
//  Mpl.
//
//  Created by Darius Martin on 23/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

enum TripMode {
    case TRAMWAY
    case BUS
    case WALK
    case UNKNOWN
}

class TripSegment {
    
    var mode: TripMode
    var departure: CLLocation?
    var arrival: CLLocation?
    var duration: Int?
    var distance: Int?
    var departureName: String?
    var arrivalName: String?
    
    var departureStop: Stop?
    var arrivalStop: Stop?
    var departureTime: DayDate?
    var arrivalTime: DayDate?
    var line: Line?
    var destination: String?
    var direction: String?
    
    var intermediateStops: [(loc: CLLocation, name: String?, id: Int)] = []
    
    init(mode: String, json: JSON) {
        switch(mode) {
        case "TRAMWAY":
            self.mode = .TRAMWAY
            self.parseTramBusSegmentJson(json: json)
        case "BUS":
            self.mode = .BUS
            self.parseTramBusSegmentJson(json: json)
        case "WALK":
            self.mode = .WALK
            self.parseWalkSegmentJson(json: json)
        default:
            self.mode = .UNKNOWN
        }
    }
    
    private func parseTramBusSegmentJson(json: JSON) {
        let departure_code = json["departure_code"].intValue
        let departure_name = json["departure_name"].stringValue
        let departure_lat = json["departure_lat"].doubleValue
        let departure_long = json["departure_long"].doubleValue
        let arrival_code = json["arrival_code"].intValue
        let arrival_name = json["arrival_name"].stringValue
        let arrival_lat = json["arrival_lat"].doubleValue
        let arrival_long = json["arrival_long"].doubleValue
        let destination = json["destination"].stringValue
        let direction = json["direction"].stringValue
        let duration = json["duration"].intValue
        let distance = json["distance"].intValue
        let departure_time = json["departure_time"].stringValue
        let arrival_time = json["arrival_time"].stringValue
        let line_id = json["line_id"].intValue
        guard let departureStop = TransportData.getStop(byTamId: departure_code) else { return }
        guard let arrivalStop = TransportData.getStop(byTamId: arrival_code) else { return }
        guard let line = TransportData.getLine(byCitywayId: line_id) else { return }
        
        self.arrival = CLLocation(latitude: arrival_lat, longitude: arrival_long)
        self.departure = CLLocation(latitude: departure_lat, longitude: departure_long)
        self.departureTime = DayDate(tamTime: departure_time)
        self.arrivalTime = DayDate(tamTime: arrival_time)
        self.duration = Int(round((Double(duration) / 60.0)))
        self.distance = distance
        self.departureName = departure_name
        self.arrivalName = arrival_name
        
        self.departureStop = departureStop
        self.arrivalStop = arrivalStop
        self.destination = destination
        self.direction = direction
        self.line = line
        if json.contains(where: {$0.0 == "intermediate_stops"}) {
            self.parseIntermediateStops(json: json["intermediate_stops"])
        }
    }
    
    private func parseWalkSegmentJson(json: JSON) {
        let departure_name = json["departure_name"].stringValue
        let departure_lat = json["departure_lat"].doubleValue
        let departure_long = json["departure_long"].doubleValue
        let arrival_name = json["arrival_name"].stringValue
        let arrival_lat = json["arrival_lat"].doubleValue
        let arrival_long = json["arrival_long"].doubleValue
        let duration = json["duration"].intValue
        let distance = json["distance"].intValue
        let departure_time = json["departure_time"].stringValue
        let arrival_time = json["arrival_time"].stringValue
        
        self.arrival = CLLocation(latitude: arrival_lat, longitude: arrival_long)
        self.departure = CLLocation(latitude: departure_lat, longitude: departure_long)
        self.departureTime = DayDate(tamTime: departure_time)
        self.arrivalTime = DayDate(tamTime: arrival_time)
        self.duration = Int(round((Double(duration) / 60.0)))
        self.distance = distance
        self.departureName = departure_name
        self.arrivalName = arrival_name
        if json.contains(where: {$0.0 == "intermediate_stops"}) {
            self.parseIntermediateStops(json: json["intermediate_stops"])
        }
    }
    
    private func parseIntermediateStops(json: JSON) {
        for (_,interstop):(String, JSON) in json {
            let loc = CLLocation(latitude: interstop["lat"].doubleValue, longitude: interstop["lon"].doubleValue)
            let id = interstop["id"].intValue
            let name = interstop.contains(where: {$0.0 == "name"}) ? interstop["name"].stringValue : nil
            let stop: (loc: CLLocation, name: String?, id: Int) = (loc: loc, name: name, id: id)
            
            self.intermediateStops.append(stop)
        }
    }
}

class Trip {
    
    var departureTime: DayDate
    var arrivalTime: DayDate
    var distance: Int
    var duration: Int
    var tripCO2: Int
    var carCO2: Int
    var segments: [TripSegment] = []
    
    init(departureTime: String, arrivalTime: String, distance: Int, duration: Int, tripCO2: Int, carCO2: Int) {
        self.departureTime = DayDate(tamTime: departureTime)
        self.arrivalTime = DayDate(tamTime: arrivalTime)
        self.distance = distance
        self.duration = Int(round((Double(duration) / 60.0)))
        self.tripCO2 = tripCO2
        self.carCO2 = carCO2
    }
    
}
