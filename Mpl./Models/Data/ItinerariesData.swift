//
//  ItinerariesData.swift
//  Mpl.
//
//  Created by Darius Martin on 22/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class ItinerariesData {
    
    public static func get(from departure: MPLLocation, to arrival: MPLLocation, completion: @escaping (_ result: [Trip]) -> Void) {
        var trips: [Trip] = []
        //building url
        let requestUrl = self.getRequestUrl(from: departure, to: arrival)
        //Requesting
        Alamofire.request(requestUrl).responseJSON { response in
            if response.data != nil {
                let json = JSON(response.data!)
                
                for (_,tripJson):(String, JSON) in json {
                    //JSON trip
                    guard let tripInfosJson = tripJson["trip"].dictionary else { break }
                    guard let tripSegmentsJson = tripJson["trip_segments"].array else { break }
                    //Getting parsed trip
                    guard let trip = self.parseTrip(infos: tripInfosJson, segments: tripSegmentsJson) else { break }
                    trips.append(trip)
                }
                completion(trips)
            } else {
                completion(trips)
            }
        }
    }
    
    private static func parseTrip(infos: [String : JSON], segments: [JSON]) -> Trip? {
        guard let departure_time = infos["departure_time"]?.stringValue else { return nil }
        guard let arrival_time = infos["arrival_time"]?.stringValue else { return nil }
        guard let duration = infos["duration"]?.intValue else { return nil }
        guard let distance = infos["distance"]?.intValue else { return nil }
        guard let trip_co2 = infos["trip_co2"]?.intValue else { return nil }
        guard let car_co2 = infos["car_co2"]?.intValue else { return nil }
        let trip = Trip(departureTime: departure_time, arrivalTime: arrival_time, distance: distance, duration: duration, tripCO2: trip_co2, carCO2: car_co2)
        
        for segment in segments {
            if !segment.contains(where: {$0.0 == "mode"}) { continue }
            let mode = segment["mode"].stringValue
            let tripSegment = TripSegment(mode: mode, json: segment)
            
            if tripSegment.mode == .UNKNOWN { continue }
            trip.segments.append(tripSegment)
        }
        return trip
    }
    
    private static func getRequestUrl(from: MPLLocation, to: MPLLocation) -> String {
        let requestUrl: String
        let departureStr: String
        let arrivalStr: String
        let date = Date()
        let dayDateFormat = DateFormatter()
        dayDateFormat.dateFormat = "yyyy-MM-dd"
        let timeDateFormat = DateFormatter()
        timeDateFormat.dateFormat = "HH-mm"
        
        if from.type == .geocoords {
            let depCoords = from.data as! CLLocation
            departureStr = "&depType=ADDRESS&depId=0&depLat=\(depCoords.coordinate.latitude)&depLon=\(depCoords.coordinate.longitude)"
        } else {
            let depStation = from.data as! StopZone
            departureStr = "&depType=STOP_PLACE&depId=\(depStation.citywayId)"
        }
        //arrival
        if to.type == .geocoords {
            let toCoords = to.data as! CLLocation
            arrivalStr = "&arrType=ADDRESS&arrId=0&arrLat=\(toCoords.coordinate.latitude)&arrLon=\(toCoords.coordinate.longitude)"
        } else {
            let toStation = to.data as! StopZone
            arrivalStr = "&arrType=STOP_PLACE&arrId=\(toStation.citywayId)"
        }
        requestUrl = "https://apimobile.tam-voyages.com/api/v1/itinerary?_format=json\(departureStr)\(arrivalStr)&departureTime=\(timeDateFormat.string(from: date))&date=\(dayDateFormat.string(from: date))&algorithm=FASTEST&car=0&vls=0"
        return requestUrl
    }
    
}
